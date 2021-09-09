import unittest
import copy
from rprdcbl import pass_final_boundary, pass_initial_boundary, pass_boundary, is_failing, get_state
from rprdcbl.processing import _reset_all_for_testing_only
from rprdcbl.testers import _deep_equality_test
from . import tutils


class IndividualTests(unittest.TestCase):

    def expect_equal_deep_compare(self,
                                  x,
                                  y,
                                  expect=True,
                                  name="custom"):
        xyy_result = _deep_equality_test(x,
                                         y,
                                         y,
                                         _latest_type="initial",
                                         _name=name)
        xyn_result = _deep_equality_test(x,
                                         y,
                                         None,
                                         _latest_type="initial",
                                         _name=name)
        xny_result = _deep_equality_test(x,
                                         None,
                                         y,
                                         _latest_type="initial",
                                         _name=name)

        self.assertEqual(len(xyn_result), len(xny_result))
        if expect:
            self.assertEqual(len(xyy_result), 0)
        else:
            self.assertNotEqual(len(xyy_result), 0)

    def testIntegratedDataStructureComparison(self):
        _reset_all_for_testing_only()
        cds_orig = dict(
            data=dict(a=1, b="b", c=range(1, 5), e=list(), f=None, g=1))
        cds = copy.deepcopy(cds_orig)
        self.expect_equal_deep_compare(cds, None)
        self.expect_equal_deep_compare(cds, cds_orig)

        cds = copy.deepcopy(cds_orig)
        cds["data"]["a"] = "a"
        self.expect_equal_deep_compare(cds, cds_orig, expect=False)

        cds = copy.deepcopy(cds_orig)
        cds["data"]["b"] = "B"
        self.expect_equal_deep_compare(cds, cds_orig, expect=False)

        cds = copy.deepcopy(cds_orig)
        cds["data"]["e"] = [True]
        self.expect_equal_deep_compare(cds, cds_orig, expect=False)

        cds = copy.deepcopy(cds_orig)
        cds["data"]["f"] = 0
        self.expect_equal_deep_compare(cds, cds_orig, expect=False)

        cds = copy.deepcopy(cds_orig)
        cds["data"]["g"] = [None]
        self.expect_equal_deep_compare(cds, cds_orig, expect=False)
