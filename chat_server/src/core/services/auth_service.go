package services

import (
	"chat_server/src/core/entities/domain"
	"chat_server/src/core/infrastructure/repositories"
	token_helpers "chat_server/src/helpers/token"
	"chat_server/src/utils"
	"fmt"
)

type AuthService struct {
	repository *repositories.UserRepository
}

func NewAuthService(repository *repositories.UserRepository) *AuthService {
	return &AuthService{
		repository: repository,
	}
}

func (service *AuthService) Register(user *domain.User) (*domain.User, error) {
	_, err := service.repository.FindOne("email", user.Email)
	if err == nil {
		return nil, fmt.Errorf("This email is already registered")
	}

	hashedPassword, err := utils.HashPassword(user.Password);
	if err != nil {
		return nil, fmt.Errorf("Hash pasword error")
	}

	user.Password = hashedPassword

	createdUser, err := service.repository.Save(user);
	if err != nil {
		return nil, err
	}

	return createdUser, nil
}

func (service *AuthService) LogIn(email string, password string, FCM string) (string, error) {
	
	user, err := service.repository.FindOne("email", email)
	if err != nil {
		return "", err
	}
	
	if !utils.CheckPasswordHash(password, user.Password) {
		return "", fmt.Errorf("invalid credentials")
	}
	
	tokenManager := token_helpers.NewTokenManager()
	token, err := tokenManager.GetToken("login", user.UserId)
	if err != nil {
		return "", fmt.Errorf("token generation error")
	}

	_, err = service.repository.AddDevice(user.UserId, FCM)
	if err != nil {
		return "", err
	}

	return token, nil
}