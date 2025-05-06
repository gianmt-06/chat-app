package controllers

import (
	api_requests "chat_server/src/core/entities/api/requests"
	api_responses "chat_server/src/core/entities/api/responses"
	"chat_server/src/core/services"
	"fmt"
	"net/http"

	"github.com/gin-gonic/gin"
)

type MessageController struct {
	service *services.MessageService
}

func NewMessageController(service *services.MessageService) *MessageController {
	return &MessageController{
		service: service,
	}
}

func (controller *MessageController) SendMessage(c *gin.Context) {
	uid, _ := c.Get("uid")
	senderId, _ := uid.(int)

	var requestBody api_requests.SendMessageRequest
	responseWrapper := api_responses.ResponseWrapper[api_responses.SendMessageResponse]{}

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse("all attributes are required"))
		c.Abort()
		return
	}

	sentMessage, notificationErrors, err := controller.service.SendMessage(
		requestBody.Content, 
		senderId, 
		requestBody.ReceptorId,
	)
	if err != nil {
		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse(err.Error()))
		return
	}

	response := &api_responses.SendMessageResponse{
		Message: *sentMessage,
		NotificationsErrors: notificationErrors,
	}

	c.JSON(http.StatusOK,
		responseWrapper.SuccessResponse("message sent successfully", response))
}

func (controller *MessageController) ReadMessage(c *gin.Context) {
	responseWrapper := api_responses.ResponseWrapper[bool]{}

	uid, _ := c.Get("uid")
	userId, _ := uid.(int)

	chatId := c.Param("key")

	if chatId == "" {
		fmt.Println("no chat id")

		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse("'chat id' parameter is required"))
		return
	}

	err := controller.service.ReadMessage(userId, chatId)

	if err != nil {
		fmt.Println(err.Error())

		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse(err.Error()))
	}

	value := true
	c.JSON(http.StatusOK,
		responseWrapper.SuccessResponse("ok", &value))
}