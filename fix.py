import glob
import re

for filepath in glob.glob('idp-backstage/examples/template/*/template.yaml'):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # 1. Remove '- environment' from Step 1 (or wherever it was wrongly placed first)
    # We will just remove ALL "- environment" from required blocks, then add it correctly.
    # Wait, simple string replace:
    content = content.replace('        - environment\n', '')
    
    # 2. Find the required block under "Configuration Azure" or "Resource Group cible"
    # Actually, we can just insert it after '- resource_group_name' or '- location'
    
    # Let's cleanly inject it exactly after '- location' or '- storage_account_name' if location is not there.
    # But wait, it's safer to just look for the properties dict where we inserted `environment:` and insert it in the required block of that same Step.
    
    # A safer way: just replace '- resource_group_name\n' with '- resource_group_name\n        - environment\n'
    # in the required blocks.
    
    content = re.sub(r'(        - resource_group_name\n)', r'\1        - environment\n', content)
    
    with open(filepath, 'w', encoding='utf-8') as f:
        f.write(content)
    print(f'Fixed {filepath}')
