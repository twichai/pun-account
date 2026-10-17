package services

import (
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"net/http"
	"os"
	"strings"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"

	"pun-account-backend/internal/auth/repository"
	"pun-account-backend/internal/wallets/models"
)

var (
	ErrInvalidToken   = errors.New("invalid or expired authentication token")
	ErrInvalidRequest = errors.New("email or google id is required")
)

type GoogleSignInRequest struct {
	IDToken   string `json:"id_token"`
	Email     string `json:"email"`
	Name      string `json:"name"`
	AvatarURL string `json:"avatar_url"`
	GoogleID  string `json:"google_id"`
}

type UserResponse struct {
	ID           uuid.UUID  `json:"id"`
	Email        string     `json:"email"`
	Name         string     `json:"name"`
	AvatarURL    *string    `json:"avatar_url,omitempty"`
	GoogleID     *string    `json:"google_id,omitempty"`
	BusinessID   *uuid.UUID `json:"business_id,omitempty"`
	BusinessName *string    `json:"business_name,omitempty"`
}

type AuthResponse struct {
	Token string       `json:"token"`
	User  UserResponse `json:"user"`
}

type GoogleTokenInfo struct {
	Sub           string `json:"sub"`
	Email         string `json:"email"`
	EmailVerified string `json:"email_verified"`
	Name          string `json:"name"`
	Picture       string `json:"picture"`
}

type AuthClaims struct {
	UserID     uuid.UUID `json:"user_id"`
	Email      string    `json:"email"`
	Name       string    `json:"name"`
	BusinessID uuid.UUID `json:"business_id,omitempty"`
	jwt.RegisteredClaims
}

type AuthService interface {
	SignInWithGoogle(ctx context.Context, req GoogleSignInRequest) (*AuthResponse, error)
	GetMe(ctx context.Context, userID uuid.UUID) (*AuthResponse, error)
	VerifyToken(tokenString string) (*AuthClaims, error)
}

type authService struct {
	repo       repository.AuthRepository
	httpClient *http.Client
	jwtSecret  []byte
}

func NewAuthService(repo repository.AuthRepository) AuthService {
	secret := os.Getenv("JWT_SECRET")
	if secret == "" {
		secret = "pun-account-dev-secret-change-in-production"
	}

	return &authService{
		repo: repo,
		httpClient: &http.Client{
			Timeout: 8 * time.Second,
		},
		jwtSecret: []byte(secret),
	}
}

func (s *authService) verifyGoogleIDToken(ctx context.Context, idToken string) (*GoogleTokenInfo, error) {
	// Skip external verification for test/mock tokens
	if strings.HasPrefix(idToken, "mock_") || strings.HasPrefix(idToken, "demo_") {
		return nil, fmt.Errorf("mock token skipped: %s", idToken)
	}

	url := fmt.Sprintf("https://oauth2.googleapis.com/tokeninfo?id_token=%s", idToken)
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, url, nil)
	if err != nil {
		return nil, fmt.Errorf("failed to create tokeninfo request: %w", err)
	}

	resp, err := s.httpClient.Do(req)
	if err != nil {
		return nil, fmt.Errorf("failed to call tokeninfo: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("google tokeninfo returned status %d", resp.StatusCode)
	}

	var info GoogleTokenInfo
	if err := json.NewDecoder(resp.Body).Decode(&info); err != nil {
		return nil, fmt.Errorf("failed to decode google token info: %w", err)
	}

	return &info, nil
}

func (s *authService) SignInWithGoogle(ctx context.Context, req GoogleSignInRequest) (*AuthResponse, error) {
	email := strings.TrimSpace(req.Email)
	name := strings.TrimSpace(req.Name)
	avatarURL := strings.TrimSpace(req.AvatarURL)
	googleID := strings.TrimSpace(req.GoogleID)

	// If IDToken is provided, attempt verification with Google
	if req.IDToken != "" {
		info, err := s.verifyGoogleIDToken(ctx, req.IDToken)
		if err == nil && info != nil && info.Email != "" {
			email = info.Email
			if info.Name != "" {
				name = info.Name
			}
			if info.Picture != "" {
				avatarURL = info.Picture
			}
			if info.Sub != "" {
				googleID = info.Sub
			}
		}
	}

	if email == "" && googleID == "" {
		return nil, ErrInvalidRequest
	}

	if name == "" {
		parts := strings.Split(email, "@")
		if len(parts) > 0 && parts[0] != "" {
			name = parts[0]
		} else {
			name = "Solopreneur"
		}
	}

	var user *models.User
	var err error

	// 1. Try finding by GoogleID if present
	if googleID != "" {
		user, err = s.repo.FindUserByGoogleID(ctx, googleID)
		if err != nil {
			return nil, err
		}
	}

	// 2. Fall back to finding by Email
	if user == nil && email != "" {
		user, err = s.repo.FindUserByEmail(ctx, email)
		if err != nil {
			return nil, err
		}
	}

	var activeBusiness *models.Business

	// 3. User already exists: update info if needed
	if user != nil {
		updated := false
		if googleID != "" && (user.GoogleID == nil || *user.GoogleID != googleID) {
			user.GoogleID = &googleID
			updated = true
		}
		if avatarURL != "" && (user.AvatarURL == nil || *user.AvatarURL != avatarURL) {
			user.AvatarURL = &avatarURL
			updated = true
		}
		if name != "" && user.Name != name {
			user.Name = name
			updated = true
		}

		if updated {
			_ = s.repo.UpdateUser(ctx, user)
		}

		if len(user.Businesses) > 0 {
			activeBusiness = &user.Businesses[0]
		} else {
			activeBusiness, _ = s.repo.GetFirstBusinessByOwnerID(ctx, user.ID)
		}
	} else {
		// 4. Create new user + default business + default cash wallet
		newUser := &models.User{
			Email: email,
			Name:  name,
		}
		if googleID != "" {
			newUser.GoogleID = &googleID
		}
		if avatarURL != "" {
			newUser.AvatarURL = &avatarURL
		}

		createdUser, createdBusiness, err := s.repo.CreateUserWithBusiness(
			ctx,
			newUser,
			fmt.Sprintf("%s's Business", name),
			"THB",
		)
		if err != nil {
			return nil, fmt.Errorf("failed to create user account: %w", err)
		}

		user = createdUser
		activeBusiness = createdBusiness
	}

	// 5. Generate JWT token
	token, err := s.generateJWT(user, activeBusiness)
	if err != nil {
		return nil, fmt.Errorf("failed to generate auth token: %w", err)
	}

	return s.buildAuthResponse(token, user, activeBusiness), nil
}

func (s *authService) GetMe(ctx context.Context, userID uuid.UUID) (*AuthResponse, error) {
	user, err := s.repo.FindUserByID(ctx, userID)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, errors.New("user not found")
	}

	var activeBusiness *models.Business
	if len(user.Businesses) > 0 {
		activeBusiness = &user.Businesses[0]
	} else {
		activeBusiness, _ = s.repo.GetFirstBusinessByOwnerID(ctx, user.ID)
	}

	token, err := s.generateJWT(user, activeBusiness)
	if err != nil {
		return nil, fmt.Errorf("failed to generate token: %w", err)
	}

	return s.buildAuthResponse(token, user, activeBusiness), nil
}

func (s *authService) generateJWT(user *models.User, business *models.Business) (string, error) {
	var busID uuid.UUID
	if business != nil {
		busID = business.ID
	}

	claims := AuthClaims{
		UserID:     user.ID,
		Email:      user.Email,
		Name:       user.Name,
		BusinessID: busID,
		RegisteredClaims: jwt.RegisteredClaims{
			ExpiresAt: jwt.NewNumericDate(time.Now().Add(30 * 24 * time.Hour)), // 30 days
			IssuedAt:  jwt.NewNumericDate(time.Now()),
			Issuer:    "pun-account-api",
		},
	}

	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(s.jwtSecret)
}

func (s *authService) VerifyToken(tokenString string) (*AuthClaims, error) {
	token, err := jwt.ParseWithClaims(tokenString, &AuthClaims{}, func(t *jwt.Token) (interface{}, error) {
		if _, ok := t.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("unexpected signing method: %v", t.Header["alg"])
		}
		return s.jwtSecret, nil
	})

	if err != nil {
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(*AuthClaims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	return claims, nil
}

func (s *authService) buildAuthResponse(token string, user *models.User, business *models.Business) *AuthResponse {
	var busID *uuid.UUID
	var busName *string
	if business != nil {
		busID = &business.ID
		busName = &business.Name
	}

	return &AuthResponse{
		Token: token,
		User: UserResponse{
			ID:           user.ID,
			Email:        user.Email,
			Name:         user.Name,
			AvatarURL:    user.AvatarURL,
			GoogleID:     user.GoogleID,
			BusinessID:   busID,
			BusinessName: busName,
		},
	}
}
