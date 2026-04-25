import glob
import re

for filepath in glob.glob('idp-backstage/examples/template/*/template.yaml'):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # We want to replace 'default: ""' right after 'description: "Le nom...' or 'title: "🏷️ Nom du Resource Group"'
    # with minLength constraint, to ensure Backstage blocks empty values.
    
    # We can just inject minLength: 2 after maxLength: 90
    content = re.sub(r'(          maxLength: 90\n)', r'\1          minLength: 2\n', content)
    
    # For storage account name
    content = re.sub(r'(          maxLength: 24\n)', r'\1          minLength: 3\n', content)
    
    # Remove default: "" if it's there
    content = re.sub(r'\s*default: ""\n', '\n', content)

    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Added minLength constraints to {filepath}')
