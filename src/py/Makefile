.SUFFIXES: ;
.PHONY: prepare package clean test lint coverage format set_version ;

BASEPKG?=rprdcbl
VERSION?=0.0.1

ifeq (${OS},Darwin)
LANG:=C
LANGUAGE:=C
LC_ALL:=C
LC_CTYPE:=UTF-8
else
LANG:=C.UTF-8
LANGUAGE:=C
LC_ALL:=C.UTF-8
LC_CTYPE:=C.UTF-8
endif

ifeq (, $(shell which yapf3))
YAPF:=yapf
else 
YAPF:=yapf3
endif 

export LANG LC_CTYPE LC_ALL LANGUAGE
unexport LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME
unexport LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION

package: prepare test 
	python3 -m setup bdist_wheel --owner root --group root 
	-rm -rf build ${BASEPKG}.egg-info .coverage

clean:
	python3 -m setup clean --all
	rm -rf dist ${BASEPKG}.egg-info ${BASEPKG}*.tar.gz .coverage doc/*.pdf
	find . -depth -type d -iname __pycache__ -exec rm -rf '{}' ';'

test: coverage ;

coverage: prepare package
	tox -e coverage

lint: prepare
	pylama 

format: prepare
	${YAPF} --in-place --recursive --verbose ${BASEPKG} tests

prepare: set_version;

set_version:
	[ -f "setup.cfg" ] && sed -i.bak -e "s#^ *version *=.*#version = ${VERSION}#" "setup.cfg"
