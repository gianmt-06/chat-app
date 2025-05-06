package constants

var (
	DB_USER     = env.GetEnvironmentVariable("DB_USER")
	DB_NAME     = env.GetEnvironmentVariable("DB_NAME")
	DB_PASSWORD = env.GetEnvironmentVariable("DB_PASSWORD")
	DB_HOST     = env.GetEnvironmentVariable("DB_HOST")
	DB_PORT     = criticalStrToInt(env.GetEnvironmentVariable("DB_PORT"))
)
