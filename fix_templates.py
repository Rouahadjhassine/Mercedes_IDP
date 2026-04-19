import os
import glob
import re

files = glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\template.yaml', recursive=True)

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Replace static pipeline names with dynamic ones that include the repo name
    content = content.replace('pipelineName: pipeline-resource-group', 'pipelineName: pipeline-resource-group-${{ parameters.repo_name }}')
    content = content.replace('pipelineName: pipeline-vm', 'pipelineName: pipeline-vm-${{ parameters.repo_name }}')
    content = content.replace('pipelineName: pipeline-keyvault', 'pipelineName: pipeline-keyvault-${{ parameters.repo_name }}')
    content = content.replace('pipelineName: pipeline-storage', 'pipelineName: pipeline-storage-${{ parameters.repo_name }}')
    
    # Also fix azure-golden-path if it has them
    
    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)

print(f"Fixed templates in {len(files)} files.")
