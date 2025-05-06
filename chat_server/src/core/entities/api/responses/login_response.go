package api_responses

import "chat_server/src/core/entities/domain"

type LoginResponse struct {
	JWT  string       `json:"token"`
	User *domain.User `json:"user"`
}
