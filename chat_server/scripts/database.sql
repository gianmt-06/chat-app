CREATE DATABASE chatapp;

CREATE USER chatadmin WITH PASSWORD 'password';

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    lastname VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    rol VARCHAR(50) NOT NULL
);

GRANT USAGE, SELECT, UPDATE ON SEQUENCE users_id_seq TO chatadmin;
ALTER DATABASE chatapp OWNER TO chatadmin;

CREATE TABLE devices (
    id SERIAL PRIMARY KEY,
    fcm_token TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE devices TO chatadmin;
GRANT USAGE, SELECT, UPDATE ON SEQUENCE devices_id_seq TO chatadmin;

CREATE TABLE user_devices (
    user_id INTEGER NOT NULL,
    device_id INTEGER NOT NULL,
    PRIMARY KEY (user_id, device_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (device_id) REFERENCES devices(id) ON DELETE CASCADE
);
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLE user_devices TO chatadmin;
