package token_helpers

import (
	"chat_server/src/constants"
	"fmt"
	"time"

	"github.com/golang-jwt/jwt/v5"
)

type JwtManager struct {
	key []byte
}

func NewTokenManager() *JwtManager {
	return &JwtManager{
		key: []byte(constants.JWT_KEY),
	}
}

func (service *JwtManager) GetToken(tokenType string, uid int) (string, error) {
	expirationTime := time.Now().Add(time.Hour * 24 * 365).Unix()
	
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, 
		jwt.MapClaims{
			"uid": uid,
			"exp": expirationTime,
		},
	)

	sign, err := token.SignedString(service.key)
	if err != nil {
		return "", err
	}

	return sign, nil
}

func (service *JwtManager) ValidateToken(tokenString string) (int, error) {
	token, _ := jwt.Parse(tokenString, func(token *jwt.Token) (any, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, fmt.Errorf("signature error")
		}
		return service.key, nil
	})

	claims, ok := token.Claims.(jwt.MapClaims); 
	if !ok {
		return -1, fmt.Errorf("claims error")
	}

	if !token.Valid {
		return -1, fmt.Errorf("invalid token")
	}

	tokenClaim, ok := claims["uid"].(float64)

	if !ok {
		return -1, fmt.Errorf("no valid token")
	} 
	tokenInt := int(tokenClaim)
	return tokenInt, nil
}