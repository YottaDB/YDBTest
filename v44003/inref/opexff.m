opexff;; 
	;; fifo abc.txt will get perm error
	s sd="/abc.txt"
	o sd:(fifo:exception="G BADOPEN")
	;o sd:(fifo:exception)
	;o sd:fifo
	w "This should not be displayed",!
	u sd
	F  U sd R x U $P W x,!
	Q
BADOPEN	w "We are inside error handler",!
	IF (($zversion["OS390")&(111=$P($ZS,",",1)))!(($zversion'["OS390")&(13=$P($ZS,",",1))) DO
	. W !,"No permission to create fifo ",sd,!
	ZM +$ZS
	Q
