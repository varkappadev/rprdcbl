from . import configuration
from . import collectors
from . import util


def _deep_equality_test(latest,
                        previous,
                        reference,
                        _latest_type="latest",
                        _name="",
                        _ignore_previous=False,
                        _ignore_reference=False):
    """Compares the latest data to the previous and reference data."""
    _name = _name or ""
    if _ignore_previous:
        previous_results = list()
    else:
        previous_results = list(
            util.__deep_compare(latest,
                                previous,
                                _x=_latest_type,
                                _y="previous",
                                _prefix=_name) or list())
    if _ignore_reference:
        reference_results = list()
    else:
        reference_results = list(
            util.__deep_compare(latest,
                                reference,
                                _x=_latest_type,
                                _y="reference",
                                _prefix=_name) or list())
    return previous_results + reference_results


def _deep_lr_equality_test(latest,
                           previous,
                           reference,
                           _latest_type="latest",
                           _name=""):
    """Compares the latest data to the reference data."""
    return _deep_equality_test(latest=latest,
                               previous=previous,
                               reference=reference,
                               _latest_type=_latest_type,
                               _name=_name,
                               _ignore_previous=True)


def _custom_test_wrapper(latest,
                         previous,
                         reference,
                         _latest_type="latest",
                         _name="",
                         _fun=None):
    """Special wrapper for the custom test function."""
    _name = _name or ""
    if _fun is None:
        _fun = configuration._cget("custom_test")

    if _fun is None:
        return list()
    else:
        result = _fun(latest, previous, reference)
        if not (result is None or isinstance(result, list)
                or isinstance(result, str)):
            result = "The custom test function returned a value of unexpected type."
        return result


def _default_testers():
    """Returns all default testing functions."""
    testers = {
        k: _deep_equality_test
        for k in collectors._default_collectors().keys()
    }
    testers["PRNG"] = _deep_lr_equality_test
    testers["global_names"] = _deep_lr_equality_test
    return testers
