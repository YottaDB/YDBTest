d002236	; 
	W !,"TESTING $NAME",!
	K
	S $ZTRAP="S ERRPOS=$ZPOS G ERROR"
	S i=1
	S name(i)=$NA(^global(9999,0.1234,"String Subscript","Longer String Subscript")) S i=i+1
	I '$D(@name("1")) ; set naked reference
	S name(i)=$NA(^("No Depth")) S i=i+1
	S name(i)=$NA(^("ZERO Depth"),0) S i=i+1	; naked with zero depth
	S name(i)=$NA(^global("ZERO Depth"),0) S i=i+1 	; global reference with zero depth
	S name(i)=$NA(^("Same Depth As Naked"),4) S i=i+1
	S name(i)=$NA(^("Depth Larger Than # Of SUBSC In Naked"),10000) S i=i+1
	S name(i)=$NA(^("Largest Possible Depth"),2147483647) S i=i+1
	S name(i)=$NA(^("Negative Depth - Generates FNNAMENEG error"),-i) S i=i+1
	S name(i)=$NA(^["EXTREF [] Form","Non Empty Second Arg"]global) S i=i+1
	S name(i)=$NA(^["EXTREF [] Form",1234]global) S i=i+1
	S name(i)=$NA(^[5678,1234]global) S i=i+1
	S name(i)=$NA(^["EXTREF [] Form",""]global) S i=i+1
	S name(i)=$NA(^|"EXTREF || Form"|global) S i=i+1
	S name(i)=$NA(^|"EXTREF || Form"|global("Extref With Subscripts")) S i=i+1
	S name(i)=$NA(^|"EXTREF || Form","Non Empty Second Arg"|global) S i=i+1
	S name(i)=$NA(^("See If Extref Messed Up Naked")) S i=i+1 ; back to naked
	S name(i)=$NA(^("B COMES AFTER "_$C($A("A")))) S i=i+1 ; expression in subscript
	S name(i)=$NA(^($J("I AM RIGHT JUSTIFIED",100))) S i=i+1 ; expression in subscript
	S name(i)=$NA(^($J("I CAN'T BE JUSTIFIED",1048577))) S i=i+1 ; MAX_STRLEN error from $NA
	S int=100000000,float=123456789.987654321
	S name(i)=$NA(local(int*2,int,-int,$j(int,30))) S i=i+1 ; int expressions in subscript
	S name(i)=$NA(local(float*2,-float,float,$j(float,30))) S i=i+1 ; float expressions in subscript
	S name(i)=$NA(@name(i-1)) S i=i+1 ; indirect arg to $NAME
	S name(i)=$NA(@name(i-1),0) S i=i+1 ; indirect arg to $NAME, 0 depth
	S name(i)=$NA(@name(i-2),int) S i=i+1 ; indirect args to $NAME
	S name(i)=$NA(@name(i-3),+"1.234") S i=i+1 ; indirect args to $NAME
	S name(i)=$NA(|"Extref for local"|local("Shouldn't work") S i=i+1 ; float expressions in subscript
	S name(i)=$NA(["Another Extref for local"]local("Shouldn't work") S i=i+1 ; float expressions in subscript
	ZWR name
	Q

ERROR
	; Record error and skip to line following line that errored
	S name(i)=$ZSTATUS S i=i+1
	S LAB=$P(ERRPOS,"+",1)
	S OFFSET=$P($P(ERRPOS,"+",2),"^",1)+1
	S NEXTLINE=LAB_"+"_OFFSET
	G @NEXTLINE
