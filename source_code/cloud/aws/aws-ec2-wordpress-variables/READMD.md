# Steps to deploy

```bash

terraform init
terraform plan
# if you have multiple terraform configuration files you run
terraform apply -var-file="terraform.tfvars" --auto-approve
# if there is just one
terraform apply --auto-approve

terraform output -raw private_key > ec2-deployer-key.pem && chmod 400 ec2-deployer-key.pem
```
