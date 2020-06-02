## Demo - how to expand LVM volume with ext4 filesystem in CentOS online.

Live demo to illustrate how ext4 LVM volume can be resized (up) online, without service disruption. What it does, in essence:
- create CentOS VM on AWS with 3 extra EBS disks
- install LVM2 package
- create GPT partition on each EBS disk
- create an LVM logical volume composed of 2 EBS disks with size 5 GB
- format logical volume with ext4 and mount to /data01
- add 3rd EBS disk to the volume group
- expand logical volume to use all available space from the volume group (23 GB)
- perform online expansion of /data01 from 5 GB to 23 GB
- fetch output of CentOS commands as file lvm-demo.log locally
- delete all AWS objects to stop the charges

### Pre-requisites:

* Terraform on Windows

  Provided Terraform code was meant to be executed on Windows (provisioner "local-exec" and scripts explicitely use cmd.exe).
  
  [Download and install Terraform on Windows](https://www.terraform.io/downloads.html)
  
  To verify installation:
  ```
  terraform version
  ```
* AWS account:
  - AWS IAM account with admin privileges
  - [Install AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
  - Configure AWS CLI for region "us-east-1" and default profile.
  
    Verification:
    ```
    aws configure get region
    ```
* [Install OpenSSH for Windows](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)

  Verification:
  ```
  where ssh.exe
  
  where scp.exe
  ```

### Usage:

1. Initialize Terraform - get dependencies:
   ```
   terraform init
   ```

2. Create Terraform plan:
   ```
   terraform plan --out=main.tfplan
   ```

3. Run the demo:
   ```
   terraform apply "main.tfplan"
   ```
   Check the last line of output, something like this:
   ```
   ssh_command = ssh -i key_pair.pem centos@3.90.85.29
   ```
   , you can use that command to ssh to created VM and inspect results of the demo in CentOS
   
4. Cleanup, to stop AWS charges:
   ```
   terraform destroy -auto-approve
   ```

5. Inspect lvm-demo.log - output of CentOS commands performing demo steps.
