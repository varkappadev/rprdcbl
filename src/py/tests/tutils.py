import types
import sys


def load_dummy_module(name):
    mod = types.ModuleType(name, "Dummy Module {}".format(name))
    mod.__dict__.update({
        "name": name,
        "__version__": "0",
        "__is_DUMMY_module__": True
    })
    sys.modules.update({name: mod})
    return name


def unload_dummy_module(name):
    if getattr(getattr(sys.modules, name, None), "__is_DUMMY_module__",
               False):
        del sys.modules[name]
        return name
    return None
