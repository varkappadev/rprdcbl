def __deep_compare(x, y, _x="observed", _y="expected", _prefix=""):
    """Comparses two values including subfields.

    Parameters:
    _x - the name of the first value ("initial", "latest", etc.)
    _y - the name of the second value ("reference" is used as a special label
         for the benchmark variable)
    _prefix - the field the two values belong to (dot-separated)
    """
    if x == y:
        return None
    if y is None and "reference" == _y and not ("." in _prefix):
        return None
    if y is None and "initial" == _x and not ("." in _prefix):
        return None
    _nnn_message = "The {} value for '{}' is None but the {} value is not."
    if y is None and x is not None:
        return _nnn_message.format(_y, _prefix, _x)
    if x is None:
        return _nnn_message.format(_x, _prefix, _y)
    if type(x) != type(y):
        return "Mismatching classes for {} and {} of '{}'.".format(
            _x, _y, _prefix)
    result = list()
    __list_extras_message = "Elements in '{}' only contained in the {} dictionary (but not in the {}): {}"
    if isinstance(x, dict):
        x_only_keys = x.keys() - y.keys()
        y_only_keys = y.keys() - x.keys()
        shared_keys = x.keys() & y.keys()
        if len(x_only_keys) > 0:
            result.append(
                __list_extras_message.format(_prefix, _x, _y,
                                             ", ".join(x_only_keys)))
        if len(y_only_keys) > 0:
            result.append(
                __list_extras_message.format(_prefix, _y, _x,
                                             ", ".join(y_only_keys)))
        for key in shared_keys:
            element_results = __deep_compare(x[key], y[key], _x, _y,
                                             _prefix + "." + key)
            if isinstance(element_results, str):
                element_results = [element_results]
            if element_results is not None:
                result.extend(element_results)
        return [r for r in result if r is not None]
    return "The values of '{}' differ.".format(_prefix)
