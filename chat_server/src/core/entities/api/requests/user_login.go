package api_requests

type LoginRequest struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
	TCM      string `json:"TCM" binding:"required"`
}