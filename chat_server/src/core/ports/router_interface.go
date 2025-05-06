package ports

import "github.com/gin-gonic/gin"

type RouterInterface interface {
    Register(engine *gin.Engine)
}