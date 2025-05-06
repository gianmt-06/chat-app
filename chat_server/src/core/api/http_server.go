package api

import (
	"chat_server/src/core/ports"
	"fmt"

	"github.com/gin-gonic/gin"
)

type HttpServer struct {
	Engine *gin.Engine
}

func NewHttpServer() *HttpServer {
	return &HttpServer{
		Engine: gin.Default(),
	}
}

func (server *HttpServer) Register(routers []ports.RouterInterface){
	for _, router := range routers {
		router.Register(server.Engine)
	}
}

func (server *HttpServer) Listen(ip string, port int) {
	address := fmt.Sprintf("%s:%d", ip, port) 
	server.Engine.Run(address)
}