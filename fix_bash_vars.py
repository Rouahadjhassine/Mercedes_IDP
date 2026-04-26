import glob
import re
import os

search_patterns = [
    'pipeline-*.yml',
    'idp-backstage/examples/template/*/skeleton/pipeline-*.yml'
]

replacements = {
    r'RG_NAME="\$\{\{ parameters\.resource_group_name \}\}"': r'RG_NAME="${BS_RESOURCE_GROUP_NAME:-\${{ parameters.resource_group_name }}}"',
    r'LOCATION="\$\{\{ parameters\.location \}\}"': r'LOCATION="${BS_LOCATION:-\${{ parameters.location }}}"',
    r'ENVIRONMENT="\$\{\{ parameters\.environment \}\}"': r'ENVIRONMENT="${BS_ENVIRONMENT:-\${{ parameters.environment }}}"',
    r'SA_NAME="\$\{\{ parameters\.storage_account_name \}\}"': r'SA_NAME="${BS_STORAGE_ACCOUNT_NAME:-\${{ parameters.storage_account_name }}}"',
    r'KV_NAME="\$\{\{ parameters\.keyvault_name \}\}"': r'KV_NAME="${BS_KEYVAULT_NAME:-\${{ parameters.keyvault_name }}}"',
    r'VM_NAME="\$\{\{ parameters\.vm_name \}\}"': r'VM_NAME="${BS_VM_NAME:-\${{ parameters.vm_name }}}"',
    r'TAG_OWNER="\$\{\{ parameters\.tag_owner \}\}"': r'TAG_OWNER="${BS_TAG_OWNER:-\${{ parameters.tag_owner }}}"',
    r'TAG_PROJECT="\$\{\{ parameters\.tag_project \}\}"': r'TAG_PROJECT="${BS_TAG_PROJECT:-\${{ parameters.tag_project }}}"',
    r'TAG_COST_CENTER="\$\{\{ parameters\.tag_cost_center \}\}"': r'TAG_COST_CENTER="${BS_TAG_COST_CENTER:-\${{ parameters.tag_cost_center }}}"',
    r'TAG_MANAGED_BY="\$\{\{ parameters\.tag_managed_by \}\}"': r'TAG_MANAGED_BY="${BS_TAG_MANAGED_BY:-\${{ parameters.tag_managed_by }}}"',
    r'TAG_CRITICALITY="\$\{\{ parameters\.tag_criticality \}\}"': r'TAG_CRITICALITY="${BS_TAG_CRITICALITY:-\${{ parameters.tag_criticality }}}"',
    r'TAG_DATA_CLASSIFICATION="\$\{\{ parameters\.tag_data_classification \}\}"': r'TAG_DATA_CLASSIFICATION="${BS_TAG_DATA_CLASSIFICATION:-\${{ parameters.tag_data_classification }}}"'
}

for pattern in search_patterns:
    for filepath in glob.glob(pattern):
        # normalize path
        filepath = os.path.normpath(filepath)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()
        
        has_changed = False
        for search, replace in replacements.items():
            # Because python regex treats \ as escape, let's fix the replace string
            # we want exact string: RG_NAME="${BS_RESOURCE_GROUP_NAME:-${{ parameters.resource_group_name }}}"
            # wait, the replace string above has \${{ which becomes \${{ in output!
            # let's be careful.
            
            # replace literal \${{ with ${{ in the replacement string
            clean_replace = replace.replace(r'\${{', '${{')
            
            new_content = re.sub(search, clean_replace, content)
            if new_content != content:
                content = new_content
                has_changed = True

        if has_changed:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f'Updated {filepath}')
