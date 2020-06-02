@@echo off
aws ec2 delete-key-pair --key-name key_pair
rem del /Q key_pair.pem