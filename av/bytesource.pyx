from cpython.buffer cimport PyObject_CheckBuffer, PyObject_GetBuffer, PyBUF_SIMPLE, PyBuffer_Release


cdef class ByteSource(object):

    def __cinit__(self, owner):
        self.owner = owner

        try:
            self.ptr = owner
        except TypeError:
            pass
        else:
            self.length = len(owner)
            return

        if PyObject_CheckBuffer(owner):
            res = PyObject_GetBuffer(owner, &self.view, PyBUF_SIMPLE)
            if not res:
                self.has_view = True
                self.ptr = <unsigned char *>self.view.buf
                self.length = self.view.len
                return
        
        raise TypeError('expected bytes, bytearray or memoryview')

    def __dealloc__(self):
        if self.has_view:
            PyBuffer_Release(&self.view)


cdef ByteSource bytesource(obj, bint allow_none=False):
    if allow_none and obj is None:
        return
    elif isinstance(obj, ByteSource):
        return obj
    else:
        return ByteSource(obj)

