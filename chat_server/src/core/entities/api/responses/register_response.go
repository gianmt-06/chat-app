package api_responses

import "chat_server/src/core/entities/domain"

type RegisterResponse struct {
	User domain.User `json:"user"`
}