import os
import glob
import re

files = glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\pipeline-*.yml', recursive=True)
files.extend(glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\azure-pipelines*.yml', recursive=True))

def fix_checkout(match):
    indent = match.group(1)
    return indent + '- checkout: self\n' + indent + '  path: self\n' + indent + '- checkout: git://IDP-MIC/IDP-MIC\n' + indent + '  path: IDP-MIC\n'

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # We current have:
    #     - checkout: self
    #     - checkout: git://IDP-MIC/IDP-MIC
    
    content = re.sub(r'^([ \t]*)-\s+checkout:\s+self\n[ \t]*-\s+checkout:\s+git://IDP-MIC/IDP-MIC\n', fix_checkout, content, flags=re.MULTILINE)

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)

print(f"Fixed explicit paths in {len(files)} files.")
