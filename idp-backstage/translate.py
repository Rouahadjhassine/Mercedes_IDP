import os
import re

directory = r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template'

translations = {
    '🗑️ Supprimer une ressource Azure': '🗑️ Delete an Azure Resource',
    'Sélectionnez une ressource existante dans le catalogue pour lancer son pipeline de suppression (action: destroy).': 'Select an existing resource from the catalog to trigger its deletion pipeline (action: destroy).',
    '🗑️ Sélection de la ressource à supprimer': '🗑️ Select the resource to delete',
    'Sélectionnez la ressource': 'Select the resource',
    'La ressource choisie sera supprimée définitivement d\'Azure.': 'The chosen resource will be permanently deleted from Azure.',
    '🔍 Récupération des informations de la ressource': '🔍 Fetching resource information',
    '💣 Lancement du Pipeline de destruction': '💣 Triggering destruction pipeline',
    '▶️ View Pipeline Execution de destruction': '▶️ View Destruction Pipeline Execution',
    '💣 Suppression en cours': '💣 Deletion in progress',
    'La demande de destruction a été envoyée !': 'The destruction request has been sent!',
    'Le pipeline Azure DevOps `${{ steps[\'run-destroy-pipeline\'].output.pipelineId }}` est en cours d\'exécution pour détruire l\'infrastructure.': 'The Azure DevOps pipeline `${{ steps[\'run-destroy-pipeline\'].output.pipelineId }}` is running to destroy the infrastructure.',
    'On extrait l\'organisation depuis l\'annotation (ou valeur par défaut ymi0337)': 'Extract organization from annotation',
    'Le nom du pipeline est stocké comme annotation au moment de la création': 'Pipeline name is stored as annotation',
    'Créer un Resource Group Azure': 'Create an Azure Resource Group',
    'Crée un Resource Group basique pour y héberger d\'autres ressources.': 'Creates a basic Resource Group to host other resources.',
    '📋 Informations Générales': '📋 General Information',
    'Saisissez le nom de votre futur Resource Group': 'Enter the name of your future Resource Group',
    'Azure DevOps et Dépôt': 'Azure DevOps and Repository',
    'Configuration du dépôt et du pipeline.': 'Repository and pipeline configuration.',
    'Sélectionnez l\'organisation ADO': 'Select the ADO organization',
    'Sélectionnez le Projet ADO': 'Select the ADO Project',
    'Nom du dépôt à créer': 'Name of the repository to create',
    'Lieu (Location)': 'Location',
    'Où déployer la ressource': 'Where to deploy the resource',
    '🏷️ Tags Obligatoires': '🏷️ Required Tags',
    'Tags pour la gouvernance': 'Tags for governance',
    'Propriétaire (Owner)': 'Owner',
    'Projet associé': 'Associated project',
    'Niveau de criticité': 'Criticality level',
    'Faible': 'Low',
    'Moyenne': 'Medium',
    'Haute': 'High',
    'Préparation des fichiers Terraform': 'Preparing Terraform files',
    'Création du Dépôt ADO': 'Creating ADO Repository',
    'Lancement du Pipeline de déploiement': 'Triggering deployment pipeline',
    'Enregistrement dans le Catalogue Backstage': 'Registering in Backstage Catalog',
    'Lien vers le dépôt': 'Repository Link',
    'Lien vers le Pipeline': 'Pipeline Link',
    '🚀 Déploiement en cours': '🚀 Deployment in progress',
    'Le pipeline Azure DevOps est en cours d\'exécution pour déployer l\'infrastructure.': 'The Azure DevOps pipeline is running to deploy the infrastructure.',
    'Veuillez patienter quelques instants. Vous pouvez suivre l\'avancement via le lien du pipeline.': 'Please wait a few moments. You can track the progress via the pipeline link.',
    'Créer un Storage Account Azure': 'Create an Azure Storage Account',
    'Crée un compte de stockage Azure.': 'Creates an Azure Storage Account.',
    'Saisissez le nom du Resource Group exact et le nom de votre futur Storage.': 'Enter the exact Resource Group name and the name of your future Storage.',
    '⚠️ Prerequisite: A Resource Group must already exist.': '⚠️ Prerequisite: A Resource Group must already exist.',
    'Saisissez le nom de votre futur Storage Account': 'Enter the name of your future Storage Account',
    'Saisissez le nom exact du Resource Group (déjà créé)': 'Enter the exact name of the Resource Group (already created)',
    '⚙️ Configuration du Stockage': '⚙️ Storage Configuration',
    'Type de compte (Kind)': 'Account Kind (Kind)',
    'Niveau de performance (Tier)': 'Performance Tier',
    'Standard (Recommandé)': 'Standard (Recommended)',
    'Type de réplication': 'Replication type',
    'Local (LRS)': 'Local (LRS)',
    'Zone (ZRS)': 'Zone (ZRS)',
    'Geo (GRS)': 'Geo (GRS)',
    'Geo-Zone (GZRS)': 'Geo-Zone (GZRS)',
    'Créer un Key Vault Azure': 'Create an Azure Key Vault',
    'Crée un coffre-fort de clés Azure.': 'Creates an Azure Key Vault.',
    'Saisissez le nom du Resource Group exact et le nom de votre futur Key Vault.': 'Enter the exact Resource Group name and the name of your future Key Vault.',
    'Saisissez le nom de votre futur Key Vault': 'Enter the name of your future Key Vault',
    'Nom du Storage Account (Optionnel)': 'Storage Account Name (Optional)',
    'Laisser vide si vous ne voulez pas lier de stockage.': 'Leave empty if you do not want to link a storage.',
    'Créer une Machine Virtuelle Azure': 'Create an Azure Virtual Machine',
    'Crée une Machine Virtuelle Azure (Windows ou Linux).': 'Creates an Azure Virtual Machine (Windows or Linux).',
    'Saisissez le nom du Resource Group exact et le nom de votre future VM.': 'Enter the exact Resource Group name and the name of your future VM.',
    'Saisissez le nom de votre future Machine Virtuelle': 'Enter the name of your future Virtual Machine',
    'Saisissez le nom exact du Resource Group (déjà créé) et le nom de votre future Machine Virtuelle.': 'Enter the exact Resource Group name (already created) and the name of your future Virtual Machine.',
    '⚙️ Configuration de la VM': '⚙️ VM Configuration',
    'Type d\'OS': 'OS Type',
    'Image OS': 'OS Image',
    'Taille de la VM (Size)': 'VM Size',
    'Type de disque': 'Disk Type',
    'Standard HDD': 'Standard HDD',
    'Standard SSD': 'Standard SSD',
    'Premium SSD': 'Premium SSD',
    'Nombre de VMs': 'Number of VMs',
    'Combien de VMs créer': 'How many VMs to create'
}

for root, _, files in os.walk(directory):
    for file in files:
        if file.endswith('.yaml') or file.endswith('.yml'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()
            
            original_content = content
            for fr, en in translations.items():
                content = content.replace(fr, en)
            
            # Use regex for some dynamic ones if needed, but direct replace is fine
            content = re.sub(r'title: \".*View Pipeline Execution de destruction\"', 'title: \"▶️ View Destruction Pipeline Execution\"', content)
            
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f'Translated: {filepath}')
print('Done.')
