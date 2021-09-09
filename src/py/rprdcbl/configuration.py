_configuration = dict()


def _cget(key, default=None):
    """Returns a configuration key or the default value."""
    global _configuration
    return _configuration.get(key, default)


def _cset(key, value=None):
    """Sets a configuration key."""
    global _configuration
    _configuration.update({key: value})
    return value
