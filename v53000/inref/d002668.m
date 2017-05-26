c002736	;
	; Test to check SELECT qualifier works with huge number of global variables
	; Although this M program is written to work with Unix and VMS, the test is not relevant for VMS since
	; DCL has a 256 byte limit on the command line which makes it impossible to specify a lot of global variables.
	;
	; Populate database with lots of globals
	;
	set unix=$zversion'["VMS"
	if unix  set extension="csh",qualifier="-"
	else     set extension="com",qualifier="/"
	set reorgfile="reorgselect."_extension
	set extractfile="extractselect."_extension
	;
        open reorgfile
	open extractfile
	;
	use reorgfile
	write "$MUPIP reorg "_qualifier_"select=%dummy"
	;
	use extractfile
	write "$MUPIP extract select.ext "_qualifier_"select=%dummy"
	;
	use $p
	set gblstr="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
	set len=$length(gblstr)
	for i=1:1:len/2  do	 ; do not go full length as otherwise the command line constructed becomes too long for Unix shell
	.	for j=1:1:len  do
	.	.	set gblname=$extract(gblstr,i)_$extract(gblstr,j)
	.	.	for k=1:1:10 do
	.	.	.	set xstr="set ^"_gblname_"("_k_")=$j("_k_",10+$r(20))"
	.	.	.	xecute xstr
	.	.	use reorgfile
	.	.	write ","_gblname
	.	.	use extractfile
	.	.	write ","_gblname
	.	.	use $p
	close reorgfile
	close extractfile
	quit
