opnodir;; 
	;; path component is not directory
	s unix=$ZV'["VMS"
	s sd="nosuchdir"
	o sd:new
	close sd
	if unix d
	. s sd="nosuchdir/abc.txt"
	else  s sd="[.nosuchdir]abc.txt"
	o sd:(readonly:exception="G BADOPEN")
	w "This should not be displayed",!
	u sd
	F  U sd R x U $P W x,!
	Q
BADOPEN	
	w "Inside error handler",!
	if unix d
	. I (($zversion["OS390")&(135=$P($ZS,",",1)))!(($zversion'["OS390")&(20=$P($ZS,",",1))) DO
	.. W "The file ",sd," does not exist",!
	else  d
	. I $ZS["-DNF" D
	.. W "The file ",sd," does not exist",!
	ZM +$ZS
	Q
