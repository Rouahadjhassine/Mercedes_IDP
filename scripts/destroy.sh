#!/bin/bash
set -e

echo "========================================="
echo "  PFE - Destruction des ressources Azure"
echo "========================================="

command -v terraform >/dev/null || { echo "❌ Terraform non installé"; exit 1; }
az account show > /dev/null 2>&1 || { echo "❌ Lance d'abord: az login"; exit 1; }

echo "⚠️  ATTENTION: Toutes les ressources vont être supprimées!"
read -p "➡️ Tape 'yes' pour confirmer: " confirm
[ "$confirm" != "yes" ] && { echo "Annulé."; exit 0; }

echo "▶ Terraform Destroy..."
terraform destroy -var-file=terraform.tfvars -auto-approve

echo "✅ Toutes les ressources ont été supprimées."

# Mode reset: destroy + redeploy
if [ "$1" == "--reset" ]; then
  echo "🔄 Mode RESET: redéploiement dans 15 secondes..."
  sleep 15
  bash scripts/deploy.sh
fi