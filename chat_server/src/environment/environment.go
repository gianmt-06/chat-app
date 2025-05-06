package environment

import (
	"log"
	"os"
	"sync"

	"github.com/joho/godotenv"
)

var (
	once sync.Once
	instance *Environment
)

type Environment struct {
}

func newEnv() *Environment {
	err := godotenv.Load("env/.development.env")
    
    if err != nil {
        log.Fatal("Error loading .env file")
    }

	return &Environment{}
}

func (env *Environment) GetEnvironmentVariable(variableName string) string {
	return os.Getenv(variableName)
}

func GetEnv() *Environment {
	once.Do(func() {
		instance = newEnv()
	})
	return instance
}