package utils

import (
	"chat_server/src/constants"
	"fmt"
)

func GetProfilePicture(uid int) string {
	return fmt.Sprintf(
		"http://%s:%s/%s/profile-pictures/%d%s",
		constants.BUCKET_IP, constants.BUCKET_PORT, constants.BUCKET_NAME, uid,
		".webp")
}
