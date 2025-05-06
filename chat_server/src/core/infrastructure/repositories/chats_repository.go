package repositories

import (
	"chat_server/src/core/infrastructure/database"
	"chat_server/src/helpers"
	"context"
	"fmt"

	"cloud.google.com/go/firestore"
)

type ChatRepository struct {
	FireClient *database.FirestorageClient
}

func NewChatRepository(fireClient *database.FirestorageClient) *ChatRepository {
	return &ChatRepository{
		FireClient: fireClient,
	}
}

func (repository *ChatRepository) FindChatByMembers(senderId int, receptorId int) (string, error) {
	ctx := context.Background()
	firestoreClient := repository.FireClient.Client

	chatParticipantsKey := helpers.GetChatParticipantsKey(senderId, receptorId)

	docs, err := firestoreClient.Collection("chats").
		Where("participantsKey", "==", chatParticipantsKey).
		Documents(ctx).GetAll()
	if err != nil {
		return "", err
	}

	if len(docs) == 0 {
		return "", fmt.Errorf("chat not found")
	} else {
		docSnap := docs[0]
		chatId := docSnap.Ref.ID 
		return chatId, nil
	}
}

func (repository *ChatRepository) CreateChat(
	senderId int, 
	senderName string, 
	receptorId int, 
	receptorName string,
) (string, error) {
	ctx := context.Background()
	firestoreClient := repository.FireClient.Client
	chatsRef := firestoreClient.Collection("chats")

	participantsKey := helpers.GetChatParticipantsKey(senderId, receptorId)
	newChat := map[string]any{
		"participantsKey": participantsKey,
		"lastMessage":     "",
		"participants":    []int{senderId, receptorId},
		"namesToShow":     []string{senderName, receptorName},
		"updatedAt":       firestore.ServerTimestamp,
	}

	chatDoc, _, err := chatsRef.Add(ctx, newChat)
	if err != nil {
		return "", err
	}
	chatId := chatDoc.ID
	return chatId, nil
}
