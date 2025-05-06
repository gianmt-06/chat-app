package constants

var (
	BUCKET_IP   = env.GetEnvironmentVariable("BUCKET_IP")
	BUCKET_PORT = env.GetEnvironmentVariable("BUCKET_PORT")
	BUCKET_NAME = env.GetEnvironmentVariable("BUCKET_NAME")

	BUCKET_ACCES_KEY_ID      = env.GetEnvironmentVariable("BUCKET_ACCES_KEY_ID")
	BUCKET_SECRET_ACCESS_KEY = env.GetEnvironmentVariable("BUCKET_SECRET_ACCESS_KEY")
)
