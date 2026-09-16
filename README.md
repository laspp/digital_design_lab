# Digital Design Lab

Lab manual for the Digital Design course, built as a [Quarto](https://quarto.org) book from `chapters/*.qmd`. Once published, it will be available at `https://laspp.github.io/digital_design_lab/`.

This year's labs use [Anvil](https://logismith.github.io/Anvil/), an open-source FPGA toolchain (F4PGA: Yosys + VPR) targeting the Digilent Nexys A7 100T — see [Lab 1](chapters/01-tools-intro.qmd) for setup instructions.

## Building locally

Requires [Quarto](https://quarto.org) and [Tectonic](https://tectonic-typesetting.github.io) (PDF engine):

```bash
brew install --cask quarto
brew install tectonic
```

Then:

```bash
make html      # render HTML -> _book/
make pdf       # render PDF  -> _book/
make render    # render both (default)
make preview   # live-reload dev server
make clean     # remove build output
```

## Structure

- `chapters/` — one `.qmd` file per lab
- `code/<NN>_lab/` — starter/reference source files, linked from each chapter
- `img/` — figures
- `_quarto.yml` — book config and chapter order
