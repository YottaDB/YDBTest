#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2014-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
# Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#FILES				File Name	format=ZWR		format=GO		format=BINARY	format not mentioned(auto detect)
#------------------	---------	--------------- --------------- --------------- ---------------------------------
#ZWR				x.zwr		Loaded			%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		Loaded
#GO					x.goo		%YDB-E-LDBINFMT	Loaded			%YDB-E-LDBINFMT		Loaded
#BINARY				x.bin		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	Loaded				Loaded
#EMPTY				x.emt		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		%YDB-E-LDBINFMT
#RANDOM TEXT		x.ran		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		%YDB-E-LDBINFMT
#ZWR UNKNOWN HEADER	x.zuh		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		%YDB-E-LDBINFMT
#GO UNKNOWN HEADER	x.guh		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		%YDB-E-LDBINFMT
#ZWR HEADERLESS		x.zhl		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		%YDB-E-LDBINFMT
#GO HEADERLESS		x.ghl		%YDB-E-LDBINFMT	%YDB-E-LDBINFMT	%YDB-E-LDBINFMT		%YDB-E-LDBINFMT
echo "#### MUPIP LOAD error conditions tests####"
if ($?gtm_chset) then
	if ("UTF-8" == $gtm_chset) set utf8mode
endif
if ((1 == $gtm_test_spanreg) || (3 == $gtm_test_spanreg)) then
	set colno = 0
	if ($?test_collation_no) then
			set colno = $test_collation_no
	endif
	setenv test_specific_gde $gtm_tst/$tst/inref/mu_load_err_COL${colno}.sprgde
	setenv gtm_test_spanreg 0	#test specific gde already points to .sprgde
endif
$gtm_tst/com/dbcreate.csh mumps 3
$gtm_exe/mumps -run %XCMD 'for i=1:1:2 set ^a(i)=1*i,^b(i)=2*i,^c(i)=3*i'
$gtm_exe/mumps -run %XCMD 'set ^a("one")="one",^a("ten")="ten",^b(10)="twentyABCD",^c("ten")=30'
echo "# Create extract files in bin/zwr/go formats, an empty file and a file with any text"
$MUPIP extract x.bin -format=bin >&! bin_extract.outx
$MUPIP extract x.zwr -format=zwr >&! zwr_extract.outx
if (! $?utf8mode) then
	$MUPIP extract x.go -format=go >&! go_extract.outx
endif
touch tmp.empty
cat > tmp.randomtext << CAT_EOF
this is
a random
text in this file
CAT_EOF
cat << M_FILE >&! corrupt.m
corrupt	;
	s src="x.bin"
	open src:(readonly:fixed:wrap:chset="M")
	s dest="xcorrupt.bin"
	open dest:(newversion:fixed:wrap:chset="M")
	set max=8192
	for  k line use src read line#max quit:\$zeof  use dest write \$zpiece(line,"ABCD",1)_"ABCDEFGH"_\$zpiece(line,"ABCD",2) set \$x=0
	use \$principal
	close src
	close dest
	quit
M_FILE
$gtm_exe/mumps -run corrupt
set serial=0
foreach onerror (proceed stop interactive)
	echo "#### mupip load with onerror=$onerror####"
	echo "# Move a.dat and b.dat to .bak"
	mv a.dat a.bak
	mv b.dat b.bak
	# 1. 7. 13. -format=BIN (no database file)
	@ serial++ ;echo "# ### $serial. Testing Binary Format (no database file) ### #"
	echo "# ${serial}a. Expect YDB-E-DBFILERR, SYSTEM-E-ENO2 and YDB-E-RECLOAD as a.dat and b.dat database files are not present"
	echo "# load will continue for all keys in mumps.dat except when -onerror is stop or interactive"
	$MUPIP load -format=bin -onerror=$onerror x.bin >&! xloadbinnodat$onerror.outx
	$grep -vE "Label =|at File offset" xloadbinnodat$onerror.outx
	echo "# ${serial}b. Expect YDB-E-LDBINFMT, as .zwr is not a valid binary format"
	$MUPIP load -format=bin -onerror=$onerror x.zwr
	if (! $?utf8mode) then
		echo "# ${serial}c. Expect YDB-E-LDBINFMT, as .go is not a valid binary format"
		$MUPIP load -format=bin -onerror=$onerror x.go
	endif
	echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain any binary header"
	$MUPIP load -format=bin -onerror=$onerror tmp.empty
	echo "# ${serial}e. Expect YDB-E-LDBINFMT, as random text is not a valid binary format"
	$MUPIP load -format=bin -onerror=$onerror tmp.randomtext
	echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
	$MUPIP load -format=bin -onerror=$onerror tmp.nofile
	# 2. 8. 14. -format=ZWR (no database file)
	@ serial++ ;echo "# ### $serial. Testing ZWR Format (no database file) ### #"
	echo "# ${serial}a. Expect YDB-E-DBFILERR, SYSTEM-E-ENO2 and YDB-E-RECLOAD as a.dat and b.dat database files are not present"
	echo "# load will continue for all keys in mumps.dat except when -onerror is stop or interactive"
	$MUPIP load -format=zwr -onerror=$onerror x.zwr
	echo "# ${serial}b. Expect YDB-E-LDBINFMT, as .bin is not a valid zwr format"
	$MUPIP load -format=zwr -onerror=$onerror x.bin
	if (! $?utf8mode) then
		echo "# ${serial}c. Expect YDB-E-LDBINFMT, as .go is not a valid zwr format"
		$MUPIP load -format=zwr -onerror=$onerror x.go
	endif
	echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain any zwr header"
	$MUPIP load -format=zwr -onerror=$onerror tmp.empty
	echo "# ${serial}e. Expect YDB-E-LDBINFMT, as random text is not a valid zwr format"
	$MUPIP load -format=zwr -onerror=$onerror tmp.randomtext
	echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
	$MUPIP load -format=zwr -onerror=$onerror tmp.nofile
	# 3. 9. 15. -format=GO (no database file)
	@ serial++
	if (! $?utf8mode) then
		echo "# ### $serial. Testing GO Format (no database file) ### #"
		echo "# ${serial}a. Expect YDB-E-DBFILERR, SYSTEM-E-ENO2 and YDB-E-RECLOAD as a.dat and b.dat database files are not present"
		echo "# load will continue for all keys in mumps.dat except when -onerror is stop or interactive"
		$MUPIP load -format=go -onerror=$onerror x.go
		echo "# ${serial}b. Expect YDB-E-LDBINFMT, as .zwr is not a valid go format"
		$MUPIP load -format=go -onerror=$onerror x.zwr
		echo "# ${serial}c. Expect YDB-E-LDBINFMT, as .bin is not a valid go format"
		$MUPIP load -format=go -onerror=$onerror x.bin
		echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain any go header"
		$MUPIP load -format=go -onerror=$onerror tmp.empty
		echo "# ${serial}e. Expect YDB-E-LDBINFMT, as random text is not a valid go format"
		$MUPIP load -format=go -onerror=$onerror tmp.randomtext
		echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
		$MUPIP load -format=go -onerror=$onerror tmp.nofile
	endif
	echo "# Restore a.dat and b.dat"
	mv a.bak a.dat
	mv b.bak b.dat
	# 4. 10. 16. -format=BIN
	@ serial++ ;echo "# ### $serial. Testing Binary Format ### #"
	echo "# ${serial}a. Successfully load the x.bin content in the database"
	$MUPIP load -format=bin -onerror=$onerror x.bin >&! xloadbin$onerror.outx
	$grep -v "Label =" xloadbin$onerror.outx
	echo "# ${serial}b. Expect YDB-E-LDBINFMT, as .zwr is not a valid binary format"
	$MUPIP load -format=bin -onerror=$onerror x.zwr
	if (! $?utf8mode) then
		echo "# ${serial}c. Expect YDB-E-LDBINFMT, as .go is not a valid binary format"
		$MUPIP load -format=bin -onerror=$onerror x.go
	endif
	echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain any binary header"
	$MUPIP load -format=bin -onerror=$onerror tmp.empty
	echo "# ${serial}e. Expect YDB-E-LDBINFMT, as random text is not a valid binary format"
	$MUPIP load -format=bin -onerror=$onerror tmp.randomtext
	echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
	$MUPIP load -format=bin -onerror=$onerror tmp.nofile
	if ( "NON_ENCRYPT" == "$test_encryption" ) then
		echo "# ${serial}g. Corrupt a binary file (replace last occurrence of ABCD with ABCDEFGH) and try loading that"
		echo "# Expect YDB-E-PREMATEOF, as file is corrupted binary format"
		$MUPIP load -format=bin -onerror=$onerror xcorrupt.bin  >&! xcorrupt$onerror.outx
		$grep -v "Label =" xcorrupt$onerror.outx
	endif
	# 5. 11. 17. -format=ZWR
	@ serial++ ;echo "# ### $serial. Testing ZWR Format ### #"
	echo "# ${serial}a. Successfully load the x.zwr content in the database"
	$MUPIP load -format=zwr -onerror=$onerror x.zwr
	echo "# ${serial}b. Expect YDB-E-LDBINFMT, as .bin is not a valid zwr format"
	$MUPIP load -format=zwr -onerror=$onerror x.bin
	if (! $?utf8mode) then
		echo "# ${serial}c. Expect YDB-E-LDBINFMT, as .go is not a valid zwr format"
		$MUPIP load -format=zwr -onerror=$onerror x.go
	endif
	echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain any zwr header"
	$MUPIP load -format=zwr -onerror=$onerror tmp.empty
	echo "# ${serial}e. Expect YDB-E-LDBINFMT, as random text is not a valid zwr format"
	$MUPIP load -format=zwr -onerror=$onerror tmp.randomtext
	echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
	$MUPIP load -format=zwr -onerror=$onerror tmp.nofile
	# 6. 12. 18. -format=GO
	@ serial++
	if (! $?utf8mode) then
		echo "# ### $serial. Testing GO Format ### #"
		echo "# ${serial}a. Successfully load the x.go content in the database"
		$MUPIP load -format=go -onerror=$onerror x.go
		echo "# ${serial}b. Expect YDB-E-LDBINFMT, as .zwr is not a valid go format"
		$MUPIP load -format=go -onerror=$onerror x.zwr
		echo "# ${serial}c. Expect YDB-E-LDBINFMT, as .bin is not a valid go format"
		$MUPIP load -format=go -onerror=$onerror x.bin
		echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain any go header"
		$MUPIP load -format=go -onerror=$onerror tmp.empty
		echo "# ${serial}e. Expect YDB-E-LDBINFMT, as random text is not a valid go format"
		$MUPIP load -format=go -onerror=$onerror tmp.randomtext
		echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
		$MUPIP load -format=go -onerror=$onerror tmp.nofile
	endif
end
# 19. -format not defined
@ serial++ ;echo "# ### $serial. Testing Auto File Sensing ### #"
echo "# ${serial}a. Successfully load the x.zwr content in the database"
$MUPIP load x.zwr
echo "# ${serial}b. Successfully load the x.bin content in the database"
$MUPIP load x.bin >&! xloadbin${serial}.outx
$grep -v "Label =" xloadbin${serial}.outx
if (! $?utf8mode) then
	echo "# ${serial}c. Successfully load the x.go content in the database"
	$MUPIP load x.go
endif
echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain ZWR/GO/BINARY header"
$MUPIP load tmp.empty
echo "# ${serial}e. Expect YDB-E-LDBINFMT, as file with random text do not contain a valid ZWR/GO/BINARY header"
$MUPIP load tmp.randomtext
echo "# ${serial}f. Expect YDB-E-FILEOPENFAIL, as file doesn't exist"
$MUPIP load tmp.nofile
# 20. -STDIN redirection
@ serial++ ;echo "# ### $serial. Testing Auto File Sensing with -STDIN and FILE REDIRECTION ### #"
echo "# ${serial}a. Successfully load the x.zwr content in the database"
$MUPIP load -STDIN < x.zwr
echo "# ${serial}b. Successfully load the x.bin content in the database"
$MUPIP load -STDIN < x.bin >&! xloadbin${serial}.outx
$grep -v "Label =" xloadbin${serial}.outx
if (! $?utf8mode) then
	echo "# ${serial}c. Successfully load the x.go content in the database"
	$MUPIP load -STDIN < x.go
endif
echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain ZWR/GO/BINARY header"
$MUPIP load -STDIN < tmp.empty
echo "# ${serial}e. Expect YDB-E-LDBINFMT, as file with random text do not contain a valid ZWR/GO/BINARY header"
$MUPIP load -STDIN < tmp.randomtext
echo "# ${serial}f. Expect No such file error, as file doesn't exist"
$MUPIP load -STDIN < tmp.nofile
# 21. -STDIN UNIX pipe
@ serial++ ;echo "# ### $serial. Testing Auto File Sensing with -STDIN and UNIX PIPE ### #"
echo "# ${serial}a. Successfully load the x.zwr content in the database"
cat x.zwr | $MUPIP load -STDIN
echo "# ${serial}b. Successfully load the x.bin content in the database"
cat x.bin | $MUPIP load -STDIN >&! xloadbin${serial}.outx
$grep -v "Label =" xloadbin${serial}.outx
if (! $?utf8mode) then
	echo "# ${serial}c. Successfully load the x.go content in the database"
	cat x.go | $MUPIP load -STDIN
endif
echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain ZWR/GO/BINARY header"
cat tmp.empty | $MUPIP load -STDIN
echo "# ${serial}e. Expect YDB-E-LDBINFMT, as file with random text do not contain a valid ZWR/GO/BINARY header"
cat tmp.randomtext | $MUPIP load -STDIN
# 22. -STDIN UNIX named pipe
@ serial++ ;echo "# ### $serial. Testing Auto File Sensing with UNIX NAMED PIPE ### #"
mkfifo namedpipe
echo "# ${serial}a. Successfully load the x.zwr content in the database"
(cat x.zwr > namedpipe &) >&! xnamedpipe${serial}a.outx
$MUPIP load namedpipe
echo "# ${serial}b. Successfully load the x.bin content in the database"
(cat x.bin > namedpipe &) >&! xnamedpipe${serial}b.outx
$MUPIP load namedpipe >&! xloadbin${serial}.outx
$grep -v "Label =" xloadbin${serial}.outx
if (! $?utf8mode) then
	echo "# ${serial}c. Successfully load the x.go content in the database"
	(cat x.go > namedpipe &) >&! xnamedpipe${serial}c.outx
	$MUPIP load namedpipe
endif
echo "# ${serial}d. Expect YDB-E-LDBINFMT, as empty files do not contain ZWR/GO/BINARY header"
(cat tmp.empty > namedpipe &) >&! xnamedpipe${serial}d.outx
$MUPIP load namedpipe
echo "# ${serial}e. Expect YDB-E-LDBINFMT, as file with random text do not contain a valid ZWR/GO/BINARY header"
(cat tmp.randomtext > namedpipe &) >&! xnamedpipe${serial}e.outx
$MUPIP load namedpipe
# switching to M mode to avoid YDB-E-LOADINVCHSET even before the actual error is caught.
$switch_chset M >&! switch_chset.out
foreach test (a b c d e f)
	foreach type (.zwr .go)
		setenv file gtm8223$test$type
		cp $gtm_tst/$tst/inref/$file ./
		echo "##################### "$file" ###################"
		echo "#################### no format ##################"
		$gtm_dist/mupip load $file
		echo "################### -format=zwr #################"
		$gtm_dist/mupip load -format=zwr $file
		echo "################### -format=go ##################"
		$gtm_dist/mupip load -format=go $file
	end
end
if (! $?utf8mode) then
	$switch_chset "UTF-8" >>&! switch_chset.out
endif
$gtm_tst/com/dbcheck.csh
