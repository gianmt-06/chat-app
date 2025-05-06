package helpers

import "fmt"

func GetChatParticipantsKey(senderId int, receptorId int) string {
	return fmt.Sprintf("%d_%d", min(senderId, receptorId), max(senderId, receptorId))
}