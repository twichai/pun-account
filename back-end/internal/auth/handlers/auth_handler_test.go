package handlers_test

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"

	"pun-account-backend/internal/auth/handlers"
	"pun-account-backend/internal/auth/services"
)

type stubAuthService struct {
	users map[string]*services.UserResponse
}

func newStubAuthService() *stubAuthService {
	return &stubAuthService{
		users: make(map[string]*services.UserResponse),
	}
}

func (s *stubAuthService) SignInWithGoogle(ctx context.Context, req services.GoogleSignInRequest) (*services.AuthResponse, error) {
	if req.Email == "" && req.GoogleID == "" && req.IDToken == "" {
		return nil, services.ErrInvalidRequest
	}

	email := req.Email
	if email == "" {
		email = "test@example.com"
	}
	name := req.Name
	if name == "" {
		name = "Test User"
	}

	userID, _ := uuid.NewV7()
	busID, _ := uuid.NewV7()
	busName := "Test Business"

	u := &services.UserResponse{
		ID:           userID,
		Email:        email,
		Name:         name,
		AvatarURL:    &req.AvatarURL,
		GoogleID:     &req.GoogleID,
		BusinessID:   &busID,
		BusinessName: &busName,
	}
	s.users[userID.String()] = u

	return &services.AuthResponse{
		Token: "mock-jwt-token-for-user",
		User:  *u,
	}, nil
}

func (s *stubAuthService) GetMe(ctx context.Context, userID uuid.UUID) (*services.AuthResponse, error) {
	u, ok := s.users[userID.String()]
	if !ok {
		return nil, services.ErrInvalidToken
	}
	return &services.AuthResponse{
		Token: "mock-jwt-token-for-user",
		User:  *u,
	}, nil
}

func (s *stubAuthService) VerifyToken(tokenString string) (*services.AuthClaims, error) {
	if tokenString != "mock-jwt-token-for-user" {
		return nil, services.ErrInvalidToken
	}

	for _, u := range s.users {
		var busID uuid.UUID
		if u.BusinessID != nil {
			busID = *u.BusinessID
		}
		return &services.AuthClaims{
			UserID:     u.ID,
			Email:      u.Email,
			Name:       u.Name,
			BusinessID: busID,
		}, nil
	}

	uid, _ := uuid.NewV7()
	return &services.AuthClaims{
		UserID: uid,
		Email:  "test@example.com",
		Name:   "Test",
	}, nil
}

func setupAuthApp(service services.AuthService) *fiber.App {
	app := fiber.New()
	api := app.Group("/api/v1")
	h := handlers.NewAuthHandler(service)
	h.RegisterRoutes(api)
	return app
}

func TestSignInWithGoogle_Success(t *testing.T) {
	service := newStubAuthService()
	app := setupAuthApp(service)

	payload := map[string]interface{}{
		"email":      "alex@maker.io",
		"name":       "Alex Maker",
		"avatar_url": "https://example.com/avatar.png",
		"google_id":  "google-123456",
	}
	body, _ := json.Marshal(payload)

	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/google", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req, 2000)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
	}

	var res services.AuthResponse
	if err := json.NewDecoder(resp.Body).Decode(&res); err != nil {
		t.Fatalf("failed to decode response: %v", err)
	}

	if res.Token == "" {
		t.Error("expected non-empty token")
	}
	if res.User.Email != "alex@maker.io" {
		t.Errorf("expected alex@maker.io, got %s", res.User.Email)
	}
}

func TestSignInWithGoogle_MissingFields(t *testing.T) {
	service := newStubAuthService()
	app := setupAuthApp(service)

	body := []byte(`{}`)
	req := httptest.NewRequest(http.MethodPost, "/api/v1/auth/google", bytes.NewReader(body))
	req.Header.Set("Content-Type", "application/json")

	resp, err := app.Test(req, 2000)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.StatusCode != http.StatusBadRequest {
		t.Fatalf("expected 400 Bad Request, got %d", resp.StatusCode)
	}

	resBody, _ := io.ReadAll(resp.Body)
	if !bytes.Contains(resBody, []byte("INVALID_INPUT")) {
		t.Errorf("expected INVALID_INPUT error code, got %s", string(resBody))
	}
}

func TestGetMe_Unauthorized(t *testing.T) {
	service := newStubAuthService()
	app := setupAuthApp(service)

	req := httptest.NewRequest(http.MethodGet, "/api/v1/auth/me", nil)
	resp, err := app.Test(req, 2000)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.StatusCode != http.StatusUnauthorized {
		t.Fatalf("expected 401 Unauthorized, got %d", resp.StatusCode)
	}
}

func TestGetMe_Success(t *testing.T) {
	service := newStubAuthService()
	app := setupAuthApp(service)

	// First sign in to populate stub
	loginPayload := map[string]interface{}{
		"email":     "solopreneur@indie.co",
		"name":      "Indie Solopreneur",
		"google_id": "google-999",
	}
	b, _ := json.Marshal(loginPayload)
	loginReq := httptest.NewRequest(http.MethodPost, "/api/v1/auth/google", bytes.NewReader(b))
	loginReq.Header.Set("Content-Type", "application/json")
	loginResp, _ := app.Test(loginReq, 2000)

	var authRes services.AuthResponse
	_ = json.NewDecoder(loginResp.Body).Decode(&authRes)

	// Now call /api/v1/auth/me
	meReq := httptest.NewRequest(http.MethodGet, "/api/v1/auth/me", nil)
	meReq.Header.Set("Authorization", "Bearer "+authRes.Token)

	resp, err := app.Test(meReq, 2000)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("expected 200 OK, got %d", resp.StatusCode)
	}

	var meRes services.AuthResponse
	_ = json.NewDecoder(resp.Body).Decode(&meRes)
	if meRes.User.Email != "solopreneur@indie.co" {
		t.Errorf("expected solopreneur@indie.co, got %s", meRes.User.Email)
	}
}
