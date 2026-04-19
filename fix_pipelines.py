import os
import glob
import re

files = glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\pipeline-*.yml', recursive=True)
files.extend(glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\azure-pipelines.yml', recursive=True))

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Let's count if "checkout: git://IDP-MIC/IDP-MIC" exists.
    # First, let's normalize everything to just "checkout: self".
    # Remove any existing IDP-MIC checkout blocks and path: s
    content = re.sub(r'\s*-\s+checkout:\s+git://IDP-MIC/IDP-MIC\s+path:\s+s', '', content)
    content = re.sub(r'\s*-\s+checkout:\s+git://IDP-MIC/IDP-MIC', '', content)
    
    # Replace all checkout: self with checkout: self + checkout git...
    # Make sure we don't double replace
    content = re.sub(r'-\s+checkout:\s+self', '- checkout: self\n    - checkout: git://IDP-MIC/IDP-MIC', content)
    
    # Fix the cd commands
    # If already replaced, don't re-replace
    if '$(Pipeline.Workspace)/IDP-MIC/$(TF_WORKING_DIR)' not in content:
        content = content.replace('cd $(TF_WORKING_DIR)', 'cd $(Pipeline.Workspace)/IDP-MIC/$(TF_WORKING_DIR)')

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)
print(f"Processed len {len(files)} files.")
