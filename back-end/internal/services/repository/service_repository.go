package repository

import (
	"context"

	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// ServiceRepository defines database operations for services and categories.
type ServiceRepository interface {
	ListServiceCategories(ctx context.Context, businessID *uuid.UUID, search string) ([]models.ServiceCategory, error)
	GetServiceCategory(ctx context.Context, idOrKey string, businessID *uuid.UUID, search string) (*models.ServiceCategory, error)
	ListServices(ctx context.Context, businessID *uuid.UUID, categoryKey string) ([]models.Service, error)
	CreateService(ctx context.Context, service *models.Service) error
	GetService(ctx context.Context, id uuid.UUID) (*models.Service, error)
}

type serviceRepository struct {
	db *gorm.DB
}

// NewServiceRepository constructs a new ServiceRepository with GORM.
func NewServiceRepository(db *gorm.DB) ServiceRepository {
	return &serviceRepository{db: db}
}

func (r *serviceRepository) ListServiceCategories(ctx context.Context, businessID *uuid.UUID, search string) ([]models.ServiceCategory, error) {
	var categories []models.ServiceCategory
	query := r.db.WithContext(ctx).Where("is_active = ?", true)

	if businessID != nil {
		query = query.Where("business_id = ? OR business_id IS NULL", *businessID)
	} else {
		query = query.Where("business_id IS NULL")
	}

	if search != "" {
		searchPattern := "%" + search + "%"
		query = query.Where(
			"service_categories.name ILIKE ? OR EXISTS (SELECT 1 FROM services WHERE services.service_category_id = service_categories.id AND services.name ILIKE ? AND services.is_active = ?)",
			searchPattern, searchPattern, true,
		)
	}

	// Preload associated services, ordered by is_quick DESC, created_at ASC
	query = query.Preload("Services", func(db *gorm.DB) *gorm.DB {
		tx := db.Where("is_active = ?", true).Order("is_quick DESC, created_at ASC")
		if search != "" {
			tx = tx.Where("name ILIKE ?", "%"+search+"%")
		}
		return tx
	})

	err := query.Order("created_at ASC").Find(&categories).Error
	return categories, err
}

func (r *serviceRepository) GetServiceCategory(ctx context.Context, idOrKey string, businessID *uuid.UUID, search string) (*models.ServiceCategory, error) {
	var category models.ServiceCategory
	query := r.db.WithContext(ctx).Where("is_active = ?", true)

	if businessID != nil {
		query = query.Where("business_id = ? OR business_id IS NULL", *businessID)
	} else {
		query = query.Where("business_id IS NULL")
	}

	if parsedUUID, err := uuid.Parse(idOrKey); err == nil {
		query = query.Where("id = ?", parsedUUID)
	} else {
		query = query.Where("key = ?", idOrKey)
	}

	query = query.Preload("Services", func(db *gorm.DB) *gorm.DB {
		tx := db.Where("is_active = ?", true).Order("is_quick DESC, created_at ASC")
		if search != "" {
			tx = tx.Where("name ILIKE ?", "%"+search+"%")
		}
		return tx
	})

	err := query.First(&category).Error
	if err != nil {
		return nil, err
	}
	return &category, nil
}

func (r *serviceRepository) ListServices(ctx context.Context, businessID *uuid.UUID, categoryKey string) ([]models.Service, error) {
	var services []models.Service
	query := r.db.WithContext(ctx).
		Preload("ServiceCategory").
		Where("is_active = ?", true)

	if businessID != nil {
		query = query.Where("services.business_id = ? OR services.business_id IS NULL", *businessID)
	} else {
		query = query.Where("services.business_id IS NULL")
	}

	if categoryKey != "" && categoryKey != "all" {
		query = query.Joins("LEFT JOIN service_categories ON service_categories.id = services.service_category_id").
			Where("service_categories.key = ?", categoryKey)
	}

	err := query.Order("services.is_quick DESC, services.created_at ASC").Find(&services).Error
	return services, err
}

func (r *serviceRepository) CreateService(ctx context.Context, service *models.Service) error {
	return r.db.WithContext(ctx).Create(service).Error
}

func (r *serviceRepository) GetService(ctx context.Context, id uuid.UUID) (*models.Service, error) {
	var service models.Service
	err := r.db.WithContext(ctx).Preload("ServiceCategory").First(&service, "id = ?", id).Error
	if err != nil {
		return nil, err
	}
	return &service, nil
}
