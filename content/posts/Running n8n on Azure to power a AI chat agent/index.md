---
title: "Running n8n on Azure to power a AI chat agent"
author: "Clemens Schotte"
date: 2025-07-30

tags: ["Azure", "AI", "n8n"]
categories: ["AI"]

resources:
- name: "featured-image"
  src: "featured-image.jpg"

draft: false

---

## A lightweight Azure backend for my AI agent

Over the past few weeks, I’ve been exploring different ways to power a personal AI agent for my blog, one that can answer questions about me, my background, and my work using context I provide. I wanted a simple, secure, and cost-effective backend that I fully control and can iterate on fast.

**n8n** is a powerful open-source automation tool that’s perfect for wiring together APIs and logic without having to spin up tons of infrastructure. 

But first, I needed to get n8n up and running on Azure.

This blog post documents exactly how I did it: deploying n8n on **Azure Container Apps**, connecting it securely to Azure Database for **PostgreSQL** Flexible Server, and setting everything up to follow best practices like private networking, basic auth, encryption, and persistent workflows.

## What you’ll need

Before I could start stitching together containers and databases, I needed to make sure my local environment was ready. For me, that meant working from my Windows machine using PowerShell (my go-to shell for anything Azure-related). I wanted this setup to be clean, repeatable, and fully self-contained, without depending on extra tooling or scripts from elsewhere.

The goal was to keep things simple but robust. With just a few PowerShell commands and the Azure CLI, I’d provision a complete backend in the cloud that felt lightweight yet production-grade.

At the core of this setup is a single Azure Container App running the official `n8nio/n8n` image. It’s backed by a PostgreSQL Flexible Server that lives securely inside a private VNet. Every connection is internal. Every service knows its place. Nothing is exposed unless I want it to be.

If you’re ready to follow along, all you really need is an updated Azure CLI, the Container Apps extension, and a PowerShell window. That’s where we begin:

```powershell
az upgrade --yes
az extension add --name containerapp --upgrade
az login
az account set --subscription "<YOUR_SUBSCRIPTION_ID_OR_NAME>"
```

## 1. Define your variables

This code defines all the values we’ll use: region, resource names, credentials, and secrets. Random values are generated for passwords and encryption keys so you never have to hardcode them.

```powershell
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
```

## 2. Provision secure networking

We’ll create a virtual network and two subnets: one for Container Apps and one for PostgreSQL. Each is delegated to the correct Azure service for secure, private communication.

```powershell
Write-Host "`nCreating resource group..." -ForegroundColor Cyan
az group create --name $RG --location $LOCATION | Out-Null

# Create VNet for secure communication (following best practices)
Write-Host "Creating secure virtual network..." -ForegroundColor Cyan
az network vnet create --resource-group $RG --name $VNET_NAME --location $LOCATION --address-prefixes 10.0.0.0/16 | Out-Null

# Create subnet for Container Apps
az network vnet subnet create --resource-group $RG --vnet-name $VNET_NAME --name $SUBNET_NAME --address-prefixes 10.0.0.0/23 | Out-Null

# Create separate subnet for PostgreSQL
az network vnet subnet create --resource-group $RG --vnet-name $VNET_NAME --name $POSTGRES_SUBNET_NAME --address-prefixes 10.0.2.0/24 | Out-Null

# Delegate Container Apps subnet
Write-Host "Delegating subnet to Container Apps..." -ForegroundColor Cyan
az network vnet subnet update --resource-group $RG --vnet-name $VNET_NAME --name $SUBNET_NAME --delegations Microsoft.App/environments | Out-Null

# Delegate PostgreSQL subnet
Write-Host "Delegating subnet to PostgreSQL..." -ForegroundColor Cyan
az network vnet subnet update --resource-group $RG --vnet-name $VNET_NAME --name $POSTGRES_SUBNET_NAME --delegations Microsoft.DBforPostgreSQL/flexibleServers | Out-Null

$SUBNET_ID = az network vnet subnet show --resource-group $RG --vnet-name $VNET_NAME --name $SUBNET_NAME --query id -o tsv

Write-Host "✓ Secure network created with separate delegated subnets" -ForegroundColor Green
```

## 3. Create a secure PostgreSQL server

n8n officially recommends PostgreSQL for production. Here we deploy a private Flexible Server inside the delegated subnet. No public access, no internet exposure.

```powershell
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
```

## 4. Set up the Container Apps environment

Azure Container Apps supports full VNet integration, great for security and compliance. I disable Log Analytics to save costs and keep things simple.

```powershell
Write-Host "`nCreating secure Container Apps environment..." -ForegroundColor Cyan
az containerapp env create `
  --resource-group $RG `
  --name $ENV_NAME `
  --location $LOCATION `
  --infrastructure-subnet-resource-id $SUBNET_ID `
  --logs-destination none | Out-Null

Write-Host "✓ Secure Container Apps environment created" -ForegroundColor Green
```

## 5. Deploy the n8n container

This is where it all comes together. We deploy the latest n8n image and configure all secrets and environment variables, including:	Basic auth credentials, PostgreSQL connection string, Encryption key, TLS (automatically provided by Azure) and 	Static scaling (1 replica)

```powershell
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
```

## 6. Configure webhooks and URL

After deployment, we extract the public FQDN and configure n8n’s internal variables like WEBHOOK_URL and N8N_HOST.

```powershell
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
```

## 7. Final output and login details

Summary of everything you need to access and manage the n8n instance, including login credentials.

```powershell
Write-Host "`n=== n8n Secure Deployment Complete ===" -ForegroundColor Green -BackgroundColor Black
Write-Host "`nn8n URL: https://$APP_FQDN" -ForegroundColor Cyan
Write-Host "Username: $N8N_BASIC_USER" -ForegroundColor Yellow
Write-Host "Password: $N8N_BASIC_PASSWORD" -ForegroundColor Yellow

Write-Host "`nPostgreSQL Details (Private Network):" -ForegroundColor Cyan
Write-Host "Server: $POSTGRES_SERVER.postgres.database.azure.com" -ForegroundColor Yellow
Write-Host "Database: $POSTGRES_DB" -ForegroundColor Yellow
Write-Host "User: $POSTGRES_USER" -ForegroundColor Yellow
Write-Host "Password: $POSTGRES_PASSWORD" -ForegroundColor Yellow
```

In the Azure Portal it looks like this:

![Infra n8n](infra.png)

## Connecting my AI chat agent to n8n

At this point in the setup, I finally had what I needed: a secure, self-hosted instance of n8n, always-on, neatly tucked into a private Azure network, and ready to receive input. But this wasn’t just about deploying a container or setting up PostgreSQL correctly. I was building the backend for something more personal, an intelligent agent that could talk to visitors on my blog, understand who I am, what I’ve worked on, and respond as if it were me.

That’s the vision behind **ClemensGPT**.

Inside n8n, it all starts with a workflow triggered by a webhook. This is the entry point, the moment someone on my website types a message into the chat box, and the request flows through the cloud, landing inside my n8n container. From there, the magic begins.

The workflow parses the message, routes it through a series of logic steps and returns a thoughtful, contextual response. The actual chat interface on the blog is nothing more than HTML and JavaScript calling the right endpoint, but behind the curtain, there’s a full orchestration engine at work.

This is what excites me most about building with n8n and Azure, every piece is composable, flexible, and private by design. I can iterate fast, fine-tune workflows in real time, and integrate anything from OpenAI to my own MCP server or blog metadata store.

The infrastructure is now invisible. All that’s left is the experience.

## Conclusion

When I started this project, I just wanted a way to play with ideas, I needed something small and cheap. But what I ended up creating is the foundation for something much bigger, an extensible, secure automation engine that powers a real-time AI assistant tied to my digital identity.

This wasn’t just about running n8n in a container. It was about control. About learning. About giving shape to an idea I had late one night "**what if my blog could talk back?**"

The beauty of this approach is that I’m not limited to just one agent. Tomorrow, I can build another focused on developer tools, or Azure Maps APIs, or even automating parts of my work. With n8n as the backend and Azure AI as the brain, the possibilities are wide open.

In the next post, I’ll show how I designed **ClemensGPT** itself, how I injected memory and personality into the responses, streamed tokens for instant feedback, and fine-tuned everything to reflect my voice. But for now, the backend is alive. The pipes are connected. The agent is listening.