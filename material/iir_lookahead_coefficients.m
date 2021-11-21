clc
clear all

% Computation of the IIR filter coefficients - lookahead version

nb = 12;

% Original coefficients
b0 = 423;
b1 = 846;
b2 = 423;
a1 = -757;
a2 = 401;

% Computation of the new coefficients
b1_la = floor((floor(b1*2^11)-(a1*b0))/2^11)
b1_la_real = b1_la/(2^(nb-1))

b2_la = floor((floor(b2*2^11)-(a1*b1))/2^11)
b2_la_real = b2_la/(2^(nb-1))

b3_la = floor((a1*b2)/2^11)
b3_la_real = b3_la/(2^(nb-1))

a1_la = floor(((a1*a1)-floor(a2*2^11))/2^11)
a1_la_real = a1_la/(2^(nb-1))

a2_la = floor((a1*a2)/2^11)
a2_la_real = a2_la/(2^(nb-1))