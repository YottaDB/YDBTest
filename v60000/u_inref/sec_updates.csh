#!/usr/local/bin/tcsh -f
# sec_updates.csh does work on the secondary side based on $1 parameter
# $1 - WAIT wait up to 240 sec for the ^x(10000) in the database
# $1 - EXTRACT extract a.mjl, b.mjl, mumps.mjl
# $1 - GETJNLSEQNO output the jnl_seqno field from NULL record in the mumps.mjf file
# $1 - SAVEOUTPUT make backup directories and save files

if ("WAIT" == "$1") then
	set waittime = 240
	set gval = `$gtm_exe/mumps -run %XCMD 'for i=1:1:'$waittime' hang 1 if $data(^x(10000)) write 1 quit'`
	if (1 == "$gval") then
		exit 0
	else
		echo "^x(10000) not found in secondary database after $waittime sec"
		exit 1
	endif
endif

if ("EXTRACT" == "$1") then
	foreach jfile(*.mjl)
		$MUPIP journal -extract -noverify -detail -for -fences=none $jfile
	end
	exit
endif

if ("GETJNLSEQNO" == "$1") then
	$grep NULL *.mjf > nullrecord.log
	$tst_awk -F'\\' '{print $7}' nullrecord.log
	exit
endif

if ("SAVEOUTPUT" == "$1") then
	mkdir mjf
	mkdir bak
	cp *.dat *.mjl *.gld *.repl bak
	mv *.mjf* nullrecord.log mjf
	exit
endif
