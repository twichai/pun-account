package services_test

import (
	"context"
	"testing"

	"github.com/google/uuid"

	"pun-account-backend/internal/auth/repository"
	"pun-account-backend/internal/auth/services"
	"pun-account-backend/internal/wallets/models"
)

type mockAuthRepository struct {
	users        map[string]*models.User
	usersByID    map[uuid.UUID]*models.User
	usersByGId   map[string]*models.User
	businesses   map[uuid.UUID]*models.Business
	createdUsers []*models.User
}

func newMockAuthRepo() *mockAuthRepository {
	return &mockAuthRepository{
		users:      make(map[string]*models.User),
		usersByID:  make(map[uuid.UUID]*models.User),
		usersByGId: make(map[string]*models.User),
		businesses: make(map[uuid.UUID]*models.Business),
	}
}

func (m *mockAuthRepository) FindUserByGoogleID(ctx context.Context, googleID string) (*models.User, error) {
	return m.usersByGId[googleID], nil
}

func (m *mockAuthRepository) FindUserByEmail(ctx context.Context, email string) (*models.User, error) {
	return m.users[email], nil
}

func (m *mockAuthRepository) FindUserByID(ctx context.Context, id uuid.UUID) (*models.User, error) {
	return m.usersByID[id], nil
}

func (m *mockAuthRepository) CreateUserWithBusiness(
	ctx context.Context,
	user *models.User,
	businessName,
	currency string,
) (*models.User, *models.Business, error) {
	if user.ID == uuid.Nil {
		user.ID, _ = uuid.NewV7()
	}
	busID, _ := uuid.NewV7()
	bus := &models.Business{
		ID:       busID,
		OwnerID:  user.ID,
		Name:     businessName,
		Currency: currency,
	}
	user.Businesses = []models.Business{*bus}

	m.users[user.Email] = user
	m.usersByID[user.ID] = user
	if user.GoogleID != nil {
		m.usersByGId[*user.GoogleID] = user
	}
	m.businesses[user.ID] = bus
	m.createdUsers = append(m.createdUsers, user)

	return user, bus, nil
}

func (m *mockAuthRepository) UpdateUser(ctx context.Context, user *models.User) error {
	m.users[user.Email] = user
	m.usersByID[user.ID] = user
	if user.GoogleID != nil {
		m.usersByGId[*user.GoogleID] = user
	}
	return nil
}

func (m *mockAuthRepository) GetFirstBusinessByOwnerID(ctx context.Context, ownerID uuid.UUID) (*models.Business, error) {
	return m.businesses[ownerID], nil
}

var _ repository.AuthRepository = (*mockAuthRepository)(nil)

func TestAuthService_SignInWithGoogle_NewUser(t *testing.T) {
	repo := newMockAuthRepo()
	svc := services.NewAuthService(repo)

	req := services.GoogleSignInRequest{
		Email:     "noah@pun.dev",
		Name:      "Noah Pun",
		AvatarURL: "https://example.com/noah.jpg",
		GoogleID:  "google-sub-456",
	}

	res, err := svc.SignInWithGoogle(context.Background(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if res.Token == "" {
		t.Error("expected valid JWT token")
	}
	if res.User.Email != "noah@pun.dev" {
		t.Errorf("expected noah@pun.dev, got %s", res.User.Email)
	}
	if res.User.BusinessName == nil || *res.User.BusinessName != "Noah Pun's Business" {
		t.Errorf("expected Noah Pun's Business, got %v", res.User.BusinessName)
	}

	// Verify JWT can be verified
	claims, err := svc.VerifyToken(res.Token)
	if err != nil {
		t.Fatalf("token verification failed: %v", err)
	}
	if claims.Email != "noah@pun.dev" {
		t.Errorf("expected token claims email to match, got %s", claims.Email)
	}
}

func TestAuthService_SignInWithGoogle_ExistingUser(t *testing.T) {
	repo := newMockAuthRepo()
	svc := services.NewAuthService(repo)

	// Pre-create user
	existingUser := &models.User{
		Email: "existing@pun.dev",
		Name:  "Existing Maker",
	}
	_, _, err := repo.CreateUserWithBusiness(context.Background(), existingUser, "Existing Business", "THB")
	if err != nil {
		t.Fatalf("failed to setup: %v", err)
	}

	req := services.GoogleSignInRequest{
		Email:     "existing@pun.dev",
		Name:      "Existing Maker Updated",
		AvatarURL: "https://example.com/new-pic.jpg",
		GoogleID:  "google-new-id",
	}

	res, err := svc.SignInWithGoogle(context.Background(), req)
	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	if res.User.Name != "Existing Maker Updated" {
		t.Errorf("expected updated name, got %s", res.User.Name)
	}
	if len(repo.createdUsers) != 1 {
		t.Errorf("should not create duplicate user, created count: %d", len(repo.createdUsers))
	}
}
