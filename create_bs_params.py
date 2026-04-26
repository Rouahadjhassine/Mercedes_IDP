import os

storage_params = '''#!/bin/bash
export BS_STORAGE_ACCOUNT_NAME="${{ values.storage_account_name }}"
export BS_RESOURCE_GROUP_NAME="${{ values.resource_group_name }}"
export BS_LOCATION="${{ values.location }}"
export BS_ENVIRONMENT="${{ values.environment }}"
export BS_TAG_OWNER="${{ values.tag_owner }}"
export BS_TAG_PROJECT="${{ values.tag_project }}"
export BS_TAG_COST_CENTER="${{ values.tag_cost_center | default('') }}"
export BS_TAG_MANAGED_BY="${{ values.tag_managed_by | default('') }}"
export BS_TAG_CRITICALITY="${{ values.tag_criticality }}"
export BS_TAG_DATA_CLASSIFICATION="${{ values.tag_data_classification }}"
'''

keyvault_params = '''#!/bin/bash
export BS_KEYVAULT_NAME="${{ values.keyvault_name }}"
export BS_RESOURCE_GROUP_NAME="${{ values.resource_group_name }}"
export BS_LOCATION="${{ values.location }}"
export BS_ENVIRONMENT="${{ values.environment }}"
export BS_TAG_OWNER="${{ values.tag_owner }}"
export BS_TAG_PROJECT="${{ values.tag_project }}"
export BS_TAG_COST_CENTER="${{ values.tag_cost_center | default('') }}"
export BS_TAG_MANAGED_BY="${{ values.tag_managed_by | default('') }}"
export BS_TAG_CRITICALITY="${{ values.tag_criticality }}"
export BS_TAG_DATA_CLASSIFICATION="${{ values.tag_data_classification }}"
'''

vm_params = '''#!/bin/bash
export BS_VM_NAME="${{ values.vm_name }}"
export BS_RESOURCE_GROUP_NAME="${{ values.resource_group_name }}"
export BS_LOCATION="${{ values.location }}"
export BS_ENVIRONMENT="${{ values.environment }}"
export BS_TAG_OWNER="${{ values.tag_owner }}"
export BS_TAG_PROJECT="${{ values.tag_project }}"
export BS_TAG_COST_CENTER="${{ values.tag_cost_center | default('') }}"
export BS_TAG_MANAGED_BY="${{ values.tag_managed_by | default('') }}"
export BS_TAG_CRITICALITY="${{ values.tag_criticality }}"
export BS_TAG_DATA_CLASSIFICATION="${{ values.tag_data_classification }}"
'''

rg_params = '''#!/bin/bash
export BS_RESOURCE_GROUP_NAME="${{ values.resource_group_name }}"
export BS_LOCATION="${{ values.location }}"
export BS_ENVIRONMENT="${{ values.environment }}"
export BS_TAG_OWNER="${{ values.tag_owner }}"
export BS_TAG_PROJECT="${{ values.tag_project }}"
export BS_TAG_COST_CENTER="${{ values.tag_cost_center | default('') }}"
export BS_TAG_MANAGED_BY="${{ values.tag_managed_by | default('') }}"
export BS_TAG_CRITICALITY="${{ values.tag_criticality }}"
export BS_TAG_DATA_CLASSIFICATION="${{ values.tag_data_classification }}"
'''

paths = {
    'idp-backstage/examples/template/azure-storage/skeleton/bs-params.sh': storage_params,
    'idp-backstage/examples/template/azure-keyvault/skeleton/bs-params.sh': keyvault_params,
    'idp-backstage/examples/template/azure-vm/skeleton/bs-params.sh': vm_params,
    'idp-backstage/examples/template/azure-resource-group/skeleton/bs-params.sh': rg_params,
    'idp-backstage/examples/template/azure-golden-path/skeleton/bs-params.sh': rg_params
}

for path, content in paths.items():
    norm_path = os.path.normpath(path)
    os.makedirs(os.path.dirname(norm_path), exist_ok=True)
    with open(norm_path, 'w', encoding='utf-8') as f:
        f.write(content)
    print("Created", norm_path)
