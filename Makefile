#!/usr/bin/env make

# This file is licensed under the Apache License Version 2.0
# See LICENSE.Apache-2.0 for the full text.
#
# Copyright (c) 2021, J. Tobias Hahn 
# All rights reserved.

OS?=$(shell uname)
SOURCE_DATE_EPOCH?=$(shell date '+%s')
SRC_PREFIX:=src/
SRC_PY:=$(SRC_PREFIX)py
SRC_R:=$(SRC_PREFIX)R

BASEPKG:=rprdcbl
ifeq ($(origin VERSION), undefined)
	ifeq ($(shell git-count >/dev/null 2>/dev/null ; echo $$?), "0")
		VERSION:=$(shell git describe --tags --dirty=-dev)
	endif
endif

LANG:=C.UTF-8
LANGUAGE:=C
LC_ALL:=C.UTF-8
LC_CTYPE:=C.UTF-8

ifeq (${OS},Darwin)
VERSION:=$(shell date -j -f "%s" "${SOURCE_DATE_EPOCH}" '+0.0.%Y%m%d%H%M')
SOURCE_DATE_8601:=$(shell date -u -j -f "%s" "${SOURCE_DATE_EPOCH}" "+%Y-%m-%dT%H:%M:%S")
LANG:=C
LANGUAGE:=C
LC_ALL:=C
LC_CTYPE:=UTF-8
else
VERSION:=$(shell date "--date=@${SOURCE_DATE_EPOCH}" '+0.0.%Y%m%d%H%M')
SOURCE_DATE_8601:=$(shell date --utc "--date=@${SOURCE_DATE_EPOCH}" --iso-8601=seconds)
endif

BASEPKG?=$(shell basename $$(readlink -f .))

export SOURCE_DATE_EPOCH
export VERSION

export LANG LC_CTYPE LC_ALL LANGUAGE
unexport LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME
unexport LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION

LTARGETS:=clean package test coverage format lint
.PHONY: all prepare set_version documentation \
		${LTARGETS} $(addsuffix .py, ${LTARGETS}) $(addsuffix .R, ${LTARGETS}) ;

.SUFFIXES: ;


define set_version_to
    bash -c '[[ "$1" =~ ^[0-9]+[0-9.]*$$ ]]' && ([ -f "doc/manual.adoc" ] && sed -i.bak -e "s#^Version.*#Version $1#" "doc/manual.adoc")
endef

all: package ;

info:
	@echo 'Building package: ${BASEPKG}'
	@echo 'Source date:      ${SOURCE_DATE_EPOCH} (${SOURCE_DATE_8601})'
	@echo 'Version:          ${VERSION}'
	@echo 'Build dependencies:'
	@echo '    python3 (coverage, tox, yapf)'
	@echo '    R (devtools, formatR, covr, lintr)'
	@echo '    pylama'
	@echo '    asciidoctor-pdf'
	@bash -c 'echo LC_ALL: $${LC_ALL}'
	@bash -c 'echo LC_PAPER: $${LC_PAPER:-not set}'

# CL/LI Targets

set_version:
	$(call set_version_to,${VERSION})

prepare: set_version;

documentation: doc/manual.pdf prepare set_version ;
	mkdir -p ${SRC_R}/doc ${SRC_PY}/doc


clean.R: 
	$(MAKE) -C "${SRC_R}" clean

clean.py: 
	$(MAKE) -C "${SRC_PY}" clean

clean: clean.py clean.R
	$(call set_version_to,0.0.1)
	rm -f doc/manual.pdf
	$(MAKE) -C "${SRC_PY}" set_version "VERSION=0.0.1"
	$(MAKE) -C "${SRC_R}" set_version "VERSION=0.0.1"


package.R: prepare documentation
	$(MAKE) -C "${SRC_R}" package

package.py: prepare documentation
	$(MAKE) -C "${SRC_PY}" package

package: package.R package.py ;


test.R: prepare set_version documentation
	$(MAKE) -C "${SRC_R}" test

test.py: prepare set_version documentation
	$(MAKE) -C "${SRC_PY}" test

test: test.R test.py ;


coverage.R: prepare set_version
	$(MAKE) -C "${SRC_R}" coverage

coverage.py: prepare set_version documentation
	$(MAKE) -C "${SRC_PY}" coverage

coverage: coverage.R coverage.py ;


lint.R: prepare
	$(MAKE) -C "${SRC_R}" lint

lint.py: prepare
	$(MAKE) -C "${SRC_PY}" lint

lint: lint.R lint.py ;


format.R: prepare
	$(MAKE) -C "${SRC_R}" format

format.py: prepare
	$(MAKE) -C "${SRC_PY}" format

format: format.R format.py ;

# filetype-based rules

%.pdf: %.adoc prepare
	cd "$(@D)" && asciidoctor-pdf -a reproducible "$(<F)"

%.pdf: %.tex prepare
	cd "$(@D)" && latexmk -quiet -gg -lualatex "$(<F)" && latexmk -quiet -c -lualatex "$(<F)"
