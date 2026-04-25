import glob
import re

search_patterns = [
    'pipeline-*.yml',
    'idp-backstage/examples/template/*/skeleton/pipeline-*.yml'
]

for pattern in search_patterns:
    for filepath in glob.glob(pattern):
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        # Replace default: "" under resource_group_name
        content = re.sub(r'(    displayName: "🏷️ Nom du Resource Group.*?"\n    type: string\n    default: )""', r'\1"rg-monprojet-test"', content)
        
        # Replace default: "" under storage_account_name
        content = re.sub(r'(    displayName: "📦 Nom du Compte de Stockage.*?"\n    type: string\n    default: )""', r'\1"stmonprojettest"', content)

        # Replace default: "" under keyvault_name
        content = re.sub(r'(    displayName: "🔐 Nom du Key Vault.*?"\n    type: string\n    default: )""', r'\1"kv-monprojet-test"', content)

        # Replace default: "" under vm_name
        content = re.sub(r'(    displayName: "💻 Nom de la Virtual Machine.*?"\n    type: string\n    default: )""', r'\1"vm-monprojet-test"', content)


        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f'Updated defaults in {filepath}')
