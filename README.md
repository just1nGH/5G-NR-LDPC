# 5G-NR-LDPC
5G NR LDPC MATLAB implementation

Ref : https://nptel.ac.in/courses/108/106/108106137/

A more efficeint implementation from the above reference.

This implementation doesn't create a whole parity check matrix H of size (N-K)by N, neither does it generate the corresponding exponent matrx of H (E(H)) of size (N-K)/Z_c by N/Z_c (like the implementation in the above link). Instead it just uses the zero or positive shift valules from the table listed in 3GPP (3GPP TS 38.212 Table 5.3.2-2/3). For BG1 is with 316 values, and BG2 is with 197 value. Save memory& time!
