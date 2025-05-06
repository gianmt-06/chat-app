package routers

import (
	"chat_server/src/core/api/controllers"
	"chat_server/src/core/infrastructure/database"
	"chat_server/src/core/infrastructure/repositories"
	"chat_server/src/core/services"

	"github.com/gin-gonic/gin"
)

/* logout
- jwt

200
*/

/* register

- email (id)
- password
- profile_picture
- name
- phone
- rol

true
*/

/* login

- email
- password
- FCM Token

jwt - 200
*/

type AuthRouter struct {
	Path string
	Controller *controllers.AuthController
}

func NewAuthRouter() *AuthRouter {
	postgres := database.GetPostgresClient()
	userRepository := repositories.NewUserRepository(postgres)
	authService := services.NewAuthService(userRepository)
	userService := services.NewUserService(userRepository)

	bucket := database.GetBucketClient()
	mediaRepository := repositories.NewMediaRepository(bucket)

	authController := controllers.NewAuthController(authService, userService, mediaRepository)

	return &AuthRouter{
		Path: "auth",
		Controller: authController,
	}
}

func (authRouter *AuthRouter) Register(e *gin.Engine) {
	router := e.Group(authRouter.Path)

	router.GET("/ping", func(ctx *gin.Context) { ctx.JSON(200, "pong")})
	router.POST("/register", authRouter.Controller.RegisterUser)
	router.POST("/login", authRouter.Controller.Login)
	// router.POST("/logout", authRouter.Controller.Login)
}