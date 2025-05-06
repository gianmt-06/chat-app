package api

import (
	"chat_server/src/core/ports"
	"fmt"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

type SocketServer struct {
	upgrader websocket.Upgrader
}

func NewSocketServer() *SocketServer {
	return &SocketServer{
		upgrader: websocket.Upgrader{},
	}
}

func (socketServer *SocketServer) Register(routers []ports.SocketRouterInterface) {
	for _, router := range routers {
		router.Register(socketServer.upgrader)
	}
}

func (socketServer *SocketServer) Listen(ip string, port int) {
	URL := fmt.Sprintf("%s:%d", ip, port) 
	log.Println(http.ListenAndServe(URL, nil))
}