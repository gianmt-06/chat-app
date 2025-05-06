package domain

import "time"

type Chat struct {
	ID              string
	ParticipantsKey string
	LastMessage     string
	Participants    []int
	UpdatedAt       time.Time
}
