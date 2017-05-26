opexcep;; 
	;; abc.txt does not exist
	s unix=$ZV'["VMS"
	s sd="abc.txt"
	o sd:(readonly:exception="G BADOPEN")
	w "This should not be displayed",!
	u sd
	F  U sd R x U $P W x,!
	Q
BADOPEN;;
	W "Inside Error handler",!
	I unix d
	. IF (($zversion["OS390")&(129=$P($ZS,",",1)))!(($zversion'["OS390")&(2=$P($ZS,",",1))) DO
        . . W !,"The file ",sd," does not exist",!
 	E  d
	. I $ZS["-FNF" D
	.. W !,"The file ",sd," does not exist",!
	ZM +$ZS
	Q
