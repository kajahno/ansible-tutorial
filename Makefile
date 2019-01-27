# Minimal makefile for Sphinx documentation
#

# You can set these variables from the command line.
SPHINXOPTS    =
SPHINXBUILD   = sphinx-build
SOURCEDIR     = source
BUILDDIR      = build
CURRENT_DATE  ?= date -u "+%b %d, %Y"

# Put it first so that "make" without argument is like "make help".
help:
	@$(SPHINXBUILD) -M help "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

clean:
	${INFO} "Cleaning $(BUILDDIR)..."
	-rm -rf docs
	-rm -rf $(BUILDDIR)/doctrees
	-rm -rf $(BUILDDIR)/singlehtml
	-rm -rf $(SOURCEDIR)/_themes/sphinx_rtd_theme/footer.html
	-rm -rf $(SOURCEDIR)/_themes/sphinx_rtd_theme/layout.html

build: clean
	${INFO} "Building project..."
	sed 's/PLC_LAST_UPDATED/$(shell $(CURRENT_DATE))/g' $(SOURCEDIR)/_themes/sphinx_rtd_theme/footer.html.template > $(SOURCEDIR)/_themes/sphinx_rtd_theme/footer.html
	sed 's/PLC_LAST_UPDATED/$(shell $(CURRENT_DATE))/g' $(SOURCEDIR)/_themes/sphinx_rtd_theme/layout.html.template > $(SOURCEDIR)/_themes/sphinx_rtd_theme/layout.html
	@$(SPHINXBUILD) -M html "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)
	${INFO} "Copying generate html to 'docs' and tidy up filenames..."
	@mv $(BUILDDIR)/html docs
	@mv docs/_images docs/images
	@find docs -type f -regex '.*\.html\|.*\.js' -print0 | xargs -0 sed -i 's/_images/images/g'
	@mv docs/_sources docs/sources
	@find docs -type f -regex '.*\.html\|.*\.js' -print0 | xargs -0 sed -i 's/_sources/sources/g'
	@mv docs/_static docs/static
	@find docs -type f -regex '.*\.html\|.*\.js' -print0 | xargs -0 sed -i 's/_static/static/g'
	${INFO} "Build finished"



.PHONY: help Makefile clean build

# Catch-all target: route all unknown targets to Sphinx using the new
# "make mode" option.  $(O) is meant as a shortcut for $(SPHINXOPTS).
%: Makefile
	${INFO} "Building goal ${@}..."
	@$(SPHINXBUILD) -M $@ "$(SOURCEDIR)" "$(BUILDDIR)" $(SPHINXOPTS) $(O)

# Cosmetics
YELLOW := "\e[1;33m"
NC := "\e[0m"

# Shell Functions
INFO := @bash -c '\
	printf $(YELLOW); \
	echo "=> $$1"; \
	printf $(NC)' VALUE

