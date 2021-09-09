from . import configuration
from . import collectors
from . import testers
from . import printers
import os.path
import pickle
import copy

_data = dict()


def _reset_data():
    global _data
    _data.clear()
    _data.update(failing=False,
                 boundaries=list(),
                 reference=None,
                 finalized=False)
    return None


def _failure_detected(force=False):
    global _data
    indicator = _data["failing"]
    return indicator is not None and (indicator if isinstance(
        indicator, bool) else any(indicator))


def _copy_state():
    global _data
    return dict(boundaries=copy.deepcopy(_data["boundaries"]),
                reference=copy.deepcopy(_data["reference"]),
                failing=_failure_detected(force=False))


def _collect(label=None, final=False):
    global _data
    boundary_number = len(_data["boundaries"]) + 1
    if label is None:
        if final:
            label = "FINAL"
        elif boundary_number == 1:
            label = "INITIAL"
        else:
            label = "BOUNDARY{}".format(boundary_number)
    boundary_data = {
        name: collector()
        for name, collector in configuration._cget(
            "collectors").items()
    }
    boundary_summary = dict(label=label,
                            number=boundary_number,
                            final=final,
                            data=boundary_data)
    _data["boundaries"].append(boundary_summary)
    return boundary_summary


def _select(d, *k):
    if d is None:
        return None
    elif k is None:
        return None
    elif len(k) == 0:
        return None
    elif len(k) == 1:
        return d.get(k[0])
    else:
        return _select(d.get(k[0]), *k[1:])


def _test():
    global _data
    if _data["boundaries"] is None or len(_data["boundaries"]) < 1:
        return None
    for b in range(0, len(_data["boundaries"])):
        results = list()
        latest = _data["boundaries"][b]
        if "results" in latest.keys():
            continue
        previous = _data["boundaries"][b - 1] if (b > 0) else None
        if _data["reference"] is None:
            reference = None
        elif len(_data["reference"]) - 1 >= b:
            reference = _data["reference"][b]
        else:
            results.append(
                "The boundary #{} does not have a corresponding " +
                "boundary in the reference boundary.".format(b + 1))
            reference = None
        if reference is not None and not (latest["label"]
                                          == reference.get("label")):
            results.append(
                ("The label for boundary #{} does not match the " +
                 "reference value ('{}' != '{}').").format(
                     str(b + 1), latest["label"], reference["label"]))
        testers = configuration._cget("testers")
        latest_type = "initial" if b == 0 else "default"
        for test in testers.keys():
            test_fun = testers[test]
            test_results = test_fun(_select(latest, "data", test),
                                    _select(previous, "data", test),
                                    _select(reference, "data", test),
                                    _name=test,
                                    _latest_type=latest_type)
            if isinstance(test_results, str):
                results.append(test_results)
            elif isinstance(test_results, list):
                results.extend(test_results)
            elif test_results is not None:
                raise Exception(
                    "An unexpected test result was found for {}".format(
                        test))
        _data["boundaries"][b].update({
            "results": [
                result for result in results
                if result is not None and len(result) > 0
            ]
        })
    _data["failing"] = any([
        len(boundary.get("results", [])) > 0
        for boundary in _data["boundaries"]
    ])
    return None


def _noop(*args):
    return None


def _self_or_noop(fun, name="fun"):
    if fun is None:
        return _noop
    elif callable(fun):
        return fun
    else:
        raise Exception("`{}` must be callable.".format(name))


def _check_state(fail=True):
    if "a81c87e5-1f5d-44c9-8c5f-eada05868816" == configuration._cget(
            "__MAGIC", ""):
        return True
    elif fail:
        raise Exception("Invalid state or uninitialized package.")
    else:
        return False


def _load_lock_file():
    fname = configuration._cget("lock_file")
    if fname is None or not os.path.exists(fname):
        return None

    with open(fname, "rb") as fh:
        loaded_data = pickle.load(fh)
    if not isinstance(loaded_data, dict):
        raise Exception("Unexpected data in lock file.")
    global _data
    _data["reference"] = loaded_data["boundaries"]
    return None


def _save_lock_file():
    global _data
    fname = configuration._cget("lock_file")
    if _failure_detected(force=True):
        return None
    if not _data["finalized"]:
        raise Exception(
            "The lock file cannot be saved prior to finalization.")
    if fname is None or os.path.exists(fname):
        return None
    if _data["reference"] is not None:
        return None
    save_data = dict(boundaries=_data["boundaries"])
    with open(fname, "wb") as fh:
        pickle.dump(save_data, fh, protocol=pickle.HIGHEST_PROTOCOL)
    return None


def _configure_testing(output_mode="pretty",
                       lock_file=None,
                       failing="never",
                       custom_collect=None,
                       custom_test=None):
    if output_mode not in {"pretty", "parsable"}:
        raise Exception("`{}` is not a valid output mode.".format(
            str(output_mode)))
    if failing not in {"never", "early", "late"}:
        raise Exception("`{}` is not a valid failing mode.".format(
            str(failing)))
    if _check_state(fail=False):
        raise Exception(
            "Cannot configure pre-configured package. " +
            "Restart the interpreter to run the script again.")

    _reset_data()
    configuration._cset("__MAGIC",
                        "a81c87e5-1f5d-44c9-8c5f-eada05868816")
    configuration._cset("output_mode", output_mode)
    configuration._cset("failing", failing)
    configuration._cset("lock_file", lock_file)
    configuration._cset("custom_collect",
                        _self_or_noop(custom_collect, "custom_collect"))
    configuration._cset("custom_test",
                        _self_or_noop(custom_test, "custom_test"))

    _collectors = collectors._default_collectors()
    _collectors["custom"] = configuration._cget("custom_collect")
    _testers = testers._default_testers()
    _testers["custom"] = testers._custom_test_wrapper
    configuration._cset("collectors", _collectors)
    configuration._cset("testers", _testers)

    _load_lock_file()
    return None


def _process_boundary(label=None, quiet=True, final=True):
    _check_state()
    global _data
    if _data["finalized"]:
        raise Exception("Final boundary already reached.")
    _collect(label=label, final=final)
    _test()
    if final:
        _data["finalized"] = True
        _save_lock_file()
    if not quiet:
        boundary_number = len(_data["boundaries"])
        if boundary_number < 1:
            raise Exception("Unexpected state detected.")
        printers._print_report(
            range(1, boundary_number) if final else boundary_number,
            boundaries=_data["boundaries"],
            mode=configuration._cget("output_mode"))
    fail_now = ("early" == configuration._cget("failing")) or \
               (final and ("never" != configuration._cget("failing")))
    if fail_now and _failure_detected(force=True):
        raise Exception("A reproducibility error has been detected.")
    return None


def _reset_all_for_testing_only():
    global _data
    _data.clear()
    configuration._configuration.clear()
    return None
