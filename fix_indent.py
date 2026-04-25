import glob
import re

search_patterns = [
    'pipeline-resource-group.yml',
    'idp-backstage/examples/template/azure-resource-group/skeleton/pipeline-resource-group.yml',
    'idp-backstage/examples/template/azure-golden-path/skeleton/pipeline-resource-group.yml'
]

for pattern in search_patterns:
    for filepath in glob.glob(pattern):
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
        
        for i in range(1, len(lines)):
            if '-var=\"environment=${{ parameters.environment }}\"' in lines[i]:
                # find the previous line with resource_group_name
                prev_line = lines[i-1]
                match = re.search(r'^(\s*)', prev_line)
                if match:
                    indent = match.group(1)
                    lines[i] = indent + '-var=\"environment=${{ parameters.environment }}\" \\\n'
        
        with open(filepath, 'w', encoding='utf-8') as f:
            f.writelines(lines)
        print(f'Fixed indentation in {filepath}')
