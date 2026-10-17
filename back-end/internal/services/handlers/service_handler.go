package handlers

import (
	"errors"
	"net/http"

	"pun-account-backend/internal/services/services"
	"pun-account-backend/internal/wallets/models"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type ServiceHandler struct {
	service services.ServiceService
}

func NewServiceHandler(service services.ServiceService) *ServiceHandler {
	return &ServiceHandler{service: service}
}

func (h *ServiceHandler) RegisterRoutes(router fiber.Router) {
	servicesGroup := router.Group("/services")
	servicesGroup.Get("/categories", h.ListCategories)
	servicesGroup.Get("/categories/:categories_id", h.GetCategory)
	servicesGroup.Get("/", h.ListServices)
	servicesGroup.Post("/", h.CreateService)
}

func (h *ServiceHandler) ListCategories(c *fiber.Ctx) error {
	var businessUUID *uuid.UUID
	businessIDStr := c.Query("business_id")
	if businessIDStr != "" {
		parsed, err := uuid.Parse(businessIDStr)
		if err == nil {
			businessUUID = &parsed
		}
	}

	search := c.Query("search")

	categories, err := h.service.ListCategories(c.Context(), businessUUID, search)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INTERNAL_ERROR",
				"message": "Failed to list service categories",
			},
		})
	}

	return c.Status(http.StatusOK).JSON(categories)
}

func (h *ServiceHandler) GetCategory(c *fiber.Ctx) error {
	categoryID := c.Params("categories_id")
	if categoryID == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INVALID_INPUT",
				"message": "Category ID or key is required",
			},
		})
	}

	var businessUUID *uuid.UUID
	businessIDStr := c.Query("business_id")
	if businessIDStr != "" {
		parsed, err := uuid.Parse(businessIDStr)
		if err == nil {
			businessUUID = &parsed
		}
	}

	search := c.Query("search")

	category, err := h.service.GetCategory(c.Context(), categoryID, businessUUID, search)
	if err != nil {
		if errors.Is(err, services.ErrNotFound) {
			return c.Status(http.StatusNotFound).JSON(fiber.Map{
				"error": fiber.Map{
					"code":    "NOT_FOUND",
					"message": "Service category not found",
				},
			})
		}
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INTERNAL_ERROR",
				"message": "Failed to retrieve service category",
			},
		})
	}

	return c.Status(http.StatusOK).JSON(category)
}

func (h *ServiceHandler) ListServices(c *fiber.Ctx) error {
	var businessUUID *uuid.UUID
	businessIDStr := c.Query("business_id")
	if businessIDStr != "" {
		parsed, err := uuid.Parse(businessIDStr)
		if err == nil {
			businessUUID = &parsed
		}
	}

	categoryKey := c.Query("category")
	servicesList, err := h.service.ListServices(c.Context(), businessUUID, categoryKey)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INTERNAL_ERROR",
				"message": "Failed to list services",
			},
		})
	}

	return c.Status(http.StatusOK).JSON(servicesList)
}

type createServiceRequest struct {
	BusinessID        *string `json:"business_id"`
	ServiceCategoryID *string `json:"service_category_id"`
	Name              string  `json:"name"`
	Provider          *string `json:"provider"`
	AccountNumber     *string `json:"account_number"`
	Icon              *string `json:"icon"`
	Color             *string `json:"color"`
	ImageURL          *string `json:"image_url"`
	Badge             *string `json:"badge"`
	IsQuick           bool    `json:"is_quick"`
}

func (h *ServiceHandler) CreateService(c *fiber.Ctx) error {
	var req createServiceRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INVALID_BODY",
				"message": "Failed to parse request payload",
			},
		})
	}

	if req.Name == "" {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INVALID_INPUT",
				"message": "Service name is required",
			},
		})
	}

	service := models.Service{
		Name:          req.Name,
		Provider:      req.Provider,
		AccountNumber: req.AccountNumber,
		Icon:          req.Icon,
		Color:         req.Color,
		ImageURL:      req.ImageURL,
		Badge:         req.Badge,
		IsQuick:       req.IsQuick,
		IsActive:      true,
	}

	if req.BusinessID != nil && *req.BusinessID != "" {
		bID, err := uuid.Parse(*req.BusinessID)
		if err == nil {
			service.BusinessID = &bID
		}
	}

	if req.ServiceCategoryID != nil && *req.ServiceCategoryID != "" {
		cID, err := uuid.Parse(*req.ServiceCategoryID)
		if err == nil {
			service.ServiceCategoryID = &cID
		}
	}

	created, err := h.service.CreateService(c.Context(), &service)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": fiber.Map{
				"code":    "INTERNAL_ERROR",
				"message": "Failed to create service",
			},
		})
	}

	return c.Status(http.StatusCreated).JSON(created)
}
