package database

import (
	"context"
	"log"
	"sync"

	"cloud.google.com/go/firestore"
	firebase "firebase.google.com/go"
	"google.golang.org/api/option"
)

var (
	onceFirestore     sync.Once
	firestoreInstance *FirestorageClient
)

type FirestorageClient struct {
	Client *firestore.Client
}

func newFirestoreClient() *FirestorageClient {
	ctx := context.Background()
	sa := option.WithCredentialsFile("config/chat-app-d8ea0-firebase-adminsdk-fbsvc-0558f59fdb.json")
	app, err := firebase.NewApp(ctx, nil, sa)
	if err != nil {
		log.Fatalln(err)
	}

	client, err := app.Firestore(ctx)
	if err != nil {
		log.Fatalln(err)
	}

	return &FirestorageClient{
		Client: client,
	}
}

func GetFirestoreClient() *FirestorageClient {
	onceFirestore.Do(func() {
		firestoreInstance = newFirestoreClient()
	})
	return firestoreInstance
}
