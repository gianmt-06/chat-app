package routers

import (
	"chat_server/src/core/api/controllers"
	"net/http"

	"github.com/gorilla/websocket"
)

type SocketsRouter struct {
	controller *controllers.SocketsController
}

func NewSocketsRouter() *SocketsRouter{
	controller := controllers.NewSocketsController()
	return &SocketsRouter{
		controller: controller,
	}
}

func (router *SocketsRouter) Register(upgrader websocket.Upgrader){
	router.controller.SetUpgrader(upgrader)

	http.HandleFunc("/hello", router.controller.SayHello)
	http.HandleFunc("/register", router.controller.HandleConnection)
}
