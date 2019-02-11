from cpython.ref cimport Py_INCREF, Py_DECREF

cdef class PtrValue(Value):

    def __init__(self, obj = None, ptr_holder = None):
        if ptr_holder is not None:
            super(PtrValue, self).__init__(ptr_holder)
            return

        Py_INCREF(obj)
        cvalue = createPtrValue(<void*>obj, decref)
        super(PtrValue, self).__init__(PtrHolder.create(<shared_ptr[void]&>cvalue))

    def value(self):
        return <object>((<cPtrValue*>self.get_c_value_ptr().get()).value())

cdef void decref(void* obj):
    Py_DECREF(<object>obj)

def valueToPtrValue(value):
    return PtrValue(ptr_holder = (<Value>value).ptr_holder)
