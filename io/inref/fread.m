FREAD(sd) ;
	OPEN sd:(readonly:exception="g BADOPEN")
	USE sd:exception="G EOF"
	FOR  USE sd READ x USE $P WRITE x,!
EOF	IF '$ZEOF ZM +$ZS
	CLOSE sd
	QUIT
BADOPEN SET unix=$ZVERSION'["VMS"
	IF unix DO BADOPU
	ELSE  DO BADOPV
	QUIT
BADOPU	IF (($zversion["OS390")&(129=$P($ZS,",",1)))!(($zversion'["OS390")&(2=$P($ZS,",",1))) DO  QUIT
	. WRITE !,"The file ",sd," does not exist."
	IF (($zversion["OS390")&(111=$P($ZS,",",1)))!(($zversion'["OS390")&(13=$P($ZS,",",1))) DO  QUIT
	. WRITE !,"The file ",sd," is not accessible."
	ZM +$ZS
	QUIT
BADOPV	IF $ZS["-FNF," DO  QUIT
	. WRITE !,"The file ",sd," does not exist."
	IF $ZS["-PRV," DO  QUIT
	. WRITE !,"The file ",sd," is not accessible."
	ZM +$ZS
	QUIT
