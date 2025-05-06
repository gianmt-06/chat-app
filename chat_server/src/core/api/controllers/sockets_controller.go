package controllers

import (
	"fmt"
	"log"
	"net/http"
	"strings"
	"sync"

	"github.com/gorilla/websocket"
	"slices"
)

var (
	connections      = make(map[string]*websocket.Conn)
	chatsConnections = make(map[string][]string)
	connectionsMutex = sync.RWMutex{}
	chatsMutex       = sync.RWMutex{}
)

type SocketsController struct {
	upgrader websocket.Upgrader
	// service  *services.BiometricsService
}

func NewSocketsController( /*service *services.BiometricsService*/ ) *SocketsController {
	return &SocketsController{
		// service: service,
	}
}

func (controller *SocketsController) SetUpgrader(upgrader websocket.Upgrader) {
	controller.upgrader = upgrader
}

func (controller *SocketsController) SayHello(w http.ResponseWriter, r *http.Request) {
	c, err := controller.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()

	for {
		messageType, message, err := c.ReadMessage()
		if err != nil {
			log.Println("read:", err)
			break
		}
		fmt.Println(string(message))

		err = c.WriteMessage(messageType, fmt.Appendf(nil, "Server response: %s", message))
		if err != nil {
			log.Println("write:", err)
			break
		}
	}
}

func (controller *SocketsController) HandleConnection(w http.ResponseWriter, r *http.Request) {
	c, err := controller.upgrader.Upgrade(w, r, nil)
	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	defer c.Close()

	for {
		var msg map[string]any

		err := c.ReadJSON(&msg)
		if err != nil {
			log.Println("read:", err)
			break
		}

		switch msg["type"] {
		case "online":
			userId := msg["userId"].(string)

			connectionsMutex.Lock()
			connections[userId] = c
			log.Println("Usuario online:", userId)
			connectionsMutex.Unlock()

		case "chat":
			action := msg["action"].(string)
			userId := msg["userId"].(string)
			participantsKey := msg["participantsKey"].(string)

			if action == "hello" {
				fmt.Println("heatnssnaith")
				connectionsMutex.Lock()
				users := chatsConnections[participantsKey]
				alreadyExists := slices.Contains(users, userId)
				if !alreadyExists {
					chatsConnections[participantsKey] = append(users, userId)
				}
				// log.Println(chatsConnections[participantsKey])
				receptorId := strings.ReplaceAll(participantsKey, userId, "")
				receptorId = strings.ReplaceAll(receptorId, "_", "")
				
				anotherInChat := slices.Contains(users, receptorId)

				if anotherInChat {
					c.WriteJSON(map[string]bool{
						"inChat": true,
					})
				} else {
					c.WriteJSON(map[string]bool{
						"inChat": false,
					})
				}

				connectionsMutex.Unlock()

				sendTypingNotification(userId, participantsKey, map[string]bool{
					"inChat": true,
				})
			} else if action == "bye" {
				connectionsMutex.Lock()

				users := chatsConnections[participantsKey]
				filtered := make([]string, 0, len(users))

				for _, id := range users {
					if id != userId {
						filtered = append(filtered, id)
					}
				}

				chatsConnections[participantsKey] = filtered
				connectionsMutex.Unlock()

				sendTypingNotification(userId, participantsKey, map[string]bool{
					"inChat": false,
				})
			}

		case "typing":
			senderId := msg["userId"].(string)
			participantsKey := msg["participantsKey"].(string)

			sendTypingNotification(senderId, participantsKey, map[string]string{
				"typing": senderId,
			})
		default:
			log.Println("Tipo de mensaje no reconocido:", msg["type"])
		}
	}
}

func sendTypingNotification(senderId string, chatKey string, data any) {
	connectionsMutex.RLock()
	chatParticipants, ok := chatsConnections[chatKey]

	if ok {
		for _, userId := range chatParticipants {
			if userId != senderId {
				conn, exists := connections[userId]

				if exists {
					err := conn.WriteJSON(data)
					if err != nil {
						log.Printf("Error enviando a %s: %v\n", senderId, err)
					}
				}
			}
		}
	}
	connectionsMutex.RUnlock()
}
