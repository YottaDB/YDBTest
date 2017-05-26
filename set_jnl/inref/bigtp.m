bigtp;
laba;
	w "Touch AREG:",!
	FOR i=1:1:2 DO
	. TStart ():(serial:transaction="BA")
	. FOR j=1:1:760 SET ^adata(j)=$j(1,2400)
	. TC
	Q
labb;
	w "Touch BREG:",!
	FOR i=1:1:2 DO
	. TStart ():(serial:transaction="BA")
	. FOR j=1:1:7600 SET ^bdata(j)=$j(1,240)
	. TC
	Q
labc;
	w "Touch CREG:",!
	FOR i=1:1:2 DO
	. TStart ():(serial:transaction="BA")
	. FOR j=1:1:760 SET ^cdata(j)=$j(1,2400)
	. TC
	Q
lab2;
	w "Touch AREG,BREG,CREG:",!
	FOR i=1:1:2 DO
	. TStart ():(serial:transaction="BA")
	. FOR j=1:1:640 SET ^bdata(j)=$j(1,2000)
	. FOR j=1:1:640 SET ^adata(j)=$j(1,2000)
	. FOR j=1:1:640 SET ^cdata(j)=$j(1,2000)
	. TC
	Q

