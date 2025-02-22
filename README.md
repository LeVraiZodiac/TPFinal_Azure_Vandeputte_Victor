
# Azure Web Application Infrastructure with Terraform

This repository contains Terraform configuration for deploying a comprehensive Azure infrastructure including web applications, application gateway, database, storage, and serverless functions.

## Architecture Overview

The infrastructure consists of:
- 2 Linux Web Apps with Node.js 20 LTS
- Application Gateway for load balancing
- SQL Server and Database
- Storage Account with containers, queues, and tables
- Python Function App for image processing
- Virtual Network configuration

## Prerequisites

- Terraform installed (version 1.0.0 or later)
- Azure CLI installed and configured
- Azure subscription with appropriate permissions
- Git installed (for source control integration)

## Infrastructure Components

### Web Applications
- Two Linux Web Apps running Node.js 20 LTS
- GitHub Actions integration for CI/CD
- Connected to the Application Gateway

### Networking
- Virtual Network (10.0.0.0/16)
- Frontend subnet (10.0.1.0/24)
- Application Gateway with HTTP listener
- Public IP for the gateway

### Database
- Azure SQL Server
- Basic tier database
- Azure AD administrator configuration
- 2GB maximum size

### Storage
- Storage Account with LRS replication
- Input and processed images containers
- Queue for image processing
- Table for processing history
- 14-day container deletion retention policy

### Serverless
- Python 3.9 Function App
- Connected to storage account
- Image processing capabilities

## Configuration

### Provider Configuration
```hcl
provider "azurerm" {
  features {}
  subscription_id = "cc39aed2-3c3a-4ee3-9b03-67b41165aba5"
}
```

### Resource Naming
All resources follow a consistent naming pattern with "my-final-" prefix:
- Resource Group: my-final-web-app-resource
- Web Apps: my-final-web-app, my-final-web-app-2
- SQL Server: my-final-sql-server
- Function App: my-final-function-app

## Deployment

1. Connect to Azure:
```bash
az login --scope https://management.core.windows.net//.default
```

2. Clone the repository:
```bash
git clone <repository-url>
```

3. Initialize Terraform:
```bash
terraform init --upgrade
```

4. Review the deployment plan:
```bash
terraform plan
```

5. Apply the configuration:
```bash
terraform validate
terraform apply
```

6. Create Registry
```bash
az acr create --resource-group my-final-web-app-resource --name myfinalregistry --sku Basic --location uksouth
az acr login --name myfinalregistry
```

7. Build Docker
```bash
docker build -t myfinalregistry.azurecr.io/image-processing docker/
docker push myfinalregistry.azurecr.io/image-processing
```

## GitHub Integration

The web applications are configured to deploy from:
- Repository: https://github.com/LeVraiZodiac/TPFinal_Azure_Vandeputte_Victor
- Branch: main
- Automatic GitHub Actions workflow generation

## Security Configuration

### SQL Server
- Administrator Username: sqladmin
- Azure AD Integration enabled
- Basic security features

### Storage
- Private blob containers
- Secure queue configuration
- Table storage for logging

## Outputs

The configuration provides several useful outputs:
```hcl
output "webapp_url"
output "webapp_url_2"
output "application_gateway_ip"
output "database_name"
```

To view outputs after deployment:
```bash
terraform output
```

## Resource Scaling

### Application Gateway
- SKU: Standard_v2
- Initial capacity: 2 instances
- Auto-scaling configuration available

### Web Apps
- Free tier (F1) service plan
- Node.js 20 LTS runtime
- Always-on disabled for cost optimization

## Monitoring and Management

### Application Gateway
- HTTP settings configured
- Cookie-based affinity disabled
- 60-second request timeout

### Storage
- Versioning disabled
- 14-day retention policy for deleted containers
- Standard performance tier

## Cleanup

To destroy all created resources:
```bash
terraform destroy
```

## Important Notes

- Free tier limitations apply to the service plan
- Database is configured with basic tier
- Storage account name must be globally unique
- Application Gateway requires Standard_v2 SKU
- Python function runs on version 3.9

## Troubleshooting

Common issues and solutions:
1. Name conflicts: Ensure unique storage account name
2. Permissions: Verify Azure credentials
3. Resource limits: Check subscription quotas
4. Deployment errors: Review terraform plan output
