package services

import (
	"chat_server/src/core/entities/domain"
	"chat_server/src/core/infrastructure/repositories"
	"chat_server/src/utils"
)

type UserService struct {
	repository *repositories.UserRepository
}

func NewUserService(repository *repositories.UserRepository) *UserService {
	return &UserService{
		repository: repository,
	}
}

func (service *UserService) GetUser(key string, value string) (*domain.User, error) {
	user, err := service.repository.FindOne(key, value)
	user.Picture = utils.GetProfilePicture(user.UserId)
	if err != nil {
		return nil, err
	}
	return user, nil
}

func (service *UserService) GetAllUsers() ([]*domain.User, error) {
	users, err := service.repository.GetAll()
	if err != nil {
		return nil, err
	}
	return users, nil
}
