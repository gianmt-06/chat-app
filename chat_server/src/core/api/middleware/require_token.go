package middleware

import (
	api_responses "chat_server/src/core/entities/api/responses"
	token_helpers "chat_server/src/helpers/token"
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
)


var (
	responseWrapper = api_responses.ResponseWrapper[bool]{}
	tokenManager = token_helpers.NewTokenManager()
)

func RequireToken() gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, 
				responseWrapper.ErrorResponse("no authorization header"))
			c.Abort()
			return
		}

		token := strings.TrimPrefix(authHeader, "Bearer ")
		if token == authHeader {
			c.JSON(http.StatusUnauthorized, 
				responseWrapper.ErrorResponse("no bearer"))
			c.Abort()
			return
		}

		tokenClaim, err := tokenManager.ValidateToken(token)
		if err != nil {
			print(err.Error())
			c.JSON(http.StatusUnauthorized,
				responseWrapper.ErrorResponse("token verification failed"))
			c.Abort()
			return
		}

		c.Set("uid", tokenClaim)
		c.Next()
	}
}
