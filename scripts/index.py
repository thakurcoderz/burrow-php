"""Write index.json for the `builds` release: one entry per tarball with its
size and SHA-256, in the same shape as static-php's directory listing
(name, is_dir, size) plus `sha256`. Reads the *.sha256 files in a folder.

    python3 scripts/index.py <dir with *.sha256> <assets.json> > index.json

assets.json is `gh release view builds --json assets`.
"""
import json
import pathlib
import sys

sums = {}
for f in pathlib.Path(sys.argv[1]).glob("*.sha256"):
    digest, name = f.read_text().split()[:2]
    sums[name.lstrip("*")] = digest

assets = json.loads(pathlib.Path(sys.argv[2]).read_text())["assets"]
entries = []
for a in sorted(assets, key=lambda a: a["name"]):
    name = a["name"]
    if not name.endswith(".tar.gz"):
        continue
    if name not in sums:
        sys.exit(f"no checksum for {name}")
    entries.append({"name": name, "is_dir": False, "size": a["size"], "sha256": sums[name]})
json.dump(entries, sys.stdout, indent=1)
print()
