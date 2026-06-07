# 🚀 Déploiement de l'IDP Backstage sur AKS avec ArgoCD

## 💡 Comprendre l'architecture (pourquoi Docker ?)

Kubernetes (AKS) **ne peut pas exécuter du code source** directement. Il fonctionne uniquement avec des **images Docker** (conteneurs). Voici le flux complet de votre IDP :

```
┌───────────────────────────────────────────────────────────────────┐
│  VOUS (développeur)                                               │
│                                                                   │
│  Modifiez le code → git push → Azure DevOps                      │
└─────────────────────────────┬─────────────────────────────────────┘
                              │
               ┌──────────────▼──────────────┐
               │  Pipeline CI Azure DevOps    │
               │  (pipeline-backstage-docker) │
               │                             │
               │  yarn build → docker build  │
               │  → docker push → ACR ✅     │
               └──────────────┬──────────────┘
                              │
               ┌──────────────▼──────────────┐
               │  ArgoCD (GitOps)             │
               │                             │
               │  Lit k8s/*.yaml depuis Git  │
               │  → Déploie sur AKS ✅       │
               └──────────────┬──────────────┘
                              │
               ┌──────────────▼──────────────┐
               │  AKS (Kubernetes)            │
               │                             │
               │  Pod Backstage (image ACR)  │
               │  Pod PostgreSQL (DB)  ✅    │
               └─────────────────────────────┘
```

**En résumé :**
- **Docker** : package le code en image → nécessaire pour Kubernetes
- **ACR** : stocke les images Docker (registre privé Azure)
- **ArgoCD** : lit les fichiers YAML de `k8s/` depuis Git et synchronise avec AKS
- **PostgreSQL** : base de données recommandée pour Backstage en production (meilleure concurrence et fiabilité qu'SQLite)

---

## 📋 Prérequis

- Cluster **AKS** opérationnel sur Azure
- **Azure Container Registry (ACR)** créé
- **ArgoCD** installé sur le cluster (`kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml`)
- Outils locaux : `kubectl`, `az` (Azure CLI)

---

## 🔐 Étape 1 : Créer les Secrets sur le Cluster AKS

> [!WARNING]
> **Ne committez jamais vos mots de passe ou tokens dans Git.** Créez les secrets directement sur le cluster depuis votre terminal.

```bash
# 1. Créer le namespace
kubectl create namespace idp-backstage

# 2. Créer le secret avec vos vraies valeurs
kubectl create secret generic backstage-secrets \
  --namespace idp-backstage \
  --from-literal=postgres-password="MonMotDePasse2024!" \
  --from-literal=azure-client-id="4477634b-77ab-4672-a566-81b4d0c5e21e" \
  --from-literal=azure-tenant-id="a7053885-9662-4f31-b58b-7200f57fad5b" \
  --from-literal=azure-client-secret="votre-client-secret" \
  --from-literal=azure-token="votre-pat-azure-devops" \
  --from-literal=github-token="votre-pat-github"

# 3. Vérifier que le secret est créé
kubectl get secrets -n idp-backstage
```

---

## 🐳 Étape 2 : Connecter AKS à l'ACR (une seule fois)

Pour qu'AKS puisse télécharger les images Docker depuis votre ACR privé :

```bash
az aks update \
  --resource-group <votre-resource-group> \
  --name <nom-de-votre-cluster-aks> \
  --attach-acr <nom-de-votre-acr>
```

---

## ⚙️ Étape 3 : Configurer le Pipeline CI (Build Docker automatique)

Le fichier [pipeline-backstage-docker.yml](file:///c:/Users/Roua%20Hadj%20Hassine/OneDrive/Bureau/terraform-azure-pfe/pipeline-backstage-docker.yml) construit automatiquement l'image Docker et la pousse sur ACR à chaque commit.

**Dans Azure DevOps :**
1. Créez un pipeline et sélectionnez `pipeline-backstage-docker.yml`.
2. Créez un **Variable Group** avec les variables :
   - `ACR_NAME` = nom de votre ACR (ex: `idpmic`)
   - `ACR_LOGINSERVER` = domaine complet (ex: `idpmic.azurecr.io`)
3. Assurez-vous que la connexion de service `MIC-IDP` a les droits `AcrPush`.

Lors du **premier déploiement**, lancez manuellement le pipeline pour construire l'image initiale.

---

## 📝 Étape 4 : Adapter les Manifestes Kubernetes

### 4.1 Mettre à jour l'image dans backstage.yaml
Ouvrez [k8s/backstage.yaml](file:///c:/Users/Roua%20Hadj%20Hassine/OneDrive/Bureau/terraform-azure-pfe/k8s/backstage.yaml) et remplacez :
```yaml
image: <VOTRE_ACR>.azurecr.io/backstage:latest
```
Par :
```yaml
image: idpmic.azurecr.io/backstage:latest   # votre vrai ACR
```

### 4.2 Mettre à jour l'URL du dépôt dans application.yaml
Ouvrez [argocd/application.yaml](file:///c:/Users/Roua%20Hadj%20Hassine/OneDrive/Bureau/terraform-azure-pfe/argocd/application.yaml) et remplacez la ligne `repoURL` par l'URL de votre dépôt Git :
```yaml
repoURL: 'https://dev.azure.com/ymi0337/IDP-MIC/_git/IDP-MIC'
# ou votre GitHub personnel :
repoURL: 'https://github.com/votre-username/terraform-azure-pfe.git'
```

---

## 🐙 Étape 5 : Lancer ArgoCD (déploiement GitOps)

```bash
# Appliquer le manifeste ArgoCD (une seule fois)
kubectl apply -f argocd/application.yaml

# Vérifier que l'application ArgoCD est créée
kubectl get application idp-backstage -n argocd
```

ArgoCD va automatiquement :
1. Créer le namespace `idp-backstage`
2. Déployer PostgreSQL (avec volume persistant)
3. Déployer Backstage (après que PostgreSQL soit prêt)
4. Exposer Backstage via un LoadBalancer Azure

---

## 🔍 Étape 6 : Vérification et Accès

```bash
# Vérifier l'état des pods (attendez que tous soient Running)
kubectl get pods -n idp-backstage -w

# Une fois les pods en Running, récupérer l'IP publique
kubectl get svc backstage -n idp-backstage
```

L'output ressemble à :
```
NAME        TYPE           CLUSTER-IP    EXTERNAL-IP      PORT(S)
backstage   LoadBalancer   10.0.x.x      20.XXX.XXX.XXX   80:30xxx/TCP
```

Accédez à votre IDP à l'adresse : `http://20.XXX.XXX.XXX`

> [!TIP]
> Ensuite, mettez à jour la variable `APP_BASE_URL` dans [k8s/backstage.yaml](file:///c:/Users/Roua%20Hadj%20Hassine/OneDrive/Bureau/terraform-azure-pfe/k8s/backstage.yaml) avec cette IP publique et dans [argocd/application.yaml](file:///c:/Users/Roua%20Hadj%20Hassine/OneDrive/Bureau/terraform-azure-pfe/argocd/application.yaml) pour finaliser la configuration SSO.

---

## 📁 Structure des Fichiers Créés

```
terraform-azure-pfe/
├── pipeline-backstage-docker.yml   ← Pipeline CI : build et push l'image Docker
│
├── k8s/                            ← Manifestes K8s (lus par ArgoCD)
│   ├── postgres.yaml               ← BD PostgreSQL + PVC + Service
│   ├── backstage.yaml              ← App Backstage + Service LoadBalancer
│   └── backstage-secrets.yaml      ← Modèle de secrets (NE PAS committer complété)
│
└── argocd/
    └── application.yaml            ← Application ArgoCD (GitOps)
```
