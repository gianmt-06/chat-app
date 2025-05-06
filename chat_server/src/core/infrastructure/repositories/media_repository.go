package repositories

import (
	"chat_server/src/constants"
	"chat_server/src/core/infrastructure/database"
	"context"
	"fmt"
	"log"
	"mime/multipart"
	"path/filepath"
	"strings"

	"github.com/minio/minio-go/v7"
)

type MediaRepository struct {
	Bucket *database.BucketClient
}

func NewMediaRepository(bucket *database.BucketClient) *MediaRepository {
	return &MediaRepository{
		Bucket: bucket,
	}
}

func (repository *MediaRepository) UploadProfilePicture(name string, file multipart.File, size int64) {
	minioClient := repository.Bucket.Client
	ctx := context.Background()
	bucketName := constants.BUCKET_NAME

	err := minioClient.MakeBucket(ctx, bucketName, minio.MakeBucketOptions{})
	if err != nil {
		exists, errBucketExists := minioClient.BucketExists(ctx, bucketName)
		if errBucketExists == nil && exists {
			log.Printf("We already own %s\n", bucketName)
		} else {
			log.Fatalln(err)
		}
	} else {
		log.Printf("Successfully created %s\n", bucketName)
	}

	objectName := fmt.Sprintf("profile-pictures/%s", name)
	ext := filepath.Ext(name)                
	cleanExt := strings.TrimPrefix(ext, ".") 

	contentType := fmt.Sprintf("image/%s", cleanExt)

	info, err := minioClient.PutObject(
		ctx, bucketName, objectName, file, size,
		minio.PutObjectOptions{ContentType: contentType})
	if err != nil {
		log.Fatalln(err)
	}

	log.Printf("Successfully uploaded %s of size %d\n", objectName, info.Size)
}
