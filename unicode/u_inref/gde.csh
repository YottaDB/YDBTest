#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#=====================================================================
$echoline
cat << EOF >>! gdeinput.gdecmd
change -segment DEFAULT -file_name=ｍｕｍｐｓ.dat
EOF
$convert_to_gtm_chset gdeinput.gdecmd

set echo; setenv gtmgbldir mumps1.gld; unset echo
$switch_chset "M"

$GDE << EOF >>&! gdeinput_chsetM.out
@gdeinput.gdecmd
exit
EOF
if ("ENCRYPT" == "$test_encryption" ) then
	# create_key_file.csh uses GDE SHOW -MAP to figure out the db file names.
	# Since the db file names contain UTF-8 byte sequences, we need to make sure chset is switched
	# to UTF-8 before invoking the script or else the file name might contain "$c(nnn)" literals
	# which correspond to the binary byte with codepoint nnn but will be misinterpreted as the letter "$"
	# followed by the letter "C" etc. which causes a CRYPTKEYFETCHFAILED error later.
	$switch_chset "UTF-8"	>&! switch_chset.out
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload1.out
	$switch_chset "M"	>>&! switch_chset.out
endif
cat gdeinput_chsetM.out

$GDE << EOF >>&! gdecheck1.out
show -map
quit
EOF

$switch_chset "UTF-8"
# chset is switched to UTF-8 here becuse, the earlier switch_chset to M causes the below "grep"
# and "if -f" not to recognise unicode ｍｕｍｐｓ.dat
$grep "ｍｕｍｐｓ.dat" gdecheck1.out
if (! $status) then
	echo "TEST-E-ERROR, ｍｕｍｐｓ.dat should NOT be in the global directory!"
endif

$MUPIP create
if (! -f ｍｕｍｐｓ.dat) then
	echo "TEST-E-ERROR, ｍｕｍｐｓ.dat should have been created!"
endif

\rm -f *.dat
#=====================================================================
$echoline
set echo; setenv gtmgbldir mumps2.gld; unset echo
$GDE << EOF >>&! gdeinput_chsetUTF8.out
@gdeinput.gdecmd
exit
EOF
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload2.out
endif
cat gdeinput_chsetUTF8.out

$GDE << EOF >>&! gdecheck2.out
show -map
quit
EOF

$grep "ｍｕｍｐｓ.dat" gdecheck2.out
if ($status) then
	echo "TEST-E-ERROR, ｍｕｍｐｓ.dat should be in the global directory!"
endif

$MUPIP create
if (! -f ｍｕｍｐｓ.dat) then
	echo "TEST-E-ERROR, ｍｕｍｐｓ.dat should have been created!"
endif

#=====================================================================
$echoline
set echo; setenv gtmgbldir mumps3.gld; unset echo
$GDE << EOF >>&!  gdecommands.outx
add -name a* -region=areg
add -name aａ* -region=areg
add -name b -region=bｒeg
add -region areg -dyn=aｓeg
add -region areg -dyn=aseg
add -segment aseg -f=ｍｕｍｐｓ3.dat
EOF
if ("ENCRYPT" == "$test_encryption" ) then
        $gtm_tst/com/create_key_file.csh >& create_key_file_dbload3.out
endif
#mask off the -E- so the error catching mechanism does not catch:
sed 's/-E-NONASCII/-X-NONASCII/g' gdecommands.outx >gdecommands.out
cat gdecommands.out

$echoline
$GDE << EOF
show -all
quit
EOF
