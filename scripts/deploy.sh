#!/bin/bash
set -e

echo "========================================="
echo "  PFE - Déploiement Azure avec Terraform"
echo "========================================="

# Vérifications
command -v terraform >/dev/null || { echo "❌ Terraform non installé"; exit 1; }
command -v az >/dev/null        || { echo "❌ Azure CLI non installé"; exit 1; }
az account show > /dev/null 2>&1 || { echo "❌ Lance d'abord: az login"; exit 1; }

echo "✅ Connecté à Azure: $(az account show --query name -o tsv)"

# Init
echo "▶ Terraform Init..."
terraform init -upgrade

# Validate
echo "▶ Validation..."
terraform validate

# Plan
echo "▶ Terraform Plan..."
terraform plan -out=tfplan -var-file=terraform.tfvars

# Confirmation
read -p "➡️ Confirmer le déploiement? (yes/no): " confirm
[ "$confirm" != "yes" ] && { echo "Annulé."; exit 0; }

# Apply
echo "▶ Terraform Apply..."
terraform apply tfplan

echo ""
echo "✅ Déploiement terminé!"
echo "📊 Résumé:"
terraform output