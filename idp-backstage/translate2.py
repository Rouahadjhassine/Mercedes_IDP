import os

directory = r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template'

translations = {
    'Génère un dépôt IaC basé sur vos pipelines (VM, KeyVault, Storage, RG).': 'Generates an IaC repository based on your pipelines (VM, KeyVault, Storage, RG).',
    'Équipe Propriétaire': 'Owning Team',
    '2. Identité des Ressources': '2. Resource Identity',
    'Nom de la VM (max 15 caractères)': 'VM Name (max 15 chars)',
    'Région Azure': 'Azure Region',
    'Génération du code Infrastructure': 'Generating Infrastructure Code',
    'Description (ex: Environnement de développement IDP)': 'Description (e.g., IDP Development Environment)',
    'Sélection de la ressource à supprimer': 'Select the resource to delete',
    'Récupération des informations de la ressource': 'Fetching resource information',
    'Lancement du Pipeline de destruction': 'Triggering destruction pipeline',
    'Suppression en cours': 'Deletion in progress',
    'Saisissez le nom exact du Resource Group (déjà créé) et le nom de votre futur Key Vault.': 'Enter the exact Resource Group name (already created) and the name of your future Key Vault.',
    'Laisser vide si vous ne voulez pas lier de stockage.': 'Leave empty if you do not want to link a storage account.',
    'Environnement de développement IDP': 'IDP Development Environment',
    'Lieu (Location)': 'Location',
    'Tags pour la gouvernance': 'Tags for governance',
    'Propriétaire (Owner)': 'Owner',
    'Niveau de criticité': 'Criticality level',
    'Saisissez le nom exact du Resource Group (déjà créé) et le nom de votre futur Storage.': 'Enter the exact Resource Group name (already created) and the name of your future Storage.',
    'Sélectionnez la ressource': 'Select the resource',
    'Saisissez le nom du Resource Group exact': 'Enter the exact Resource Group name'
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
            
            if content != original_content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(content)
                print(f'Translated: {filepath}')
print('Done.')
