terraform {
  required_version = ">= 0.12"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "null_resource" "generate_key_pair" {
  provisioner "local-exec" {
    command = "scripts\\create-key-pair.bat"
    interpreter = ["cmd.exe", "/c"]
  }
}

resource "null_resource" "cleanup_key_pair" {
  provisioner "local-exec" {
    when    = "destroy"
    command = "scripts\\delete-key-pair.bat"
    interpreter = ["cmd.exe", "/c"]
  }
}

resource "aws_security_group" "sg_allow_ssh" {
  name = "sg_allow_ssh"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "ic_test_vm01" {
  ami           = "ami-004b66801cc40a839"     # Bitnami Stacksmith Centos 7 Base Image
  instance_type = "t2.nano"

  associate_public_ip_address = true

  vpc_security_group_ids = [aws_security_group.sg_allow_ssh.id]

  ebs_block_device {
    device_name = "sdb"
    volume_size = 8
  }
  ebs_block_device {
    device_name = "sdc"
    volume_size = 8
  }
  ebs_block_device {
    device_name = "sdd"
    volume_size = 8
  }

  key_name = var.key_name

  tags = {
    Name = "ic_test_vm01"
  }

}

resource "null_resource" "lvm_demo" {
  triggers = {
    public_ip = aws_instance.ic_test_vm01.public_ip
  }

  connection {
    type  = "ssh"
    host  = aws_instance.ic_test_vm01.public_ip
    user  = var.ssh_user
    port  = var.ssh_port
    private_key = file("key_pair.pem")
  }

  # copy our example script to the server
  provisioner "file" {
    source      = "scripts\\lvm-demo.sh"
    destination = "/tmp/lvm-demo.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/lvm-demo.sh",
      "/tmp/lvm-demo.sh > /tmp/lvm-demo.log"
    ]
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no -i key_pair.pem ${var.ssh_user}@${aws_instance.ic_test_vm01.public_ip}:/tmp/lvm-demo.log lvm-demo.log"
  }
}
