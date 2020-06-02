@@echo off
aws ec2 create-key-pair --key-name key_pair --query KeyMaterial --output text > key_pair.pem
