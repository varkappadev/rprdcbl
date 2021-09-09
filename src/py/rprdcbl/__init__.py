from . import processing

__all__ = [
    "pass_initial_boundary", "pass_boundary", "pass_final_boundary"
]


def pass_initial_boundary(label=None,
                          quiet=True,
                          output_mode="pretty",
                          lock_file=None,
                          fail="never",
                          custom_collect=None,
                          custom_test=None):
    """Configures the system and collects information for the initial boundary."""
    processing._configure_testing(output_mode, lock_file, fail,
                                  custom_collect, custom_test)
    processing._process_boundary(label=label, quiet=quiet, final=False)
    return None


def pass_boundary(label=None, quiet=True):
    """Marks an intermediary boundary."""
    processing._process_boundary(label=label, quiet=quiet, final=False)
    return None


def pass_final_boundary(label=None, quiet=False):
    """Marks the final boundary and produces final output if request."""
    processing._process_boundary(label=label, quiet=quiet, final=True)
    return None


def get_state():
    """Returns a copy of the currently collected data.

    The returned data structure is a copy of the internal state and may change
    in future versions.
    """
    return processing._copy_state()


def is_failing():
    """Indicates whether reproducibility failure has been detected.

    This function may produce false negatives prior to the final boundary.
    """
    return processing._failure_detected(force=False)
