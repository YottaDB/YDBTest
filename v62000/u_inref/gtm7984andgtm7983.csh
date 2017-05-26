#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# This tests GTM-7984 and GTM-7983.

# GTM-7983
#	a) Test that MUPIP JOURNAL -EXTRACT extracts jnl records > 32Kb in size
#	b) Test that DSE DUMP -GLO/-ZWR correctly extracts unsubscripted nodes
# GTM-7984
#	c) Test that piping the output of GT.M or MUPIP or DSE that has lines longer than 32Kb now works fine
#	d) Also test that ZSHOW D for pipe devices display STREAM/NOWRAP as appropriate

echo "a) Test that MUPIP JOURNAL -EXTRACT extracts jnl records > 32Kb in size"
echo "b) Test that DSE DUMP -GLO/-ZWR correctly extracts unsubscripted nodes"
echo "c) Test that piping the output of GT.M or MUPIP or DSE that has lines longer than 32Kb now works fine"
echo ""
setenv gtm_test_jnl "SETJNL"                # For journal creation at database creation time
foreach recsize (32768 65536 1048576)
	$gtm_tst/com/dbcreate.csh mumps 1 -key=1000 -rec=$recsize -block=4096
	echo ""
	echo " -------------------- Record size = $recsize ------------------"
	$GTM << GTM_EOF
	set ^a=\$j(1,1000),^a(1)=\$j(1,1000),^a("abcd")=\$j(1,1000)	; test for unsubscripted and subscripted nodes
	set ^x=\$j(2,$recsize)
	set ^x(1)=\$j(2,$recsize)
	set ^x(\$j(1,980))=\$j(2,$recsize)
GTM_EOF
	echo " --> Test of (c) : MUPIP EXTRACT -STDOUT <-- "
	$MUPIP extract -stdout | $grep '^\^' > extract_$recsize.out
	$GTM << GTM_EOF
		do shrink^gtm7984andgtm7983("extract_$recsize.out"," ")	; shrink the file using space as separator
GTM_EOF
	echo " --> Test of (a) : MUPIP JOURNAL -EXTRACT <-- "
	$MUPIP journal -extract -noverify -for -fences=none mumps.mjl >& jnlext_$recsize.log
	# grep for SET records in mumps.mjf after shrinking them (to avoid huge reference file)
	$GTM << GTM_EOF |& $grep ^05 | sed 's/.*\^/^/g'
		do shrink^gtm7984andgtm7983("mumps.mjf"," ")	; shrink the file using space as separator
GTM_EOF
	$DSE << DSE_EOF >& dsedump_$recsize.log
		open -file=dsedump_$recsize.zwr
		dump -bl=3 -zwr
		close
		open -file=dsedump_$recsize.glo
		dump -bl=3 -glo
		close
DSE_EOF
	echo " --> Test of (b) : DSE DUMP -ZWR <-- "
	$GTM << GTM_EOF
		do shrink^gtm7984andgtm7983("dsedump_$recsize.zwr"," ")	; shrink the file using space as separator
GTM_EOF
	# Note that in UTF-8 mode, DSE DUMP -GLO is not supported, so adjust reference file accordingly.
	echo " --> Test of (b) : DSE DUMP -GLO <-- "
	$GTM << GTM_EOF
		do shrink^gtm7984andgtm7983("dsedump_$recsize.glo"," ")	; shrink the file using space as separator
GTM_EOF
	$gtm_tst/com/dbcheck.csh
	mkdir bak_$recsize
	mv mumps.* bak_$recsize
end

echo "d) Also test that ZSHOW D for pipe devices display STREAM/NOWRAP as appropriate"
echo ""
$gtm_exe/mumps -run pipe^gtm7984andgtm7983

