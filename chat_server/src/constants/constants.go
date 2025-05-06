package constants

import (
	"chat_server/src/environment"
	"strconv"
)

var env = environment.GetEnv()

func criticalStrToInt(portStr string) int {
	port, err := strconv.Atoi(portStr)
	if err != nil {
		panic(err)
	}

	return port
}
