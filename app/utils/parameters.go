package utils

import (
	"context"
	"fmt"

	"github.com/aws/aws-sdk-go-v2/config"
	"github.com/aws/aws-sdk-go-v2/service/ssm"
)

const prefix = "/bookstore/aurora"

var client *ssm.Client

func init() {
	cfg, err := config.LoadDefaultConfig(context.TODO())
	Check(err)
	client = ssm.NewFromConfig(cfg)
}

type Parameters struct {
	AuroraUsername string
	AuroraPassword string
	AuroraEndpoint string
}

func GetParameters() Parameters {
	a := make([]string, 3)
	a[0] = fmt.Sprintf("%s/username", prefix)
	a[1] = fmt.Sprintf("%s/password", prefix)
	a[2] = fmt.Sprintf("%s/endpoint", prefix)
	input := &ssm.GetParametersInput{
		Names: a,
	}
	o, err := client.GetParameters(context.TODO(), input)
	Check(err)

	return Parameters{
		AuroraUsername: *o.Parameters[0].Value,
		AuroraPassword: *o.Parameters[1].Value,
		AuroraEndpoint: *o.Parameters[2].Value,
	}
}
