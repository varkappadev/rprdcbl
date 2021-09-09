.SUFFIXES: ;
.PHONY: prepare package clean test lint coverage format set_version documentation;
APIPDF:=API.pdf

BASEPKG?=rprdcbl
VERSION?=0.0.1

RCALL:=R --vanilla --no-environ --quiet -e

R_PAPERSIZE:=a4
export R_PAPERSIZE

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

export LANG LC_CTYPE LC_ALL LANGUAGE
unexport LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME
unexport LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION

package: R tests documentation Makefile prepare
	${RCALL} 'devtools::build(binary = FALSE, path = ".", manual = TRUE)'

clean:
	-rm -rf inst
	-rm -rf man
	-rm -f doc/*.pdf
	-rm -f ${APIPDF}
	-rm -f ${BASEPKG}_*.tar.gz

test: prepare
	${RCALL} 'devtools::test()'
	${RCALL} 'devtools::check(quiet = FALSE, remote = FALSE, incoming = FALSE, error_on = "never")'

lint: prepare
	# disable useless and unhelpful linters
	# styles = c("dotted.case", "lowercase"), 
	-${RCALL} 'devtools::lint(pkg = ".", cache = FALSE, linters = lintr::with_defaults(object_name_linter = NULL, snake_case_linter = NULL, single_quotes_linter = NULL, multiple_dots_linter = NULL, line_length_linter = lintr::line_length_linter(120), trailing_blank_lines_linter = NULL, trailing_whitespace_linter = NULL, object_usage_linter = NULL))'

coverage: prepare
	${RCALL} 'covr::package_coverage()'
	${RCALL} 't <- covr::tally_coverage(covr::package_coverage()); print(t[t$$value < 1, ])'

documentation:
	${RCALL} 'devtools::document()'

${APIPDF}: prepare
	rm -f "$@"
	R CMD Rd2pdf --batch --no-preview --force --output="$@" .

format: prepare
	${RCALL} 'formatR::tidy_dir("R", comment = TRUE, blank = TRUE, arrow = TRUE, wrap = TRUE, brace.newline = FALSE, indent = 4, width.cutoff = 72)'

prepare: set_version;

set_version:
	sed -i.bak -e 's#^Version:.*$$#Version: ${VERSION}#' "DESCRIPTION"

