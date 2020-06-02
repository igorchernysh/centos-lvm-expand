output "public_ip" {
   value = aws_instance.ic_test_vm01.public_ip
}

output "ssh_command" {
   value = "ssh -i key_pair.pem ${var.ssh_user}@${aws_instance.ic_test_vm01.public_ip}"
}

