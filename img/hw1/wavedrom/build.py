"""Render the WaveDrom sources (*.json) to ../*.svg.
Usage: python3 build.py   (needs: pip install wavedrom)"""
import glob, json, os, wavedrom
here = os.path.dirname(os.path.abspath(__file__))
for src in sorted(glob.glob(os.path.join(here, "*.json"))):
    out = os.path.join(here, "..", os.path.basename(src)[:-5] + ".svg")
    d = json.load(open(src))
    for sig in d["signal"]:           # canonical WaveDrom: repeated levels use "."
        w, o = sig.get("wave", ""), ""
        for i, ch in enumerate(w):
            o += "." if i and ch in "01xz" and ch == w[i - 1] else ch
        sig["wave"] = o
    wavedrom.render(json.dumps(d)).saveas(out)
    print("wrote", os.path.normpath(out))
