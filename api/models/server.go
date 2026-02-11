package models

type ServerInfo struct {
	Hostname         string `json:"hostname"`
	PrivateIP        string `json:"private_ip"`
	InstanceID       string `json:"instance_id"`
	AvailabilityZone string `json:"availability_zone"`
	LocalHostname    string `json:"local_hostname"`
}