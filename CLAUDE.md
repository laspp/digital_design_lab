# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A Quarto book for a digital design lab course, migrated from `digital_design_labwork/` — a separate nested git repo (its own `.git`) checked out at the repo root, which holds the source-of-truth lab manuscripts (`01_lab/` … `09_lab/`, each a numbered Markdown lab writeup plus its SystemVerilog/C/XDC starter files and a shared `img/`). Content there is the material being refined into this book; treat `digital_design_labwork/` as read-mostly source to migrate from, not as part of the book itself.

## Commands

```bash
make html      # render HTML only  -> _book/
make pdf       # render PDF only (tectonic engine) -> _book/
make render    # render both formats (default target)
make preview   # live-reload dev server (quarto preview)
make check     # verify Quarto + engine install (quarto check)
make clean     # remove _book/, .quarto/, and other render artifacts
```

Toolchain: [Quarto](https://quarto.org) (`quarto`) + [Tectonic](https://tectonic-typesetting.github.io) as the PDF engine (set via `pdf-engine: tectonic` in `_quarto.yml` — no separate LaTeX distribution needed). Both installed via Homebrew (`brew install --cask quarto`, `brew install tectonic`).

There is no single-test/single-chapter render command beyond passing a source file straight to Quarto, e.g. `quarto render chapters/06-uart.qmd`.

## Structure

- `_quarto.yml` — book project config: chapter list/order and format options (html, pdf). **This file is the single source of truth for chapter order** — a new chapter must be added here or it won't render.
- `index.qmd` — book preface.
- `chapters/*.qmd` — one file per lab, migrated from `digital_design_labwork/<NN>_lab/*.md`. Filenames are `NN-slug.qmd` where `NN` matches the lab folder number (not necessarily the number embedded in the original filename — e.g. lab 6's source file is literally named `05-UART.md`, but it's folder `06_lab`; the chapter is named `06-uart.qmd` after the folder, not the source filename).
- `img/` — copied verbatim from `digital_design_labwork/img/` (flat, ~21MB, one subfolder `rigol_exe/`). Chapters reference images with `../img/...`, unchanged from the original relative depth.
- `code/<NN>_lab/` — per-lab starter/reference source files (`.sv`, `.c`, `.xdc`) copied from `digital_design_labwork/<NN>_lab/`, decision: **linked as downloads, not embedded inline**. Each migrated chapter has a "Starter files" section at the end with relative links (`../code/<NN>_lab/<file>`) to every non-Markdown file from its source lab folder. Quarto's resource scanner picks these up automatically from the links and copies them into `_book/` on render — no manual registration needed in `_quarto.yml`.

## Publishing to GitHub Pages

`.github/workflows/publish.yml` renders and publishes the book to the `gh-pages` branch on every push to `main` (and on manual dispatch), via `quarto-dev/quarto-actions/publish@v2` with `target: gh-pages`. It installs Tectonic in the runner first since the book's PDF format needs it too.

**One-time setup required before this workflow will work** (not yet done as of this writing):

1. Run `quarto publish gh-pages` locally once, authenticated against the `laspp/digital_design_lab` GitHub remote — this creates `_publish.yml`, which the CI action needs on subsequent runs. This pushes a `gh-pages` branch and is outward-facing/hard to reverse, so do it deliberately rather than as a side effect of another task.
2. In the repo's GitHub Settings → Actions → General → Workflow permissions, enable "Read and write permissions".
3. In Settings → Pages, set the source to the `gh-pages` branch (the `quarto publish` step above typically does this automatically).

## Migrating a lab from `digital_design_labwork/`

1. Copy `digital_design_labwork/<NN>_lab/<file>.md` → `chapters/<NN>-<slug>.qmd` (content carries over as-is; image paths already resolve correctly one level up).
2. Copy any non-`.md` files from that lab folder into `code/<NN>_lab/`.
3. Append a `## Starter files` section to the chapter linking each copied file as `../code/<NN>_lab/<file>`.
4. Add the new chapter path to the `book.chapters` list in `_quarto.yml`.
5. `make html` to verify it renders and the starter-file links resolve.

## Toolchain change: Vivado → Anvil (this year)

The course switched off proprietary **Xilinx Vivado** to the open-source **[Anvil](https://logismith.github.io/Anvil/)** CLI (F4PGA = Yosys + VPR, `sv2v`, `openFPGALoader`; full user docs at [logismith.github.io/Docs](https://logismith.github.io/Docs/)) starting this academic year. The only board Anvil currently supports is the Digilent **Nexys A7 100T** — the same board the course already used, so no hardware change.

Practical consequence: **`chapters/01-tools-intro.qmd` was authored fresh, not mechanically migrated** — it replaced the old `01-vivado-guide.qmd` (Vivado install walkthrough, deleted) with an Anvil install guide plus a from-scratch intro to the digital design cycle. Its content came from `https://logismith.github.io/Anvil/` and `https://logismith.github.io/Docs/` (installation, supported-boards, getting-started, tutorials/blinky pages), not from `digital_design_labwork/`.

Later labs still reference Vivado-specific steps and Vivado-flavored `.xdc` syntax (e.g. `08_lab`'s `set_property -dict {...}` form) inherited from `digital_design_labwork/`. Expect to re-author those similarly, rather than mechanically migrate, wherever they depend on Vivado's GUI or its constraint-file conventions — check against the Anvil docs above before assuming a step still applies as written. The unused Vivado screenshots (`img/Step1.png` … `img/Step16.png`, `img/Screenshot 2024-09-18 *.png`) were left in `img/` since later chapters weren't checked for references to them.
