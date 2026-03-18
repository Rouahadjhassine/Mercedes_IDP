IDP# 🏗️ IDP-MIC – Terraform Azure PFE

Architecture **4 pipelines séparés** (comme le Marketplace Azure) : chaque ressource est déployée indépendamment et partage ses informations via un **Remote State Terraform** dans Azure Blob Storage.

---

## 📋 Ordre des pipelines

```
1️⃣  Pipeline Resource Group  →  Crée le RG (obligatoire en premier)
         ↓ remote state (resource-group.tfstate)
2️⃣  Pipeline VM              →  Lit le RG, déploie les VMs
3️⃣  Pipeline Storage         →  Lit le RG, déploie le Storage Account
         ↓ remote state (storage.tfstate)
4️⃣  Pipeline Key Vault       →  Lit le RG + Storage, stocke les secrets
```

---

## 🚀 Pipelines Azure DevOps

| Fichier | Ressource | Pré-requis |
|---------|-----------|------------|
| `pipeline-resource-group.yml` | Resource Group | Aucun |
| `pipeline-vm.yml` | Virtual Machine | Pipeline #1 |
| `pipeline-storage.yml` | Storage Account | Pipeline #1 |
| `pipeline-keyvault.yml` | Key Vault | Pipeline #1 + #3 (optionnel) |

---

## 🗄️ Remote State – Prérequis (une seule fois)

```bash
# Créer le storage account de backend Terraform
az group create --name rg-terraform-state --location "West Europe"
az storage account create --name pfetfstate --resource-group rg-terraform-state --sku Standard_LRS
az storage container create --name tfstate --account-name pfetfstate
```

---

## 📁 Structure

```
terraform-azure-pfe/
├── pipeline-resource-group.yml   # Pipeline ADO #1
├── pipeline-vm.yml               # Pipeline ADO #2
├── pipeline-storage.yml          # Pipeline ADO #3
├── pipeline-keyvault.yml         # Pipeline ADO #4
│
├── pipelines/
│   ├── resource-group/           # Terraform – Resource Group
│   ├── vm/                       # Terraform – VM (lit RG via remote state)
│   ├── storage/                  # Terraform – Storage (lit RG via remote state)
│   └── keyvault/                 # Terraform – KeyVault (lit RG + Storage)
│
└── modules/
    ├── vm/                       # Module réutilisable VM
    ├── storage/                  # Module réutilisable Storage
    └── keyvault/                 # Module réutilisable KeyVault
```
