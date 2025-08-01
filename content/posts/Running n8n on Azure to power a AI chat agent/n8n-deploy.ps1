# Running n8n on Azure Container Apps with PostgreSQL
# Deploy n8n on Azure Container Apps following best practices from the n8n community.
# Uses Azure Database for PostgreSQL Flexible Server with proper security configuration
# Container is set to minimum 1 replica to keep n8n running continuously for workflow processing.
# Follows security best practices with VNet integration and restricted database access.

## 1. Variables - Pick a region and a few names

# Region close to me (Netherlands)
$LOCATION = "northeurope"

# Resource names (lightweight but persistent)
$RG        = "n8n"
$ENV_NAME  = "n8n-lite-env"
$APP_NAME  = "n8n-lite"
$VNET_NAME = "n8n-vnet"
$SUBNET_NAME = "n8n-subnet"
$POSTGRES_SUBNET_NAME = "postgres-subnet"

# PostgreSQL Flexible Server (required for n8n best practices)
$POSTGRES_SERVER = "n8n-postgres-$(Get-Random -Maximum 99999)"
$POSTGRES_DB = "n8n"
$POSTGRES_USER = "n8nadmin"

# Basic auth for n8n editor
$N8N_BASIC_USER = "admin"

# Generate a strong random password for PostgreSQL and a 32-byte hex encryption key
Add-Type -AssemblyName System.Security
$bytes = New-Object byte[] 32
[Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
$N8N_ENCRYPTION_KEY = ($bytes | ForEach-Object { $_.ToString("x2") }) -join ""

$chars = (48..57 + 65..90 + 97..122)
$N8N_BASIC_PASSWORD = -join (1..24 | ForEach-Object { [char]($chars | Get-Random) })
$POSTGRES_PASSWORD = -join (1..24 | ForEach-Object { [char]($chars | Get-Random) })

## 2. Resource group and secure networking

Write-Host "`nCreating resource group..." -ForegroundColor Cyan
az group create --name $RG --location $LOCATION | Out-Null

# Create VNet for secure communication (following best practices)
Write-Host "Creating secure virtual network..." -ForegroundColor Cyan
az network vnet create `
  --resource-group $RG `
  --name $VNET_NAME `
  --location $LOCATION `
  --address-prefixes 10.0.0.0/16 | Out-Null

# Create subnet for Container Apps
az network vnet subnet create `
  --resource-group $RG `
  --vnet-name $VNET_NAME `
  --name $SUBNET_NAME `
  --address-prefixes 10.0.0.0/23 | Out-Null

# Create separate subnet for PostgreSQL
az network vnet subnet create `
  --resource-group $RG `
  --vnet-name $VNET_NAME `
  --name $POSTGRES_SUBNET_NAME `
  --address-prefixes 10.0.2.0/24 | Out-Null

# Delegate Container Apps subnet
Write-Host "Delegating subnet to Container Apps..." -ForegroundColor Cyan
az network vnet subnet update `
  --resource-group $RG `
  --vnet-name $VNET_NAME `
  --name $SUBNET_NAME `
  --delegations Microsoft.App/environments | Out-Null

# Delegate PostgreSQL subnet
Write-Host "Delegating subnet to PostgreSQL..." -ForegroundColor Cyan
az network vnet subnet update `
  --resource-group $RG `
  --vnet-name $VNET_NAME `
  --name $POSTGRES_SUBNET_NAME `
  --delegations Microsoft.DBforPostgreSQL/flexibleServers | Out-Null

$SUBNET_ID = az network vnet subnet show `
  --resource-group $RG `
  --vnet-name $VNET_NAME `
  --name $SUBNET_NAME `
  --query id -o tsv

Write-Host "✓ Secure network created with separate delegated subnets" -ForegroundColor Green

## 3. Secure PostgreSQL database with VNet integration

Write-Host "`nCreating secure PostgreSQL Flexible Server..." -ForegroundColor Cyan

# Create PostgreSQL with VNet integration (secure, no public access)
az postgres flexible-server create `
  --resource-group $RG `
  --name $POSTGRES_SERVER `
  --location $LOCATION `
  --admin-user $POSTGRES_USER `
  --admin-password $POSTGRES_PASSWORD `
  --sku-name Standard_B1ms `
  --tier Burstable `
  --storage-size 32 `
  --version 14 `
  --vnet $VNET_NAME `
  --subnet $POSTGRES_SUBNET_NAME `
  --yes | Out-Null

# Create the n8n database
Write-Host "Creating n8n database..." -ForegroundColor Cyan
az postgres flexible-server db create `
  --resource-group $RG `
  --server-name $POSTGRES_SERVER `
  --database-name $POSTGRES_DB | Out-Null

Write-Host "✓ Secure PostgreSQL server created: $POSTGRES_SERVER" -ForegroundColor Green

## 4. Create Container Apps environment with VNet integration

Write-Host "`nCreating secure Container Apps environment..." -ForegroundColor Cyan
az containerapp env create `
  --resource-group $RG `
  --name $ENV_NAME `
  --location $LOCATION `
  --infrastructure-subnet-resource-id $SUBNET_ID `
  --logs-destination none | Out-Null

Write-Host "✓ Secure Container Apps environment created" -ForegroundColor Green

## 5. Deploy n8n with secure PostgreSQL connection

Write-Host "`nDeploying n8n container app..." -ForegroundColor Cyan

az containerapp create `
  --name $APP_NAME `
  --resource-group $RG `
  --environment $ENV_NAME `
  --image n8nio/n8n:latest `
  --ingress external --target-port 5678 `
  --cpu 1.0 --memory 2.0Gi `
  --min-replicas 1 --max-replicas 1 `
  --secrets `
      n8n-basic-password="$N8N_BASIC_PASSWORD" `
      n8n-encryption-key="$N8N_ENCRYPTION_KEY" `
      postgres-password="$POSTGRES_PASSWORD" `
  --env-vars `
      DB_TYPE=postgresdb `
      DB_POSTGRESDB_HOST="$POSTGRES_SERVER.postgres.database.azure.com" `
      DB_POSTGRESDB_PORT=5432 `
      DB_POSTGRESDB_DATABASE=$POSTGRES_DB `
      DB_POSTGRESDB_USER=$POSTGRES_USER `
      DB_POSTGRESDB_PASSWORD=secretref:postgres-password `
      DB_POSTGRESDB_SSL_REJECT_UNAUTHORIZED=false `
      DB_POSTGRESDB_CONNECTION_TIMEOUT=30000 `
      DB_POSTGRESDB_POOL_SIZE=5 `
      N8N_BASIC_AUTH_ACTIVE=true `
      N8N_BASIC_AUTH_USER=$N8N_BASIC_USER `
      N8N_BASIC_AUTH_PASSWORD=secretref:n8n-basic-password `
      N8N_ENCRYPTION_KEY=secretref:n8n-encryption-key `
      N8N_PROTOCOL=https `
      N8N_PORT=5678 `
      N8N_DIAGNOSTICS_ENABLED=false `
      N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true `
      GENERIC_TIMEZONE="Europe/Amsterdam" `
      TRUST_PROXY=true | Out-Null

Write-Host "✓ n8n container app deployed securely" -ForegroundColor Green

# Get the public hostname and configure webhook URLs
Write-Host "`nConfiguring webhooks..." -ForegroundColor Cyan
$APP_FQDN = az containerapp show `
  --resource-group $RG `
  --name $APP_NAME `
  --query "properties.configuration.ingress.fqdn" -o tsv

# Update webhook and host configuration
az containerapp update `
  --resource-group $RG `
  --name $APP_NAME `
  --set-env-vars WEBHOOK_URL="https://$APP_FQDN" N8N_HOST="$APP_FQDN" | Out-Null

Write-Host "✓ Webhook configuration complete" -ForegroundColor Green

# Final output
Write-Host "`n=== n8n Secure Deployment Complete ===" -ForegroundColor Green -BackgroundColor Black
Write-Host "`nn8n URL: https://$APP_FQDN" -ForegroundColor Cyan
Write-Host "Username: $N8N_BASIC_USER" -ForegroundColor Yellow
Write-Host "Password: $N8N_BASIC_PASSWORD" -ForegroundColor Yellow

Write-Host "`nPostgreSQL Details (Private Network):" -ForegroundColor Cyan
Write-Host "Server: $POSTGRES_SERVER.postgres.database.azure.com" -ForegroundColor Yellow
Write-Host "Database: $POSTGRES_DB" -ForegroundColor Yellow
Write-Host "User: $POSTGRES_USER" -ForegroundColor Yellow
Write-Host "Password: $POSTGRES_PASSWORD" -ForegroundColor Yellow

Write-Host "`nEstimated monthly cost:" -ForegroundColor Cyan
Write-Host "- Container Apps (1 vCPU, 2GB, 24/7): ~$35-45" -ForegroundColor Yellow
Write-Host "- PostgreSQL Flexible Server (Burstable B1ms): ~$25-30" -ForegroundColor Yellow
Write-Host "- VNet integration: ~$0 (included)" -ForegroundColor Yellow
Write-Host "- Total: ~$60-75/month" -ForegroundColor Yellow

Write-Host "`nSecurity Features:" -ForegroundColor Cyan
Write-Host "✓ PostgreSQL in private VNet (no public access)" -ForegroundColor Green
Write-Host "✓ Container Apps VNet integration" -ForegroundColor Green
Write-Host "✓ Private DNS zone for database" -ForegroundColor Green
Write-Host "✓ Always-on (min 1 replica) for workflow processing" -ForegroundColor Green
Write-Host "✓ Basic authentication enabled" -ForegroundColor Green
Write-Host "✓ HTTPS with free *.azurecontainerapps.io domain" -ForegroundColor Green
Write-Host "✓ Follows n8n community security best practices" -ForegroundColor Green

Write-Host "`nNext steps:" -ForegroundColor Cyan
Write-Host "1. Open the n8n URL above and log in" -ForegroundColor White
Write-Host "2. Create your first workflow" -ForegroundColor White
Write-Host "3. Set up webhooks using the provided URL" -ForegroundColor White