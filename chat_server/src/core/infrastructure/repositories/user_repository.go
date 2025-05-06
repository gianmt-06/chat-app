package repositories

import (
	"chat_server/src/core/entities/domain"
	"chat_server/src/core/infrastructure/database"
	"chat_server/src/utils"
	"database/sql"
	"fmt"
)

type UserRepository struct {
	Database *database.PostgressClient
}

func NewUserRepository(database *database.PostgressClient) *UserRepository {
	return &UserRepository{
		Database: database,
	}
}

func (repository *UserRepository) FindOne(key string, value string) (*domain.User, error) {
	query := fmt.Sprintf(
		`SELECT id, email, password, name, lastname, phone, rol FROM users WHERE %s = $1 LIMIT 1;`,
		key)

	row := repository.Database.Db.QueryRow(query, value)

	var uid int
	var userEmail, password, name, lastName, phoneNumber, rol string

	err := row.Scan(&uid, &userEmail, &password, &name, &lastName, &phoneNumber, &rol)
	if err != nil {
		if err == sql.ErrNoRows {
			return nil, fmt.Errorf("Error: user not found")
		}
		return nil, err
	}

	return &domain.User{
		UserId:      uid,
		Email:       userEmail,
		Password:    password,
		Name:        name,
		LastName:    lastName,
		PhoneNumber: phoneNumber,
		Rol:         rol,
	}, nil
}

func (repository *UserRepository) Save(user *domain.User) (*domain.User, error) {
	query := `
		INSERT INTO users (email, password, name, lastname, phone, rol)
		VALUES ($1, $2, $3, $4, $5, $6)
		RETURNING id;
	`

	var userID int
	err := repository.Database.Db.QueryRow(
		query,
		user.Email, user.Password, user.Name, user.LastName, user.PhoneNumber, user.Rol,
	).Scan(&userID)

	if err != nil {
		return nil, fmt.Errorf("Error registering user: %v", err)
	}

	return &domain.User{
		UserId:      userID,
		Email:       user.Email,
		Name:        user.Name,
		LastName:    user.LastName,
		PhoneNumber: user.PhoneNumber,
		Rol:         user.Rol,
	}, nil
}

func (repository *UserRepository) GetAll() ([]*domain.User, error) {
	query := `SELECT id, email, name, lastname, phone, rol FROM users;`

	rows, err := repository.Database.Db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var users []*domain.User

	for rows.Next() {
		var uid int
		var userEmail, name, lastName, phoneNumber, rol string

		err := rows.Scan(&uid, &userEmail, &name, &lastName, &phoneNumber, &rol)
		if err != nil {
			return nil, err
		}

		user := &domain.User{
			UserId:      uid,
			Email:       userEmail,
			Name:        name,
			LastName:    lastName,
			PhoneNumber: phoneNumber,
			Rol:         rol,
			Picture:     utils.GetProfilePicture(uid),
		}

		users = append(users, user)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return users, nil
}

func (repository *UserRepository) FindDevice(fcm string) (int, error) {
	query := `SELECT id FROM devices WHERE fcm_token = $1;`

	var id int
	err := repository.Database.Db.QueryRow(query, fcm).Scan(&id)

	if err != nil {
		if err == sql.ErrNoRows {
			return -1, err
		}
		return -1, err
	}

	return id, nil
}

func (repository *UserRepository) AddDevice(uid int, fcm string) (bool, error) {
	removeDeviceQuery := `
	DELETE FROM devices
	WHERE id IN (
	  SELECT d.id
	  FROM devices d
	  LEFT JOIN user_devices ud ON d.id = ud.device_id
	  WHERE d.fcm_token = $1 AND ud.user_id IS DISTINCT FROM $2
	);
	`
	_, err := repository.Database.Db.Exec(removeDeviceQuery, fcm, uid)
	if err != nil {
		return false, fmt.Errorf("error deleting devices: %v", err)
	}

	deviceId, err := repository.FindDevice(fcm)
	if err != nil {
		addDeviceQuery := `INSERT INTO devices (fcm_token) VALUES ($1) RETURNING id;`

		err := repository.Database.Db.QueryRow(addDeviceQuery, fcm).Scan(&deviceId)
		if err != nil {
			return false, err
		}
	}

	asignDeviceToUserQuery := `
		INSERT INTO user_devices (user_id, device_id) 
		VALUES ($1, $2) 
		ON CONFLICT DO NOTHING;
	`
	_, err = repository.Database.Db.Exec(asignDeviceToUserQuery, uid, deviceId)
	if err != nil {
		return false, err
	}
	return true, nil
}

func (repository *UserRepository) GetDevices(uid int) ([]string, error) {
	query := `
		SELECT d.fcm_token
		FROM devices d
		INNER JOIN user_devices ud ON d.id = ud.device_id
		WHERE ud.user_id = $1;
	`

	rows, err := repository.Database.Db.Query(query, uid)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var devices []string
	for rows.Next() {
		var token string
		if err := rows.Scan(&token); err != nil {
			return nil, err
		}
		devices = append(devices, token)
	}

	if err = rows.Err(); err != nil {
		return nil, err
	}

	return devices, nil
}
