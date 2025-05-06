package controllers

import (
	api_responses "chat_server/src/core/entities/api/responses"
	"chat_server/src/core/entities/domain"
	"chat_server/src/core/services"
	"net/http"

	"github.com/gin-gonic/gin"
)

type UserController struct {
	Service *services.UserService
}

func NewUserController(service *services.UserService) *UserController {
	return &UserController{
		Service: service,
	}
}

func (controller *UserController) GetUserByEmail(c *gin.Context) {
	email := c.Param("email")
	controller.getUser("email", email, c)
}

func (controller *UserController) GetUserById(c *gin.Context) {
	id := c.Param("id")
	controller.getUser("id", id, c)
}

func (controller *UserController) GetAllUsers(c *gin.Context) {
	responseWrapper := api_responses.ResponseWrapper[[]*domain.User]{}

	users, err := controller.Service.GetAllUsers()
	if err != nil {
		c.JSON(http.StatusInternalServerError,
			responseWrapper.ErrorResponse("internal server error"))
		return
	}

	c.JSON(http.StatusOK,
		responseWrapper.SuccessResponse("users successfully obtained", &users))
}

func (controller *UserController) getUser(key string, value string, c *gin.Context) {
	responseWrapper := api_responses.ResponseWrapper[domain.User]{}

	if value == "" {
		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse("'email' parameter is required"))
		return
	}

	user, err := controller.Service.GetUser(key, value)
	if err != nil {
		switch err.Error() {
		case "Error: user not found":
			c.JSON(http.StatusNotFound,
				responseWrapper.ErrorResponse("user not found"))
		default:
			c.JSON(http.StatusInternalServerError,
				responseWrapper.ErrorResponse("internal server error"))
		}
		return
	}
	user.Password = ""

	c.JSON(http.StatusOK,
		responseWrapper.SuccessResponse("user successfully obtained", user))
}
