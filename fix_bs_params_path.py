import glob
import re
import os

search_patterns = [
    'pipeline-*.yml',
    'idp-backstage/examples/template/*/skeleton/pipeline-*.yml'
]

replacement = r"""if [ -f "$(Pipeline.Workspace)/self/bs-params.sh" ]; then
  source "$(Pipeline.Workspace)/self/bs-params.sh"
  echo "✅ Sourced bs-params.sh from $(Pipeline.Workspace)/self"
elif [ -f "bs-params.sh" ]; then
  source "bs-params.sh"
  echo "✅ Sourced bs-params.sh from current directory"
else
  echo "⚠️ bs-params.sh not found!"
fi"""

for pattern in search_patterns:
    for filepath in glob.glob(pattern):
        filepath = os.path.normpath(filepath)
        with open(filepath, 'r', encoding='utf-8') as f:
            content = f.read()

        def repl(match):
            indent = match.group(1)
            lines = replacement.split('\n')
            return "\n".join([indent + l for l in lines])

        new_content = re.sub(r'([ \t]+)\[ -f bs-params\.sh \] && source bs-params\.sh', repl, content)
        
        if new_content != content:
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f'Updated {filepath}')
