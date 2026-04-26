import glob
import re
import os

search_patterns = [
    'pipeline-*.yml',
    'idp-backstage/examples/template/*/skeleton/pipeline-*.yml'
]

for pattern in search_patterns:
    for filepath in glob.glob(pattern):
        filepath = os.path.normpath(filepath)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        # If it doesn't already have source bs-params.sh
        if 'source bs-params.sh' not in content:
            # We want to replace exactly this match:
            #           export ARM_SUBSCRIPTION_ID=$(SUBSCRIPTION_ID)
            # with the same plus the source command
            
            # Since YAML indentation could be different, let's match the exact export
            # and append our code with the same indentation.
            
            # Regex to find export ARM_SUBSCRIPTION_ID=$(SUBSCRIPTION_ID)
            # with its leading spaces
            # r'( +)export ARM_SUBSCRIPTION_ID=\$\(SUBSCRIPTION_ID\)\n'
            
            def repl(match):
                spaces = match.group(1)
                replacement = match.group(0) # the original matched string including newline
                # Then append our code
                replacement += f'{spaces}# ── Guard: Charger les variables Backstage si présentes ──\n'
                replacement += f'{spaces}[ -f bs-params.sh ] && source bs-params.sh\n'
                return replacement

            new_content = re.sub(r'( +)export ARM_SUBSCRIPTION_ID=\$\(SUBSCRIPTION_ID\)\n', repl, content)
            
            if new_content != content:
                with open(filepath, 'w', encoding='utf-8') as f:
                    f.write(new_content)
                print(f'Updated {filepath}')
