package handlers

import (
	"context"
	"io"
	"net/http"
	"time"
)

var metadataClient = &http.Client{
	Timeout: 2 * time.Second,
}

func getAWSMetadata(path string) string {
	ctx, cancel := context.WithTimeout(context.Background(), 2*time.Second)
	defer cancel()

	reqToken, err := http.NewRequestWithContext(ctx, "PUT", "http://169.254.169.254/latest/api/token", nil)
	if err != nil {
		return "unknown"
	}
	reqToken.Header.Set("X-aws-ec2-metadata-token-ttl-seconds", "21600")

	respToken, err := metadataClient.Do(reqToken)
	if err != nil || respToken.StatusCode != 200 {
		return "not-aws-instance"
	}
	defer respToken.Body.Close()
	token, _ := io.ReadAll(respToken.Body)

	reqMeta, err := http.NewRequestWithContext(ctx, "GET", "http://169.254.169.254/latest/meta-data/"+path, nil)
	if err != nil {
		return "unknown"
	}
	reqMeta.Header.Set("X-aws-ec2-metadata-token", string(token))

	respMeta, err := metadataClient.Do(reqMeta)
	if err != nil || respMeta.StatusCode != 200 {
		return "unknown"
	}
	defer respMeta.Body.Close()
	data, _ := io.ReadAll(respMeta.Body)

	return string(data)
}