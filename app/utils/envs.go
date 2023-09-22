package utils

import (
	"os"
	"strconv"
)

func GetPort() int {
	env := os.Getenv("PORT")
	if len(env) == 0 {
		return 8080
	}
	p, err := strconv.Atoi(env)
	Check(err)
	return p
}
