# Default Snakemake options. Change here or override by setting
# an environment variable as needed.
SNAKEMAKEOPTS   ?= -c1 --use-conda


# Local vars
TEMPORARIES      = src/ms.pdf src/__latexindent*.tex
CONDA           := $(shell conda -V 2&> /dev/null && echo 1 || echo 0)
SNAKEMAKE       := $(shell snakemake -v 2&> /dev/null && echo 1 || echo 0)
SHOWYOURWORK    := $(shell test -f showyourwork/LICENSE && echo 1 || echo 0)
.PHONY: ms.pdf clean report dag snakemake_setup conda_setup showyourwork_setup Makefile


# Default target: generate the article
ms.pdf: snakemake_setup showyourwork_setup
	@snakemake $(SNAKEMAKEOPTS) ms.pdf


# Ensure conda is setup
conda_setup:
	@if [ "$(CONDA)" = "0" ]; then \
		echo "Conda package manager not found. Please install it from anaconda.com/products/individual.";\
		false;\
	fi


# Ensure Snakemake is setup
snakemake_setup: conda_setup
	@if [ "$(SNAKEMAKE)" = "0" ]; then \
		echo "Snakemake not found. Installing it using conda...";\
		conda install -c defaults -c conda-forge -c bioconda mamba snakemake;\
	fi


# Ensure we've cloned the showyourwork submodule
showyourwork_setup:
	@if [ "$(SHOWYOURWORK)" = "0" ]; then \
		echo "Setting up the showyourwork submodule...";\
		git submodule init;\
		git submodule update;\
	fi

# Remove all intermediates, outputs, and temporaries
clean: snakemake_setup showyourwork_setup
	@snakemake $(SNAKEMAKEOPTS) ms.pdf --delete-all-output
	@rm -rf $(TEMPORARIES)


# Generate a workflow report
report: snakemake_setup showyourwork_setup
	@snakemake $(SNAKEMAKEOPTS) ms.pdf --report


# Generate a workflow directed acyclic graph (DAG)
dag: snakemake_setup showyourwork_setup
	@snakemake $(SNAKEMAKEOPTS) ms.pdf --dag | dot -Tpdf > dag.pdf


# Catch-all target: route all unknown targets to Snakemake
%: Makefile snakemake_setup showyourwork_setup
	@snakemake $(SNAKEMAKEOPTS) $@
