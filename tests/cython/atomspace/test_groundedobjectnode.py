import unittest

from opencog.atomspace import AtomSpace
from opencog.utilities import initialize_opencog, finalize_opencog
from opencog.type_constructors import (GroundedObjectNode,
                                       SnetExecutionOutputLink, DotLink,
                                       ListLink, ConceptNode)
from opencog.bindlink import execute_atom

class GroundedObjectNodeTest(unittest.TestCase):

    def setUp(self):
        self.space = AtomSpace()
        initialize_opencog(self.space)

    def tearDown(self):
        finalize_opencog()
        del self.space

    def test_call_grounded_object_predicate(self):
        grounded_object_node = GroundedObjectNode("test_grounded_object_node",
                                                  TestObject("some object"))
        exec_link = SnetExecutionOutputLink(
                        DotLink(grounded_object_node, ConceptNode("foo")),
                        ListLink(ConceptNode("arg"))
                        )

        result = execute_atom(self.space,  exec_link)

        self.assertEqual(result, ConceptNode("arg"))

class TestObject:
    def __init__(self, name):
        self.name = name
    def foo(self, args):
        return args.out[0]

if __name__ == '__main__':
    unittest.main()