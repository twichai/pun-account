package services

import (
	"context"
	"errors"

	"pun-account-backend/internal/services/repository"
	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

var (
	ErrNotFound = errors.New("resource not found")
)

// ServiceService defines business logic for services and categories.
type ServiceService interface {
	ListCategories(ctx context.Context, businessID *uuid.UUID) ([]models.ServiceCategory, error)
	ListServices(ctx context.Context, businessID *uuid.UUID, categoryKey string) ([]models.Service, error)
	CreateService(ctx context.Context, service *models.Service) (*models.Service, error)
}

type serviceService struct {
	repo repository.ServiceRepository
}

// NewServiceService constructs a ServiceService implementation.
func NewServiceService(repo repository.ServiceRepository) ServiceService {
	return &serviceService{repo: repo}
}

func (s *serviceService) ListCategories(ctx context.Context, businessID *uuid.UUID) ([]models.ServiceCategory, error) {
	return s.repo.ListServiceCategories(ctx, businessID)
}

func (s *serviceService) ListServices(ctx context.Context, businessID *uuid.UUID, categoryKey string) ([]models.Service, error) {
	return s.repo.ListServices(ctx, businessID, categoryKey)
}

func (s *serviceService) CreateService(ctx context.Context, service *models.Service) (*models.Service, error) {
	if service.ID == uuid.Nil {
		newID, err := uuid.NewV7()
		if err != nil {
			return nil, err
		}
		service.ID = newID
	}

	err := s.repo.CreateService(ctx, service)
	if err != nil {
		return nil, err
	}

	return s.repo.GetService(ctx, service.ID)
}

func (s *serviceService) GetService(ctx context.Context, id uuid.UUID) (*models.Service, error) {
	svc, err := s.repo.GetService(ctx, id)
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, ErrNotFound
		}
		return nil, err
	}
	return svc, nil
}
