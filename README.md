# 5G-NR-LDPC
5G NR LDPC MATLAB implementation

Ref : https://nptel.ac.in/courses/108/106/108106137/

A more efficeint implementation from the above reference.

This implementation doesn't create a matrix B of size (N-K)/Z_c by N/Z_c (like the implementation in the above link) instead, it
just use those element of B with postive or zero values from the table provided in 3GPP. Save memory& time!
