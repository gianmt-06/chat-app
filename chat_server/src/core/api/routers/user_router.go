package routers

import (
	"chat_server/src/core/api/controllers"
	"chat_server/src/core/infrastructure/database"
	"chat_server/src/core/infrastructure/repositories"
	"chat_server/src/core/services"

	"github.com/gin-gonic/gin"
)

/* get user
+ token

- email

user - 200
*/

/* get users
+ token

users[] - 200
*/

type UserRouter struct {
	Path       string
	Controller *controllers.UserController
}

func NewUserRouter() *UserRouter {
	postgres := database.GetPostgresClient()
	userRepository := repositories.NewUserRepository(postgres)
	userService := services.NewUserService(userRepository)
	userController := controllers.NewUserController(userService)

	return &UserRouter{
		Path:       "users",
		Controller: userController,
	}
}

func (userRouter *UserRouter) Register(e *gin.Engine) {
	router := e.Group(userRouter.Path)

	router.GET("/ping", func(ctx *gin.Context) { ctx.JSON(200, "pong") })
	router.GET("/email/:email", userRouter.Controller.GetUserByEmail)
	router.GET("/id/:id", userRouter.Controller.GetUserById)
	router.GET("/", userRouter.Controller.GetAllUsers)
}
