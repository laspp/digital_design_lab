.PHONY: all html pdf preview render clean check

all: render

# Render every configured format (html + pdf, per _quarto.yml)
render:
	quarto render

# Render HTML only
html:
	quarto render --to html

# Render PDF only (uses tectonic, see _quarto.yml)
pdf:
	quarto render --to pdf

# Live-reloading local preview server
preview:
	quarto preview

# Verify Quarto + engines + dependencies are correctly installed
check:
	quarto check

# Remove rendered output
clean:
	rm -rf _book .quarto index_files site_libs chapters/*_files
