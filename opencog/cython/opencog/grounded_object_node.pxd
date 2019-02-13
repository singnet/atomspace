from libcpp.memory cimport shared_ptr
from cpython.object cimport PyObject

cdef extern from "opencog/atoms/execution/GroundedObject.h" namespace "opencog":
    cdef cppclass cGroundedObject "opencog::GroundedObject":
        pass

cdef extern from "PythonGroundedObject.h":
    cdef cppclass cPythonGroundedObject "opencog::PythonGroundedObject" (cGroundedObject):
        cPythonGroundedObject(PyObject* object)
        pass

cdef extern from "opencog/atoms/execution/GroundedObjectNode.h" namespace "opencog":
    cdef cppclass cGroundedObjectNode "opencog::GroundedObjectNode":
        pass

    ctypedef shared_ptr[cGroundedObjectNode] cGroundedObjectNodePtr "opencog::GroundedObjectNodePtr"

    cdef cGroundedObjectNodePtr cCreateGroundedObjectNode "createGroundedObjectNode" (...)
