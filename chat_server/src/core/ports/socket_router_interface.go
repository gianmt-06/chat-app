package ports

import "github.com/gorilla/websocket"

type SocketRouterInterface interface {
	Register(upgrader websocket.Upgrader)
}
