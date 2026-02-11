package handlers

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"
	"time"

	"api/models"

	"github.com/go-chi/render"
)

type OmikujiHandler struct {
	Fortunes []models.Omikuji
}

func NewOmikujiHandler(filePath string) (*OmikujiHandler, error) {
	file, err := os.Open(filePath)
	if err != nil {
		return nil, fmt.Errorf("không thể mở file data: %w", err)
	}
	defer file.Close()

	var fortunes []models.Omikuji
	decoder := json.NewDecoder(file)
	if err := decoder.Decode(&fortunes); err != nil {
		return nil, fmt.Errorf("lỗi parsing JSON: %w", err)
	}

	rand.Seed(time.Now().UnixNano())

	return &OmikujiHandler{
		Fortunes: fortunes,
	}, nil
}

func (h *OmikujiHandler) Draw(w http.ResponseWriter, r *http.Request) {
	if len(h.Fortunes) == 0 {
		render.Status(r, http.StatusInternalServerError)
		render.JSON(w, r, map[string]string{"error": "Dữ liệu quẻ chưa được load"})
		return
	}

	randomIndex := rand.Intn(len(h.Fortunes))
	selectedFortune := h.Fortunes[randomIndex]

	serverInfo := GetServerInfo()

	response := struct {
		models.Omikuji
		ServerInfo models.ServerInfo `json:"server_info"`
	}{
		Omikuji:    selectedFortune,
		ServerInfo: serverInfo,
	}

	render.Status(r, http.StatusOK)
	render.JSON(w, r, response)
}

func (h *OmikujiHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	render.JSON(w, r, h.Fortunes)
}

func GetServerInfo() models.ServerInfo {
	hName, _ := os.Hostname()

	instanceID := getAWSMetadata("instance-id")
	
	if instanceID == "not-aws-instance" {
		return models.ServerInfo{
			Hostname:  hName,
			PrivateIP: "127.0.0.1 (Local Mode)",
			InstanceID: "local-dev",
			AvailabilityZone: "localhost",
		}
	}

	return models.ServerInfo{
		Hostname:         hName,
		InstanceID:       instanceID,
		AvailabilityZone: getAWSMetadata("placement/availability-zone"),
		PrivateIP:        getAWSMetadata("local-ipv4"),
		LocalHostname:    getAWSMetadata("local-hostname"),
	}
}