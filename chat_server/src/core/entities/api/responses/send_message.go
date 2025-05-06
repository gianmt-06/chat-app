package api_responses

import (
	firebase_entities "chat_server/src/core/entities/database/firebase"
	"chat_server/src/core/entities/domain"
)

type SendMessageResponse struct {
	Message             domain.Message                               `json:"message"`
	NotificationsErrors []firebase_entities.DeviceNotificationResult `json:"notificationErrors"`
}
