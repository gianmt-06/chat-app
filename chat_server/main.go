package main

import (
	"chat_server/src/constants"
	"chat_server/src/core/api"
	"chat_server/src/core/api/routers"
	"chat_server/src/core/ports"
	"fmt"
)

func main()  {
	go func ()  { initHttpServer() }()
	go func () { initSocketServer() }()
	select {}
}

func initHttpServer(){
	fmt.Println("ChatApp - HTTP Server")
	server := api.NewHttpServer()

	authRouter := routers.NewAuthRouter()
	messagesRouter := routers.NewMessagesRouter()
	userRouter := routers.NewUserRouter()

	server.Register([]ports.RouterInterface{
		authRouter,
		messagesRouter,
		userRouter,
	})

	server.Listen(constants.HTTP_IP, constants.HTTP_PORT)
}

func initSocketServer(){
	fmt.Println("ChatApp - Socket Server")
	server := api.NewSocketServer()

	socketRouter := routers.NewSocketsRouter()

	server.Register([]ports.SocketRouterInterface{
		socketRouter,
	})

	server.Listen(constants.WEBSOCKETS_IP, constants.WEBSOCKETS_PORT)
}