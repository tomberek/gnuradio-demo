/* -*- c++ -*- */

#define HOWTO_API

%include "gnuradio.i"			// the common stuff

//load generated python docstrings
%include "howto_swig_doc.i"

%{
#include "howto/gain_cpp.h"
%}

%include "howto/gain_cpp.h"
GR_SWIG_BLOCK_MAGIC2(howto, gain_cpp);
