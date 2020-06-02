variable "key_name" {
    description = "Key pair for SSH login"
    default = "key_pair"
}

variable "ssh_user" {
    description = "SSH user"
    default = "centos"
}

variable "ssh_port" {
    description = "SSH port number"
    default = 22
}
