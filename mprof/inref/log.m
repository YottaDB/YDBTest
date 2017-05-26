log	; Test of logical operators
;	File modified by Hallgarth on  2-MAY-1986 14:55:58.35
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w (i-j)&(i-k)&(j-k)&(i-(j*k)-k)&(i+j-(2*k))&(i*j-(1*j\(2*k)))&(i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w (i-(j*k)-k)!(i+j-(2*k))!(i*j-(1*j\(2*k)))&(i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w (i-(j*k)-k)!(i+j-(2*k))&(i*j-(5*j\(2*k)))!(i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w (i-(j*k)-k)!(i+j-(2*k))!(i*j-(5*j\(2*k)))!(i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w '(i-j)&(i-k)&(j-k)&(i-(j*k)-k)&'(i+j-(2*k))&(i*j-(1*j\(2*k)))&(i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w (i-(j*k)-k)!(i+j-(2*k))!(i*j-(1*j\(2*k)))&('i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w (i-(j*k)-k)!(i+j-(2*k))&'(i*j-(1*j\(2*k)))!(i*j*k\3*k)
	w !!
	f i=1:1:4 f j=1:1:4 f k=1:1:4 w '(i-(j*k)-k)!'(i+j-(2*k))!'(i*j-(1*j\(2*k)))!'(i*j*k\3*k)
	w !!
