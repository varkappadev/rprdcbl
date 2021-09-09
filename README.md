# Reproducibility Reports

This repository contains packages to collect information during R and
Python script execution to aid reproducibility (and possibly some
debugging).

For a detailed explanation and documentation see [`manual.adoc`](doc/manual.adoc).

Note: The manual is currently not included in the final packages.

## License

|Language|Path|License|Local LICENSE file|
|-|-|-|-|
|R package|src/R/**|GPL-2|LICENSE.GPL2|
|Python 3 package|src/py/**|Apache License Version 2.0|LICENSE.Apache-2.0|
|documentation|doc/**|CC-BY-SA-4.0|LICENSE.CCBYSA4|
|base documentation files|README.md CONTRIBUTING.md|CC-BY-SA-4.0|LICENSE.CCBYSA4|
|common files| in the root directory: Makefile |Apache License Version 2.0|LICENSE.Apache-2.0|

** indicates files below the given directory and its files, and any
subdirectories (recursively) and their files


## Considerations

**Why the weird name?**

I wanted to have the same package name for R and Python and it turned
out surprisingly difficult to find one.

**Why the different licenses?**

The licenses were chosen to fit with the typical licenses for their
respective languages. This makes it a little easier to integrate into
their larger ecosystems.

This file is licensed under the Creative Commons Attribution-ShareAlike
4.0 International License:
[http://creativecommons.org/licenses/by-sa/4.0/](http://creativecommons.org/licenses/by-sa/4.0/)
or [LICENSE.CCBYSA4](LICENSE.CCBYSA4).