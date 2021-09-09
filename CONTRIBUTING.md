# Contributing

## Building from Source 

The project contains a `Makefile` to generate the packages in their
language-specific package format, documentation, and tests as applicable.

## Code Conventions
Given the multi-language nature, some of the usual conventions do not apply.
Source files are largely named similarly between languages with functions 
placed in those files and named following the same pattern. Public functions 
use the same names and parameter names. Private methods follow language 
conventions to a larger degree:

- private variables are prefixed with `.` (R) or `_` (Python)
- some parameters use the `_` prefix if they represent the label of 
  another argument or if they are optional

Other coding guidelines are:

- no classes (except for unit tests if required or the use of builtin ones)
- no dependencies at runtime other than builtin packages
- use public APIs as much as possible (this is sometimes difficult or impossible
  as internal states need to be captured and the information is not exposed 
  through a public function)
- do not explicitly parallelize or use generators (Python) 
- return nothing explicitly if that is what is intended (`invisible(NULL)` or
  `return None`) to manage expectations

## Patches
If you wish to submit a patch, please make sure:

- it covers all languages with identical semantics
- it does not have any dependencies (other than builtin/core/base ones)
- identifier names use the language-specific conventions
- the code runs
- a test case is included if applicable.

This file is licensed under the Creative Commons Attribution-ShareAlike
4.0 International License
(http://creativecommons.org/licenses/by-sa/4.0/ or LICENSE.CCBYSA4).