import unittest
import re

from rprdcbl import pass_final_boundary, pass_initial_boundary, pass_boundary, is_failing, get_state
from rprdcbl.processing import _reset_all_for_testing_only
from . import tutils


class GeneralTests(unittest.TestCase):

    def testSingleSuccessfulRun(self):
        _reset_all_for_testing_only()
        pass_initial_boundary()
        pass_boundary()
        pass_final_boundary()
        self.assertFalse(is_failing())

    def testFailWithIllegalArguments(self):
        _reset_all_for_testing_only()
        with self.assertRaisesRegex(Exception, ".*callable.*"):
            pass_initial_boundary(custom_collect="string")
        _reset_all_for_testing_only()
        with self.assertRaisesRegex(Exception, ".*callable.*"):
            pass_initial_boundary(custom_test="string")

    def testCustomTesting(self):
        _reset_all_for_testing_only()
        pass_initial_boundary(
            custom_collect=lambda: True,
            custom_test=lambda l, p, r: "({}, {}, {})".format(l, p, r))
        pass_final_boundary()
        self.assertTrue(is_failing())
        self.assertTrue(
            re.match(".*\\(True, None, None\\).*",
                     get_state()["boundaries"][0]["results"][0]))
        self.assertTrue(
            re.match(".*\\(True, True, None\\).*",
                     get_state()["boundaries"][1]["results"][0]))
