package models_test

import (
	"encoding/json"
	"testing"

	"pun-account-backend/internal/wallets/models"

	"github.com/google/uuid"
)

func TestWalletUI_Serialization(t *testing.T) {
	cardHolder := "PAVLO D."
	last4 := "7642"
	cardBrand := "visa"

	ui := models.WalletUI{
		AuroraAccent: "cyan",
		CardHolder:   &cardHolder,
		Last4:        &last4,
		CardBrand:    &cardBrand,
	}

	bytes, err := json.Marshal(ui)
	if err != nil {
		t.Fatalf("failed to marshal WalletUI: %v", err)
	}

	var decoded models.WalletUI
	if err := json.Unmarshal(bytes, &decoded); err != nil {
		t.Fatalf("failed to unmarshal WalletUI: %v", err)
	}

	if decoded.AuroraAccent != "cyan" {
		t.Errorf("expected aurora_accent 'cyan', got '%s'", decoded.AuroraAccent)
	}
	if decoded.CardHolder == nil || *decoded.CardHolder != "PAVLO D." {
		t.Errorf("expected card_holder 'PAVLO D.', got %v", decoded.CardHolder)
	}
	if decoded.Last4 == nil || *decoded.Last4 != "7642" {
		t.Errorf("expected last4 '7642', got %v", decoded.Last4)
	}
	if decoded.CardBrand == nil || *decoded.CardBrand != "visa" {
		t.Errorf("expected card_brand 'visa', got %v", decoded.CardBrand)
	}
}

func TestWalletUI_SQLScannerAndValuer(t *testing.T) {
	cardHolder := "PAVLO D."
	originalUI := models.WalletUI{
		AuroraAccent: "emerald",
		CardHolder:   &cardHolder,
	}

	// Test Value()
	val, err := originalUI.Value()
	if err != nil {
		t.Fatalf("Value() returned error: %v", err)
	}

	// Test Scan() with []byte
	var scannedUI models.WalletUI
	if err := scannedUI.Scan(val); err != nil {
		t.Fatalf("Scan([]byte) returned error: %v", err)
	}
	if scannedUI.AuroraAccent != "emerald" {
		t.Errorf("expected aurora_accent 'emerald', got '%s'", scannedUI.AuroraAccent)
	}

	// Test Scan() with string
	var stringScanned models.WalletUI
	if err := stringScanned.Scan(string(val.([]byte))); err != nil {
		t.Fatalf("Scan(string) returned error: %v", err)
	}
	if stringScanned.AuroraAccent != "emerald" {
		t.Errorf("expected aurora_accent 'emerald', got '%s'", stringScanned.AuroraAccent)
	}

	// Test Scan() with nil
	var nilScanned models.WalletUI
	if err := nilScanned.Scan(nil); err != nil {
		t.Fatalf("Scan(nil) returned error: %v", err)
	}
	if nilScanned.AuroraAccent != "" {
		t.Errorf("expected empty aurora_accent on nil, got '%s'", nilScanned.AuroraAccent)
	}
}

func TestWallet_FullJSONPayload(t *testing.T) {
	walletID := uuid.MustParse("01927500-0001-7000-8000-000000000001")
	businessID := uuid.MustParse("01927500-0000-7000-8000-000000000001")
	cardHolder := "PAVLO D."
	last4 := "7642"
	cardBrand := "visa"

	wallet := models.Wallet{
		ID:         walletID,
		BusinessID: businessID,
		Name:       "Business Visa Card",
		Type:       models.WalletTypeCreditCard,
		Currency:   "THB",
		Balance:    145250.00,
		IsActive:   true,
		UI: models.WalletUI{
			AuroraAccent: "cyan",
			CardHolder:   &cardHolder,
			Last4:        &last4,
			CardBrand:    &cardBrand,
		},
	}

	bytes, err := json.Marshal(wallet)
	if err != nil {
		t.Fatalf("failed to marshal Wallet: %v", err)
	}

	var parsed models.Wallet
	if err := json.Unmarshal(bytes, &parsed); err != nil {
		t.Fatalf("failed to unmarshal Wallet: %v", err)
	}

	if parsed.Currency != "THB" {
		t.Errorf("expected currency 'THB', got '%s'", parsed.Currency)
	}
	if parsed.UI.AuroraAccent != "cyan" {
		t.Errorf("expected UI.AuroraAccent 'cyan', got '%s'", parsed.UI.AuroraAccent)
	}
	if parsed.UI.Last4 == nil || *parsed.UI.Last4 != "7642" {
		t.Errorf("expected UI.Last4 '7642', got %v", parsed.UI.Last4)
	}
}
