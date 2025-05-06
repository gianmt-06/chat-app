package api_requests

type SendMessageRequest struct {
	Content    string `json:"content" binding:"required"`
	// SenderId   int    `json:"senderId" binding:"required"`
	ReceptorId int    `json:"receptorId" binding:"required"`
}