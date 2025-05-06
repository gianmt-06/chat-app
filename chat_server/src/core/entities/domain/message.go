package domain

import "time"

type Message struct {
	ID        string
	Content   string
	SenderId  int
	ReceptorId  int
	Status    int
	Timestamp time.Time
}
