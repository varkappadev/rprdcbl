import unittest
from rprdcbl import pass_final_boundary, pass_initial_boundary, pass_boundary, is_failing
from rprdcbl.processing import _reset_all_for_testing_only
from . import tutils


class BoundaryTests(unittest.TestCase):

    def testSingleFailureOutput(self):
        _reset_all_for_testing_only()
        pass_initial_boundary(fail='never')
        tutils.load_dummy_module("ZZZZsingleFailureOutput")
        pass_boundary()
        pass_final_boundary()
        self.assertTrue(is_failing())

    def testSingleFailureError(self):
        _reset_all_for_testing_only()
        pass_initial_boundary(fail='late')
        tutils.load_dummy_module("ZZZZsingleFailureError")
        pass_boundary()
        self.assertTrue(is_failing())
        with self.assertRaisesRegex(Exception, ".*reproducibility.*"):
            pass_final_boundary()

    def testSingleFailureWithParsable(self):
        _reset_all_for_testing_only()
        pass_initial_boundary(fail='never', output_mode='parsable')
        pass_boundary()
        tutils.load_dummy_module("ZZZZsingleFailureWithParsable")
        pass_final_boundary()
        self.assertTrue(is_failing())
