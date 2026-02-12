package handlers

import (
	"encoding/json"
	"fmt"
	"math/rand"
	"net/http"
	"os"

	"api/models"

	"github.com/go-chi/render"
)

type OmikujiHandler struct {
	Fortunes   []models.Omikuji
	ServerInfo models.ServerInfo
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

	// Cache server info once at startup
	serverInfo := getServerInfo()

	return &OmikujiHandler{
		Fortunes:   fortunes,
		ServerInfo: serverInfo,
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

	response := struct {
		models.Omikuji
		ServerInfo models.ServerInfo `json:"server_info"`
	}{
		Omikuji:    selectedFortune,
		ServerInfo: h.ServerInfo,
	}

	render.Status(r, http.StatusOK)
	render.JSON(w, r, response)
}

func (h *OmikujiHandler) GetAll(w http.ResponseWriter, r *http.Request) {
	render.JSON(w, r, h.Fortunes)
}

func getServerInfo() models.ServerInfo {
	hName, _ := os.Hostname()

	instanceID := getAWSMetadata("instance-id")
	
	if instanceID == "not-aws-instance" || instanceID == "unknown" {
		return models.ServerInfo{
			Hostname:         hName,
			PrivateIP:        "127.0.0.1 (Local Mode)",
			InstanceID:       "local-dev",
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