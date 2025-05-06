package controllers

import (
	"chat_server/src/constants"
	api_requests "chat_server/src/core/entities/api/requests"
	api_responses "chat_server/src/core/entities/api/responses"
	"chat_server/src/core/entities/domain"
	"chat_server/src/core/infrastructure/repositories"
	"chat_server/src/core/services"
	"fmt"
	"net/http"
	"path/filepath"

	"github.com/gin-gonic/gin"
)

type AuthController struct {
	Service         *services.AuthService
	userService     *services.UserService
	MediaRepository *repositories.MediaRepository
}

func NewAuthController(
	service *services.AuthService,
	userService *services.UserService,
	media *repositories.MediaRepository,

) *AuthController {
	return &AuthController{
		Service:         service,
		userService:     userService,
		MediaRepository: media,
	}
}

func (controller *AuthController) RegisterUser(c *gin.Context) {
	responseWrapper := api_responses.ResponseWrapper[api_responses.RegisterResponse]{}

	requestBody := &api_requests.UserRegisterRequest{
		Email:       c.PostForm("email"),
		Password:    c.PostForm("password"),
		Name:        c.PostForm("name"),
		LastName:    c.PostForm("lastName"),
		PhoneNumber: c.PostForm("phoneNumber"),
		Rol:         c.PostForm("rol"),
	}
	fileHeader, pictureErr := c.FormFile("profilePicture")

	registeredUser, err := controller.Service.Register(&domain.User{
		Email:       requestBody.Email,
		Password:    requestBody.Password,
		Name:        requestBody.Name,
		LastName:    requestBody.LastName,
		PhoneNumber: requestBody.PhoneNumber,
		Rol:         requestBody.Rol,
	})

	if err != nil {
		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse(err.Error()))
		c.Abort()
		return
	}

	if pictureErr == nil {
		file, err := fileHeader.Open()
		if err != nil {
			c.String(http.StatusInternalServerError, "no se pudo abrir el archivo")
			return
		}
		fileSize := fileHeader.Size

		controller.MediaRepository.UploadProfilePicture(
			fmt.Sprintf(
				"%d%s",
				registeredUser.UserId, filepath.Ext(fileHeader.Filename)),
			file, fileSize)

		defer file.Close()

		registeredUser.Picture = fmt.Sprintf(
			"http://%s:%s/%s/profile-pictures/%d%s",
			constants.BUCKET_IP, constants.BUCKET_PORT, constants.BUCKET_NAME, registeredUser.UserId,
			filepath.Ext(fileHeader.Filename))
	} else {
		registeredUser.Picture = fmt.Sprintf(
			"http://%s:%s/%s/profile-pictures/eldoc.jpg",
			constants.BUCKET_IP, constants.BUCKET_PORT, constants.BUCKET_NAME,
		)
	}

	c.JSON(http.StatusCreated,
		responseWrapper.SuccessResponse(
			"user successfully registered",
			&api_responses.RegisterResponse{
				User: *registeredUser,
			},
		))
}

func (controller *AuthController) Login(c *gin.Context) {
	var requestBody api_requests.LoginRequest
	responseWrapper := api_responses.ResponseWrapper[api_responses.LoginResponse]{}

	if err := c.ShouldBindJSON(&requestBody); err != nil {
		c.JSON(http.StatusBadRequest,
			responseWrapper.ErrorResponse("all attributes are required"))
		c.Abort()
		return
	}

	token, err := controller.Service.LogIn(requestBody.Email, requestBody.Password, requestBody.TCM)

	if err != nil {
		if err.Error() == "invalid credentials" || err.Error() == "Error: user not found" {
			c.JSON(http.StatusUnauthorized,
				responseWrapper.ErrorResponse("invalid credentials"),
			)
		} else {
			fmt.Println(err)
			c.JSON(http.StatusInternalServerError,
				responseWrapper.ErrorResponse("server error"),
			)
		}
		c.Abort()
		return
	}

	user, _ := controller.userService.GetUser("email", requestBody.Email)

	c.JSON(http.StatusOK,
		responseWrapper.SuccessResponse(
			"user successfully authenticated",
			&api_responses.LoginResponse{
				JWT: token,
				User: user,
			},
		))
}
