package handlers

import (
	"io/ioutil"
	"net/http"
	"time"
)

func getAWSMetadata(path string) string {
	client := &http.Client{Timeout: 2 * time.Second}

	reqToken, _ := http.NewRequest("PUT", "http://169.254.169.254/latest/api/token", nil)
	reqToken.Header.Set("X-aws-ec2-metadata-token-ttl-seconds", "21600")
	
	respToken, err := client.Do(reqToken)
	if err != nil || respToken.StatusCode != 200 {
		return "not-aws-instance"
	}
	defer respToken.Body.Close()
	token, _ := ioutil.ReadAll(respToken.Body)

	reqMeta, _ := http.NewRequest("GET", "http://169.254.169.254/latest/meta-data/"+path, nil)
	reqMeta.Header.Set("X-aws-ec2-metadata-token", string(token))

	respMeta, err := client.Do(reqMeta)
	if err != nil || respMeta.StatusCode != 200 {
		return "unknown"
	}
	defer respMeta.Body.Close()
	data, _ := ioutil.ReadAll(respMeta.Body)

	return string(data)
}