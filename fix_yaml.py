import os
import glob
import re

files = glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\pipeline-*.yml', recursive=True)
files.extend(glob.glob(r'c:\Users\Roua Hadj Hassine\OneDrive\Bureau\terraform-azure-pfe\idp-backstage\examples\template\**\azure-pipelines.yml', recursive=True))

def fix_checkout(match):
    indent = match.group(1)
    return indent + '- checkout: self\n' + indent + '- checkout: git://IDP-MIC/IDP-MIC\n'

for f in files:
    with open(f, 'r', encoding='utf-8') as file:
        content = file.read()
    
    # Fix the checkout steps
    content = re.sub(r'^([ \t]*)-\s+checkout:\s+[^\n]+(?:\n[ \t]+path:\s+[^\n]+)?\n', fix_checkout, content, flags=re.MULTILINE)
    
    # Let's ensure no duplicate checkout: self is created if the file already had it.
    # The regex replaces the existing checkout with `self + IDP-MIC`. 
    # If the file had 2 back-to-back checkouts, they'd get replaced by 4. But originally they only had 1.
    
    # Fix the cd working directory
    content = content.replace('cd $(TF_WORKING_DIR)', 'cd $(Pipeline.Workspace)/IDP-MIC/$(TF_WORKING_DIR)')

    with open(f, 'w', encoding='utf-8') as file:
        file.write(content)

print(f"Fixed checkouts and cd paths in {len(files)} files.")
