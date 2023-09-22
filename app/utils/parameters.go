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
	ssmUsernameKey := fmt.Sprintf("%s/username", prefix)
	ssmPasswordKey := fmt.Sprintf("%s/password", prefix)
	ssmEndpointKey := fmt.Sprintf("%s/endpoint", prefix)

	a := make([]string, 3)
	a[0] = ssmUsernameKey
	a[1] = ssmPasswordKey
	a[2] = ssmEndpointKey

	withDecryption := true

	input := &ssm.GetParametersInput{
		Names:          a,
		WithDecryption: &withDecryption,
	}
	o, err := client.GetParameters(context.TODO(), input)
	Check(err)

	params := Parameters{}

	for _, p := range o.Parameters {
		switch os := *p.Name; os {
		case ssmUsernameKey:
			params.AuroraUsername = *p.Value
		case ssmPasswordKey:
			params.AuroraPassword = *p.Value
		case ssmEndpointKey:
			params.AuroraEndpoint = *p.Value
		default:
			msg := fmt.Sprintf("Switch failed %s", *p.Name)
			panic(msg)
		}
	}

	return params
}
