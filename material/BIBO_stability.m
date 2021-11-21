%BIBO stability checker

%Filter's transfer function
H = tf(bq,aq,-1,'Variable','z^-1');

%Root of both numerator and denominator (zeros and poles)
Zq=roots(bq);
Pq=roots(aq);

%plot
zplane(Zq,Pq);
title('Filter BIBO stability');
legend("Zeros","Poles");