c1780	;
	;
	s unix=$zv'["VMS"
	f i=1:1:100 do
	.	TSTART ():SERIAL
	.	s ^a(i)=$j(i,200)
	.	s ^x(i)=$j(i,200)
	.	TCOMMIT
	h 1
	if unix zsy "$gtm_dist/mupip set -journal=""enable,before"" -reg AREG"
	else  zsy "MUPIP set /journal=(enable,before) /reg $DEFAULT"
	TSTART ():SERIAL
	s ^a=1
	s ^x=1
	TCOMMIT
	if unix zsy "$gtm_dist/dse buff" ;will flush only AREG not DEFAULT
	else  zsy "DSE buff"
	h 1
	if unix zsy "kill -9 "_$j
	else  zsy "stop/id="_$$FUNC^%DH($j)
	w "After calling stop/id",!
	Q
