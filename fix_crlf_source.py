#!/usr/bin/env python3
"""
Adds sed -i 's/\\r//' <file> before every `source <file>` of bs-params.sh
in the resource-group pipelines (skeleton + root).
"""
import re
import sys

FILES = [
    r"pipeline-resource-group.yml",
    r"idp-backstage\examples\template\azure-resource-group\skeleton\pipeline-resource-group.yml",
]

PATTERN = re.compile(
    r'( +)(source "([^"]*bs-params\.sh)")',
)

def fix_file(path: str) -> None:
    with open(path, "r", encoding="utf-8") as f:
        content = f.read()

    matches = PATTERN.findall(content)
    if not matches:
        print(f"  [WARNING] No occurrences found in {path}")
        return

    def replacer(m):
        indent = m.group(1)
        source_line = m.group(2)
        filepath_expr = m.group(3)
        sed_line = f"{indent}sed -i 's/\\r//' \"{filepath_expr}\""
        return f"{sed_line}\n{indent}{source_line}"

    new_content = PATTERN.sub(replacer, content)

    # Deduplicate if script is re-run
    dup_pattern = re.compile(
        r"( +sed -i 's/\\r//' \"([^\"]*bs-params\.sh)\"\n"
        r" +sed -i 's/\\r//' \"\2\")",
    )
    while dup_pattern.search(new_content):
        new_content = dup_pattern.sub(lambda m: m.group(0).split('\n')[0], new_content)

    with open(path, "w", encoding="utf-8") as f:
        f.write(new_content)

    count = len(matches)
    print(f"  [OK] {count} occurrence(s) fixed in {path}")

if __name__ == "__main__":
    for file_path in FILES:
        print(f"\n[*] Processing: {file_path}")
        try:
            fix_file(file_path)
        except FileNotFoundError:
            print(f"  [ERROR] File not found: {file_path}")
            sys.exit(1)

    print("\n[DONE] All sed CRLF fixes applied.")
