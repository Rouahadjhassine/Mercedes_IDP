import os
import glob

files = glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\pipeline-*.yml', recursive=True)
files.extend(glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\azure-pipelines.yml', recursive=True))

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    content = content.replace('cd /IDP-MIC/$(TF_WORKING_DIR)', 'cd $(Pipeline.Workspace)/IDP-MIC/$(TF_WORKING_DIR)')

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
print(f"Fixed cd in {len(files)} files.")
