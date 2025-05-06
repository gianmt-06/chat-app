package constants

var (
	HTTP_IP   = env.GetEnvironmentVariable("HTTP_IP")
	HTTP_PORT = criticalStrToInt(env.GetEnvironmentVariable("HTTP_PORT"))

	WEBSOCKETS_IP   = env.GetEnvironmentVariable("WEBSOCKETS_IP")
	WEBSOCKETS_PORT = criticalStrToInt(env.GetEnvironmentVariable("WEBSOCKETS_PORT"))
)