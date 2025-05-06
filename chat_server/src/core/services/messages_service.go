package services

import (
	firebase_entities "chat_server/src/core/entities/database/firebase"
	"chat_server/src/core/entities/domain"
	"chat_server/src/core/infrastructure/repositories"
	"fmt"
	"time"
)

type MessageService struct {
	messageRepository *repositories.MessageRepository
	chatRepository    *repositories.ChatRepository
	userRepository    *repositories.UserRepository
}

func NewMessageService(
	repository *repositories.MessageRepository,
	chatRepository *repositories.ChatRepository,
	userRepository *repositories.UserRepository,
) *MessageService {
	return &MessageService{
		messageRepository: repository,
		chatRepository:    chatRepository,
		userRepository:    userRepository,
	}
}

func (service *MessageService) SendMessage(
	content string,
	senderId int,
	receptorId int,
) (*domain.Message, []firebase_entities.DeviceNotificationResult, error) {
	var chatId string

	if content == "" {
		return nil, nil, fmt.Errorf("The content cannot be empty")
	}

	senderUser, err := service.userRepository.FindOne("id", fmt.Sprint(senderId))
	if err != nil {
		return nil, nil, fmt.Errorf("Sender user not found")
	}

	receptorUser, err := service.userRepository.FindOne("id", fmt.Sprint(receptorId))
	if err != nil {
		return nil, nil, fmt.Errorf("Receptor user not found")
	}

	start := time.Now() 
	chatIdFound, err := service.chatRepository.FindChatByMembers(senderId, receptorId)
	elapsed := time.Since(start) 
	fmt.Printf("Tiempo transcurrido: %s\n", elapsed)
	if err != nil {
		createdChat, err := service.chatRepository.CreateChat(
			senderId, senderUser.Name, receptorId, receptorUser.Name)
		if err != nil {
			return nil, nil, fmt.Errorf("It is not possible to create a chat")
		}
		chatId = createdChat
	} else {
		chatId = chatIdFound
	}

	err = service.messageRepository.SendMessage(chatId, content, senderId, receptorId)
	if err != nil {
		return nil, nil, err
	}
	
	devices, err := service.userRepository.GetDevices(receptorUser.UserId)
	
	var notificationErrors []firebase_entities.DeviceNotificationResult
	if len(devices) > 0 {
		notificationErrors, err = service.messageRepository.NotifyDivices(
			devices,
			fmt.Sprintf("%s", senderUser.Name),
			content,
			senderId,
			receptorId,
			chatId,
		)
	}
	return &domain.Message{}, notificationErrors, nil
}

func (service *MessageService) ReadMessage(userId int, chatId string) error {
	return service.messageRepository.ReadMessage(userId, chatId)
}