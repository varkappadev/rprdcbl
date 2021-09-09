import unittest
import tempfile
import os
from rprdcbl import pass_final_boundary, pass_initial_boundary, pass_boundary, is_failing
from rprdcbl.processing import _reset_all_for_testing_only
from . import tutils


class ReplicationTests(unittest.TestCase):

    def setUp(self):
        # use the deprecated function as it is only needed for testing and
        # the use of an actual file _name_ is to be simulated
        self.lock_file_name = tempfile.mktemp()

    def tearDown(self):
        try:
            os.remove(self.lock_file_name)
        except:
            pass

    def testReplicationRun(self):
        self.assertFalse(os.path.exists(self.lock_file_name))
        _reset_all_for_testing_only()
        pass_initial_boundary(lock_file=self.lock_file_name,
                              fail='never')
        pass_boundary()
        pass_final_boundary()
        self.assertFalse(is_failing())
        self.assertTrue(os.path.exists(self.lock_file_name))

        _reset_all_for_testing_only()
        pass_initial_boundary(lock_file=self.lock_file_name,
                              fail='never')
        pass_boundary()
        pass_final_boundary()
        self.assertFalse(is_failing())
        self.assertTrue(os.path.exists(self.lock_file_name))

        _reset_all_for_testing_only()
        pass_initial_boundary(lock_file=self.lock_file_name,
                              fail='never')
        pass_boundary()
        pass_boundary()
        pass_final_boundary()
        self.assertTrue(is_failing())
        self.assertTrue(os.path.exists(self.lock_file_name))
