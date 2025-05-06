package domain

type User struct {
	UserId      int `json:"id"`
	Email       string `json:"email"`
	Password    string `json:"password"`
	Name        string `json:"name"`
	LastName    string `json:"lastName"`
	PhoneNumber string `json:"phoneNumber"`
	Rol         string `json:"rol"`
	Picture 	string `json:"picture"`
}
