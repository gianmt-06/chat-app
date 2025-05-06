package database

import (
	"chat_server/src/constants"
	"fmt"
	"log"
	"sync"

	"github.com/minio/minio-go/v7"
	"github.com/minio/minio-go/v7/pkg/credentials"
)

var (
	onceBucket     sync.Once
	bucketInstance *BucketClient
)


type BucketClient struct {
	Client *minio.Client
}

func newBucketClient() *BucketClient {
	endpoint := fmt.Sprintf("%s:%s", constants.BUCKET_IP, constants.BUCKET_PORT)
	accessKeyID := constants.BUCKET_ACCES_KEY_ID
	secretAccessKey := constants.BUCKET_SECRET_ACCESS_KEY
	useSSL := false

	minioClient, err := minio.New(endpoint, &minio.Options{
		Creds:  credentials.NewStaticV4(accessKeyID, secretAccessKey, ""),
		Secure: useSSL,
	})
	if err != nil {
		log.Fatalln(err)
	}
	log.Printf("Conexión exitosa al bucket Minio")
	return &BucketClient{
		Client: minioClient,
	}
}

func GetBucketClient() *BucketClient {
	onceBucket.Do(func() {
		bucketInstance = newBucketClient()
	})
	return bucketInstance
}