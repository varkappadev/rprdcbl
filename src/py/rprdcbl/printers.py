def _escape_dquote(s):
    """Escapes double-quotes."""
    return str(s).replace("\"", "\\\"") if s is not None else None


def _formatter_pretty(boundary):
    """Converts boundary error information to human-readable message strings."""
    if boundary is None:
        return None
    if boundary["results"] is None or len(boundary["results"]) == 0:
        return None
    return "Boundary \"{}\" (#{}): {}".format(
        boundary["label"], boundary["number"],
        "  \n".join(boundary["results"]))


def _formatter_parsable(boundary):
    """Converts boundary error information to a parsable string."""
    if boundary is None:
        return None
    if boundary["results"] is None or len(boundary["results"]) == 0:
        return None
    return [
        "E: B={} L=\"{}\" C=\"{}\"".format(boundary["number"],
                                           boundary["label"],
                                           _escape_dquote(result))
        for result in boundary["results"] if result is not None
    ]


def _print_report(b=None, boundaries=None, mode="pretty"):
    """Prints boundary error information to stdout.

    Caputres all `b` boundaries from `boundaries` or the global default
    to message strings using the given mode ('pretty', or 'parsable' otherwise)
    and prints it to stdout using `print`.
    """
    if boundaries is None:
        return list()
    if b is None:
        b = len(boundaries)
    if mode == "pretty":
        formatter = _formatter_pretty
    else:
        formatter = _formatter_parsable
    # do not combine the following lines (for easier debugging)
    items = [formatter(boundaries[n - 1]) for n in b]
    items = [item for item in items if item is not None]
    for item in items:
        print(item)
