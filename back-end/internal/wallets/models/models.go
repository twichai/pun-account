package models

import (
	"database/sql/driver"
	"encoding/json"
	"fmt"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// User represents the system user / owner.
type User struct {
	ID        uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	Email     string         `gorm:"type:varchar(255);uniqueIndex;not null" json:"email"`
	Name      string         `gorm:"type:varchar(255);not null" json:"name"`
	AvatarURL *string        `gorm:"type:text" json:"avatar_url,omitempty"`
	GoogleID  *string        `gorm:"type:varchar(255);uniqueIndex" json:"google_id,omitempty"`
	CreatedAt time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Businesses []Business `gorm:"foreignKey:OwnerID;constraint:OnDelete:CASCADE" json:"businesses,omitempty"`
}

// Business represents a business owned by a user (e.g., Freelance, Studio, DinoPOS).
type Business struct {
	ID        uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	OwnerID   uuid.UUID      `gorm:"type:uuid;not null;index" json:"owner_id"`
	Name      string         `gorm:"type:varchar(255);not null" json:"name"`
	Currency  string         `gorm:"type:varchar(10);default:'THB';not null" json:"currency"`
	CreatedAt time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Owner        *User         `gorm:"foreignKey:OwnerID" json:"owner,omitempty"`
	Wallets      []Wallet      `gorm:"foreignKey:BusinessID;constraint:OnDelete:CASCADE" json:"wallets,omitempty"`
	Categories   []Category    `gorm:"foreignKey:BusinessID;constraint:OnDelete:CASCADE" json:"categories,omitempty"`
	Transactions []Transaction `gorm:"foreignKey:BusinessID;constraint:OnDelete:CASCADE" json:"transactions,omitempty"`
	Transfers    []Transfer    `gorm:"foreignKey:BusinessID;constraint:OnDelete:CASCADE" json:"transfers,omitempty"`
	Assets       []Asset       `gorm:"foreignKey:BusinessID;constraint:OnDelete:CASCADE" json:"assets,omitempty"`
	Services     []Service     `gorm:"foreignKey:BusinessID;constraint:OnDelete:CASCADE" json:"services,omitempty"`
}

// WalletType enum values
const (
	WalletTypeCash       = "cash"
	WalletTypeBank       = "bank"
	WalletTypeEWallet    = "e_wallet"
	WalletTypeCreditCard = "credit_card"
	WalletTypeOther      = "other"
)

// WalletUI represents UI presentation and card styling attributes.
// Designed to store frontend visual configurations (such as Aurora Mesh gradients,
// card numbers, cardholder names, and brand badges from Flutter's Wallet model).
type WalletUI struct {
	AuroraAccent string  `json:"aurora_accent,omitempty"` // e.g. "emerald", "cyan", "violet", "slate", "amber", "rose"
	CardHolder   *string `json:"card_holder,omitempty"`   // e.g. "PAVLO D."
	Last4        *string `json:"last4,omitempty"`         // e.g. "7642"
	CardBrand    *string `json:"card_brand,omitempty"`    // e.g. "visa", "mastercard"
	ColorHex     *string `json:"color_hex,omitempty"`     // custom accent hex color
	Icon         *string `json:"icon,omitempty"`          // icon name or identifier
}

// Value implements driver.Valuer for database/sql and GORM JSON serialization.
func (u WalletUI) Value() (driver.Value, error) {
	return json.Marshal(u)
}

// Scan implements sql.Scanner for database/sql and GORM JSON deserialization.
func (u *WalletUI) Scan(value any) error {
	if value == nil {
		*u = WalletUI{}
		return nil
	}
	var bytes []byte
	switch v := value.(type) {
	case []byte:
		bytes = v
	case string:
		bytes = []byte(v)
	default:
		return fmt.Errorf("failed to scan WalletUI: incompatible type %T", value)
	}
	if len(bytes) == 0 {
		*u = WalletUI{}
		return nil
	}
	return json.Unmarshal(bytes, u)
}

// Wallet represents a store of money (Cash, KBank, Credit Card, etc.).
// Note: Balance is a cached field; transactions are the true source of truth.
type Wallet struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID uuid.UUID      `gorm:"type:uuid;not null;index" json:"business_id"`
	Name       string         `gorm:"type:varchar(255);not null" json:"name"`
	Type       string         `gorm:"type:varchar(50);not null" json:"type"`
	Currency   string         `gorm:"type:varchar(10);default:'THB';not null" json:"currency"`
	Balance    float64        `gorm:"type:numeric(15,2);default:0.00;not null" json:"balance"`
	UI         WalletUI       `gorm:"type:jsonb;serializer:json;default:'{}';not null" json:"ui"`
	IsActive   bool           `gorm:"default:true;not null" json:"is_active"`
	CreatedAt  time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt  time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// CategoryType enum values
const (
	CategoryIncome      = "income"
	CategoryExpense     = "expense"
	CategoryTypeIncome  = CategoryIncome
	CategoryTypeExpense = CategoryExpense
)

// Category groups transactions (e.g. Software, Marketing, Product).
// BusinessID is NULL for system-wide default categories.
type Category struct {
	ID         uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID *uuid.UUID     `gorm:"type:uuid;index" json:"business_id,omitempty"`
	Name       string         `gorm:"type:varchar(255);not null" json:"name"`
	Type       string         `gorm:"type:varchar(50);not null" json:"type"`
	Icon       string         `gorm:"type:varchar(100)" json:"icon,omitempty"`
	ParentID   *uuid.UUID     `gorm:"type:uuid;index" json:"parent_id,omitempty"`
	IsSystem   bool           `gorm:"default:false;not null;index" json:"is_system"`
	IsActive   bool           `gorm:"default:true;not null" json:"is_active"`
	CreatedAt  time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt  time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt  gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Parent        *Category     `gorm:"foreignKey:ParentID" json:"parent,omitempty"`
	Subcategories []Category    `gorm:"foreignKey:ParentID" json:"subcategories,omitempty"`
	Transactions  []Transaction `gorm:"foreignKey:CategoryID" json:"transactions,omitempty"`
}

// TransactionType enum values
const (
	TransactionTypeIncome            = "income"
	TransactionTypeExpense           = "expense"
	TransactionTypeOwnerWithdrawal   = "owner_withdrawal"
	TransactionTypeOwnerContribution = "owner_contribution"
	TransactionTypeTransfer          = "transfer"
)

// Transaction represents an individual financial movement event.
type Transaction struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"business_id"`
	WalletID        uuid.UUID      `gorm:"type:uuid;not null;index" json:"wallet_id"`
	CategoryID      *uuid.UUID     `gorm:"type:uuid;index" json:"category_id,omitempty"`
	ServiceID       uuid.UUID      `gorm:"type:uuid;not null;index" json:"service_id"`
	Type            string         `gorm:"type:varchar(50);not null" json:"type"`
	Amount          float64        `gorm:"type:numeric(15,2);not null" json:"amount"`
	TransactionDate time.Time      `gorm:"type:timestamptz;not null;default:CURRENT_TIMESTAMP;index" json:"transaction_date"`
	Description     *string        `gorm:"type:text" json:"description,omitempty"`
	CreatedAt       time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt       time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Business    *Business    `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	Wallet      *Wallet      `gorm:"foreignKey:WalletID" json:"wallet,omitempty"`
	Category    *Category    `gorm:"foreignKey:CategoryID" json:"category,omitempty"`
	Service     *Service     `gorm:"foreignKey:ServiceID" json:"service,omitempty"`
	Attachments []Attachment `gorm:"foreignKey:TransactionID;constraint:OnDelete:CASCADE" json:"attachments,omitempty"`
}

// Transfer represents a money movement between two internal wallets (not income, not expense).
type Transfer struct {
	ID              uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"business_id"`
	FromWalletID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"from_wallet_id"`
	ToWalletID      uuid.UUID      `gorm:"type:uuid;not null;index" json:"to_wallet_id"`
	Amount          float64        `gorm:"type:numeric(15,2);not null" json:"amount"`
	TransactionDate time.Time      `gorm:"type:timestamptz;not null;default:CURRENT_TIMESTAMP;index" json:"transaction_date"`
	Note            *string        `gorm:"type:text" json:"note,omitempty"`
	CreatedAt       time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt       time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Business   *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	FromWallet *Wallet   `gorm:"foreignKey:FromWalletID" json:"from_wallet,omitempty"`
	ToWallet   *Wallet   `gorm:"foreignKey:ToWalletID" json:"to_wallet,omitempty"`
}

// Attachment holds receipt images or invoice PDFs linked to transactions.
type Attachment struct {
	ID            uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID    uuid.UUID      `gorm:"type:uuid;not null;index" json:"business_id"`
	TransactionID uuid.UUID      `gorm:"type:uuid;not null;index" json:"transaction_id"`
	FileURL       string         `gorm:"type:text;not null" json:"file_url"`
	FileType      *string        `gorm:"type:varchar(100)" json:"file_type,omitempty"`
	CreatedAt     time.Time      `gorm:"autoCreateTime" json:"created_at"`
	DeletedAt     gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Transaction *Transaction `gorm:"foreignKey:TransactionID" json:"transaction,omitempty"`
}

// Asset represents company assets (e.g., MacBook, Camera, Office Equipment).
// Prepared schema for tracking company assets before opening full UI.
type Asset struct {
	ID             uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID     uuid.UUID      `gorm:"type:uuid;not null;index" json:"business_id"`
	Name           string         `gorm:"type:varchar(255);not null" json:"name"`
	Type           string         `gorm:"type:varchar(50);not null" json:"type"`
	PurchaseAmount float64        `gorm:"type:numeric(15,2);not null" json:"purchase_amount"`
	PurchaseDate   time.Time      `gorm:"type:timestamptz;not null" json:"purchase_date"`
	Status         string         `gorm:"type:varchar(50);default:'active';not null" json:"status"`
	CreatedAt      time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt      time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt      gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
}

// ServiceCategory represents a job track / vertical (e.g., Content Creator, Developer, Designer).
type ServiceCategory struct {
	ID          uuid.UUID      `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID  *uuid.UUID     `gorm:"type:uuid;index" json:"business_id,omitempty"`
	Key         string         `gorm:"type:varchar(50);not null;index" json:"key"`
	Name        string         `gorm:"type:varchar(255);not null" json:"name"`
	Description *string        `gorm:"type:text" json:"description,omitempty"`
	Icon        *string        `gorm:"type:varchar(100)" json:"icon,omitempty"`
	Color       *string        `gorm:"type:varchar(50)" json:"color,omitempty"`
	IsSystem    bool           `gorm:"default:false;not null;index" json:"is_system"`
	IsActive    bool           `gorm:"default:true;not null" json:"is_active"`
	CreatedAt   time.Time      `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt   time.Time      `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt   gorm.DeletedAt `gorm:"index" json:"deleted_at,omitempty"`

	Business *Business `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	Services []Service `gorm:"foreignKey:ServiceCategoryID;constraint:OnDelete:SET NULL" json:"services,omitempty"`
}

// Service represents a SaaS, subscription, cloud tool, or recurring payment recipient.
type Service struct {
	ID                uuid.UUID        `gorm:"type:uuid;primaryKey;default:gen_random_uuid_v7()" json:"id"`
	BusinessID        *uuid.UUID       `gorm:"type:uuid;index" json:"business_id,omitempty"`
	ServiceCategoryID *uuid.UUID       `gorm:"type:uuid;index" json:"service_category_id,omitempty"`
	Name              string           `gorm:"type:varchar(255);not null" json:"name"`
	Provider          *string          `gorm:"type:varchar(100)" json:"provider,omitempty"`
	AccountNumber     *string          `gorm:"type:varchar(100)" json:"account_number,omitempty"`
	Icon              *string          `gorm:"type:varchar(100)" json:"icon,omitempty"`
	Color             *string          `gorm:"type:varchar(50)" json:"color,omitempty"`
	ImageURL          *string          `gorm:"type:text" json:"image_url,omitempty"`
	Badge             *string          `gorm:"type:varchar(50)" json:"badge,omitempty"`
	IsQuick           bool             `gorm:"default:false;not null;index" json:"is_quick"`
	IsSystem          bool             `gorm:"default:false;not null;index" json:"is_system"`
	IsActive          bool             `gorm:"default:true;not null" json:"is_active"`
	CreatedAt         time.Time        `gorm:"autoCreateTime" json:"created_at"`
	UpdatedAt         time.Time        `gorm:"autoUpdateTime" json:"updated_at"`
	DeletedAt         gorm.DeletedAt   `gorm:"index" json:"deleted_at,omitempty"`

	Business        *Business        `gorm:"foreignKey:BusinessID" json:"business,omitempty"`
	ServiceCategory *ServiceCategory `gorm:"foreignKey:ServiceCategoryID" json:"service_category,omitempty"`
	Transactions    []Transaction    `gorm:"foreignKey:ServiceID" json:"transactions,omitempty"`
}
