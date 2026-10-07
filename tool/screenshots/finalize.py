#!/usr/bin/env python3
"""Flatten raw screenshots to opaque RGB PNGs and verify their dimensions.

App Store Connect rejects screenshots with an alpha channel, and each device
class only accepts exact pixel sizes. Called by take_screenshots.sh:

    python3 finalize.py <raw-dir> <out-dir> <width>x<height>

Only the files present in <raw-dir> are written, so a partial run (e.g. just
the route pass) replaces those screenshots and leaves the rest alone. Exits
non-zero if any image has the wrong size.
"""
import sys
from pathlib import Path

from PIL import Image

src, dst, size = Path(sys.argv[1]), Path(sys.argv[2]), sys.argv[3]
want = tuple(int(v) for v in size.split("x"))
raw = sorted(src.glob("*.png"))
if not raw:
    sys.exit(f"no screenshots found in {src}")

dst.mkdir(parents=True, exist_ok=True)
ok = True
for path in raw:
    im = Image.open(path)
    if im.mode in ("RGBA", "LA", "P"):
        im = im.convert("RGBA")
        flat = Image.new("RGB", im.size, (0, 0, 0))
        flat.paste(im, mask=im.getchannel("A"))
        im = flat
    elif im.mode != "RGB":
        im = im.convert("RGB")
    out = dst / path.name
    im.save(out, "PNG", optimize=True)

    check = Image.open(out)
    match = check.size == want and check.mode == "RGB"
    ok &= match
    print(f"{out}  {check.size[0]}x{check.size[1]}  {check.mode}  "
          f"{'OK' if match else 'WRONG SIZE'}")

sys.exit(0 if ok else 1)
