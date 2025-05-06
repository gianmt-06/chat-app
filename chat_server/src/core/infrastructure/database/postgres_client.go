package database

import (
	"chat_server/src/constants"
	"database/sql"
	_ "github.com/lib/pq"
	"fmt"
	"log"
	"sync"
)

var (
	once     sync.Once
	instance *PostgressClient
)

type PostgressClient struct {
	Db *sql.DB
}

func newPostgressClient() *PostgressClient {
	connStr := fmt.Sprintf(
		"user=%s password=%s dbname=%s host=%s port=%d sslmode=disable",
		constants.DB_USER, constants.DB_PASSWORD, constants.DB_NAME, constants.DB_HOST, constants.DB_PORT,
	)
	var err error

	DB, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal("Error abriendo la base de datos:", err)
	}

	err = DB.Ping()
	if err != nil {
		log.Fatal("No se pudo conectar a la base de datos:", err)
	}
	log.Println("Conexión exitosa a PostgreSQL")

	return &PostgressClient{
		Db: DB,
	}
}

func GetPostgresClient() *PostgressClient {
	once.Do(func() {
		instance = newPostgressClient()
	})
	return instance
}
