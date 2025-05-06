package routers

import (
	"chat_server/src/core/api/controllers"
	"chat_server/src/core/api/middleware"
	"chat_server/src/core/infrastructure/database"
	"chat_server/src/core/infrastructure/repositories"
	"chat_server/src/core/services"

	"github.com/gin-gonic/gin"
)

/* send message
+ token

- sender_id
- receptor_id
- text
- timestamp

true - 200
*/

/* get single chat  X -> Firestore
+ token

- chat_id

chat - 200
*/

/* user chat list   X -> Firestore
+ token

- user_email

chats[] - 200
*/

type MessagesRouter struct {
	Path string
	Controller *controllers.MessageController
}

func NewMessagesRouter() *MessagesRouter {

	firestoreClient := database.GetFirestoreClient()
	postgres := database.GetPostgresClient()
	messagesRepository := repositories.NewMessageRepository(firestoreClient)
	chatRepository := repositories.NewChatRepository(firestoreClient)
	userRepository := repositories.NewUserRepository(postgres)

	messagesService := services.NewMessageService(messagesRepository, chatRepository, userRepository)
	messagesController := controllers.NewMessageController(messagesService)
	
	return &MessagesRouter{
		Path: "messages",
		Controller: messagesController,
	}
}

func (messagesRouter *MessagesRouter) Register(e *gin.Engine) {
	router := e.Group(messagesRouter.Path)

	router.GET("/ping", func(ctx *gin.Context) { ctx.JSON(200, "pong")})
	router.POST("/send", middleware.RequireToken(), messagesRouter.Controller.SendMessage)
	router.POST("/read/:key", middleware.RequireToken(), messagesRouter.Controller.ReadMessage) 
}