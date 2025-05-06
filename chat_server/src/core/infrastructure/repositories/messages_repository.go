package repositories

import (
	firebase_entities "chat_server/src/core/entities/database/firebase"
	"chat_server/src/core/infrastructure/database"
	"chat_server/src/utils"
	"context"
	"fmt"
	"log"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go"
	"firebase.google.com/go/messaging"
	"google.golang.org/api/option"
)

type MessageRepository struct {
	FireClient *database.FirestorageClient
	MessagingClient *messaging.Client
}

func NewMessageRepository(fireClient *database.FirestorageClient) *MessageRepository {
	opt := option.WithCredentialsFile("config/chat-app-d8ea0-firebase-adminsdk-fbsvc-0558f59fdb.json")

	app, err := firebase.NewApp(context.Background(), nil, opt)
	if err != nil {
		log.Fatal("no app notifications")
	}

	fcmClient, err := app.Messaging(context.Background())
	if err != nil {
		log.Fatal("no ftm client")
	}

	return &MessageRepository{
		FireClient: fireClient,
		MessagingClient: fcmClient,
	}
}

func (repository *MessageRepository) NotifyDivices(
	devices []string,
	title string,
	body string,
	senderId int,
	receptorId int,
	chatId string,
) ([]firebase_entities.DeviceNotificationResult, error) {
	var deviceErrors []firebase_entities.DeviceNotificationResult

	for _, tokenDevice := range devices {
		_, err := repository.MessagingClient.Send(context.Background(), &messaging.Message{
			Data: map[string]string{
				"route": "/chat",
				"chatId": chatId,
				"senderId": fmt.Sprint(senderId),
				"senderName": title,
				"receptorId": fmt.Sprint(receptorId),
			},
			Notification: &messaging.Notification{
				Title: title,
				Body:  body,
				ImageURL: utils.GetProfilePicture(senderId),
			},
			Token: tokenDevice,
		})
		if err != nil {
			deviceErrors = append(deviceErrors, firebase_entities.DeviceNotificationResult{
				Token: tokenDevice,
				Error: err,
			})
		}
	}

	return deviceErrors, nil
}

func (repository *MessageRepository) SendMessage(
	chatId string,
	content string,
	senderId int,
	receptorId int,
) (error) {
	ctx := context.Background()
	firestoreClient := repository.FireClient.Client
	chatRef := firestoreClient.Collection("chats").Doc(chatId)

	message := map[string]any{
		"content":   content,
		"senderId":  senderId,
		"status":    0,
		"timestamp": firestore.ServerTimestamp,
	}

	_, _, err := chatRef.Collection("messages").Add(ctx, message)
	if err != nil {
		return err
	}
	
	update := []firestore.Update{
		{Path: "status", Value: "unread"},
		{Path: "lastSender", Value: senderId},
		{Path: "lastMessage", Value: content},
		{Path: "updatedAt", Value: firestore.ServerTimestamp},
	}
	_, err = chatRef.Update(ctx, update)
	if err != nil {
		return err
	}

	return nil
}

func (repository *MessageRepository) ReadMessage(userId int, chatId string) error {
	ctx := context.Background()
	firestoreClient := repository.FireClient.Client
	chatRef := firestoreClient.Collection("chats").Doc(chatId)

	chatSnap, err := chatRef.Get(ctx)
	if err != nil {
		return err
	}

	data := chatSnap.Data()

	fmt.Println(data)
	
	lastSender, ok := data["lastSender"].(int64)
	if !ok {
		return fmt.Errorf("no last sender")
	}

	lastSenderInt := int(lastSender)

	if lastSenderInt != userId {
		status, ok := data["status"].(string)
		if !ok {
			return fmt.Errorf("no chat status")
		}

		if status == "unread" {
			update := []firestore.Update{
				{Path: "status", Value: "read"},
			}
			_, err = chatRef.Update(ctx, update)
			if err != nil {
				return err
			}
		}
	}
	
	return nil
}
