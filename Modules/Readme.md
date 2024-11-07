         ___        ______     ____ _                 _  ___  
        / \ \      / / ___|   / ___| | ___  _   _  __| |/ _ \ 
       / _ \ \ /\ / /\___ \  | |   | |/ _ \| | | |/ _` | (_) |
      / ___ \ V  V /  ___) | | |___| | (_) | |_| | (_| |\__, |
     /_/   \_\_/\_/  |____/   \____|_|\___/ \__,_|\__,_|  /_/ 
 ----------------------------------------------------------------- 


Hi there! Welcome to Assignment1- ACS 730!


Project tructure:
.
├── Modules
│   ├── NonProd
│   │   ├── config.tf
│   │   ├── main.tf
│   │   ├── nonprod_key
│   │   ├── nonprod_key.pub
│   │   ├── output.tf
│   │   └── variables.tf
│   ├── Peering
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── terraform.tfstate
│   │   ├── terraform.tfstate.backup
│   │   └── variable.tf
│   ├── Prod
│   │   ├── config.tf
│   │   ├── main.tf
│   │   ├── output.tf
│   │   ├── prodkey
│   │   ├── prodkey.pub
│   │   └── variables.tf
│   ├── Readme.md
│   └── terraform.tfstate
└── README.md

Modules
NonProd: Contains configuration for the non-production environment.
Prod: Contains configuration for the production environment.
Peering: Contains configuration for VPC peering between non-production and production environments.


How to Apply The Modules

NonProd:
Initialize: terraform init
Validate: terraform validate
Plan: terraform plan
Apply: terraform apply

Prod:
Initialize: terraform init
Validate: terraform validate
Plan: terraform plan
Apply: terraform apply

Peering:
Initialize: terraform init
Validate: terraform validate
Plan: terraform plan
Apply: terraform apply

Testing the environment

Create Keys:

Generating SSH keys for non-production and production environments.

Copy keys to local machine and the bastion host.

Login to Bastion Host:
From the local machine, SSH into the bastion host.

Access Non-Prod VMs:
SSH into VM1 and VM2 in the non-production environment from the bastion host.
Use curl to test the web server on VM1 and VM2.

Access Prod VMs:
SSH into VM1 and VM2 in the production environment from the bastion host.
How to Destroy Infrastructure

Destroy Peering:
terraform destroy in the Peering module.

Destroy Prod:
terraform destroy in the Prod module.

Destroy NonProd:
terraform destroy in the NonProd module.

Conclusion
Succesful Deployment of a fully Automated multi-tier infrastructure using Terraform with best practices for network isolation for prod and non prod environments/
