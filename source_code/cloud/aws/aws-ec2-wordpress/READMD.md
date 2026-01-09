# Steps to deploy

```bash

terraform init
terraform plan
terraform apply

terraform output -raw private_key > ec2-deployer-key.pem && chmod 400 ec2-deployer-key.pem
```
