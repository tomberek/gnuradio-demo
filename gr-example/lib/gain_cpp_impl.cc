/* -*- c++ -*- */
/* 
 * Copyright 2018 Tom Bereknyei.
 * 
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

#ifdef HAVE_CONFIG_H
#include "config.h"
#endif

#include <gnuradio/io_signature.h>
#include "gain_cpp_impl.h"

namespace gr {
  namespace howto {

    gain_cpp::sptr
    gain_cpp::make(float gain)
    {
      return gnuradio::get_initial_sptr
        (new gain_cpp_impl(gain));
    }

    /*
     * The private constructor
     */
    gain_cpp_impl::gain_cpp_impl(float gain)
      : gr::sync_block("gain_cpp",
              gr::io_signature::make(1, 1, sizeof(gr_complex)),
              gr::io_signature::make(1, 1, sizeof(gr_complex))),
      d_gain(gain)
    {}

    /*
     * Our virtual destructor.
     */
    gain_cpp_impl::~gain_cpp_impl()
    {
    }

    int
    gain_cpp_impl::work(int noutput_items,
        gr_vector_const_void_star &input_items,
        gr_vector_void_star &output_items)
    {
      const gr_complex *in = (const gr_complex *) input_items[0];
      gr_complex *out = (gr_complex *) output_items[0];
      for(int i=0;i<noutput_items;i++){
          out[i] = in[i] * d_gain;
      }

      // Do <+signal processing+>

      // Tell runtime system how many output items we produced.
      return noutput_items;
    }
    void gain_cpp_impl::set_gain(float gain){
        d_gain = gain;
    }

  } /* namespace howto */
} /* namespace gr */

