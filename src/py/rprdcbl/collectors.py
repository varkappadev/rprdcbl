import sys
import platform
import types
import re
import os


def _collect_globals():
    """Collects 'global' variable names."""
    main = sys.modules['__main__']
    return sorted([
        k for k in dir(main)
        if not isinstance(getattr(main, k), types.ModuleType)
    ])


def _collect_version():
    """Collects version information."""
    fields = ["major", "minor", "micro", "releaselevel", "serial"]
    return {k: getattr(sys.version_info, k, None) for k in fields}


def _collect_os():
    """Returns the operating system identifier."""
    return platform.platform()


def _collect_platform():
    """Returns the platform (machine information)."""
    return platform.machine()


def _collect_environment():
    """Returns 'Python' as an identifier."""
    return "Python"


def _collect_variant():
    """Returns the implementation variant."""
    return sys.implementation.name


def _collect_modules():
    """Returns a list of loaded modules and their versions."""
    return {
        k: str(getattr(v, "__version__", ""))
        for k, v in sys.modules.items()
    }


def _collect_lapack():
    """Returns scipy's loaded LAPACK version."""
    if "scipy.linalg.lapack" in sys.modules:
        import scipy.linalg.lapack
        return list(scipy.linalg.lapack.ilaver())
    else:
        return list()


def _collect_prng():
    """Returns the state of the `random` PRNG."""
    if "random" in sys.modules:
        import random
        return random.getstate()
    else:
        return list()


def _collect_locale():
    """Returns the state of locale as configured by the local environment (LANG, LANGUAGE, LC_*) """
    values = dict()
    for k in os.environ:
        if k == "LANG" or k == "LANGUAGE" or re.match("^LC_[A-Z]+$", k):
            values[k] = os.environ[k]
    return values


def _default_collectors():
    """Returns a dict of all default data collectors."""
    return dict(environment=_collect_environment,
                variant=_collect_variant,
                version=_collect_version,
                platform=_collect_platform,
                os=_collect_os,
                modules=_collect_modules,
                locale=_collect_locale,
                LAPACK=_collect_lapack,
                PRNG=_collect_prng,
                global_names=_collect_globals)
