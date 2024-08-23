#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2024 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

cat << CAT_EOF | sed 's/^/# /;' | sed 's/ $//;'
*****************************************************************
GTM-F135418 - Test the following release note
*****************************************************************

Release note (http://tinco.pair.com/bhaskar/gtm/doc/articles/GTM_V7.0-005_Release_Notes.html#GTM-F135418) says:

> The GT.M restrictions facility recognizes ZLINK, ZRUPDATE and
> SET \$ZROUTINES. When an explicit ZLINK (not auto-zlink),
> ZRUPDATE, or SET \$ZROUTINES restriction conditions are
> configured, the restricted command issues a RESTRICTEDOP error
> message. Previously, the restrictions facility did not support
> ZLINK, ZRUPDATE, or SET \$ZROUTINES. (GTM-F135418)
CAT_EOF

echo
echo "# ---- startup ----"

# set error prefix
setenv ydb_msgprefix "GTM"

echo '# prepare read-write $gtm_dist directory'
set old_dist=$gtm_dist
source $gtm_tst/com/copy_ydb_dist_dir.csh ydb_temp_dist
setenv gtm_dist $ydb_dist
chmod -R +wX ydb_temp_dist

echo "# get group IDs for restrict.txt"
set mygid=`id -gn`
set notmygid=`cat /etc/group | grep -vw $mygid | head -n1 | cut -d':' -f1`

echo
echo "# ---- test ZLINK ----"

echo
echo "# restrict.txt does not exist"
rm -f $gtm_dist/restrict.txt

echo
echo "# attempt to ZLINK a non-existent file (expect file not found errors)"
$gtm_dist/mumps -run %XCMD 'zlink "NoCodeIsBuglessCode"'

echo
echo "# create and ZLINK a M program (expect no error)"
echo " write 4*4,!" > w4x4.m
$gtm_dist/mumps -run %XCMD 'zlink "w4x4"'
echo "# files:"
ls -1 w4x4*
rm -f w4x4*

echo
echo "# create restrict.txt with ZLINK allowed"
rm -f $gtm_dist/restrict.txt
echo "ZLINK:$mygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt

echo
echo "# attempt to ZLINK a non-existent file (expect file not found error)"
$gtm_dist/mumps -run %XCMD 'zlink "NoCodeIsBuglessCode"'

echo
echo "# create and ZLINK a M program (expect no error)"
echo " write 5*5,!" > w5x5.m
$gtm_dist/mumps -run %XCMD 'zlink "w5x5"'
echo "# files:"
ls -1 w5x5*
rm -f w5x5*

echo
echo "# create restrict.txt with ZLINK disabled"
rm -f $gtm_dist/restrict.txt
echo "ZLINK:$notmygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt

echo
echo "# attempt to ZLINK a non-existent file (expect RESTRICTEDOP error)"
$gtm_dist/mumps -run %XCMD 'zlink "NoCodeIsBuglessCode"'

echo
echo "# create and ZLINK a M program (expect RESTRICTEDOP error)"
echo " write 6*6,!" > w6x6.m
$gtm_dist/mumps -run %XCMD 'zlink "w6x6"'
echo "# files:"
ls -1 w6x6*
rm -f w6x6*

echo
echo "# ---- test ZRUPDATE ----"

echo
echo "# restrict.txt does not exist"
rm -f $gtm_dist/restrict.txt

echo
echo "# attempt to ZRUPDATE a non-existent file (expect file not found error)"
$gtm_dist/mumps -run %XCMD 'zrupdate "NoCodeIsBuglessCode.o"'
ls -1 *.o

echo
echo "# create restrict.txt with ZRUPDATE allowed"
rm -f $gtm_dist/restrict.txt
echo "ZRUPDATE:$mygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt

echo
echo "# create, ZLINK and ZRUPDATE a M program (expect no error)"
echo " write 4*4,!" > w4x4.m
echo "#  ZLINK:"
$gtm_dist/mumps -run %XCMD 'zlink "w4x4"'
echo "#  ZRUPDATE:"
$gtm_dist/mumps -run %XCMD 'zrupdate "w4x4.o"'
echo "# files:"
ls -1 w4x4*
rm -f w4x4*

echo
echo "# create restrict.txt with ZRUPDATE allowed"
rm -f $gtm_dist/restrict.txt
echo "ZRUPDATE:$mygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt

echo
echo "# create, ZLINK and ZRUPDATE a M program (expect no error)"
echo " write 5*5,!" > w5x5.m
echo "#  ZLINK:"
$gtm_dist/mumps -run %XCMD 'zlink "w5x5"'
echo "#  ZRUPDATE:"
$gtm_dist/mumps -run %XCMD 'zrupdate "w5x5.o"'
echo "# files:"
ls -1 w5x5*
rm -f w5x5*

echo
echo "# create restrict.txt with ZRUPDATE disabled"
rm -f $gtm_dist/restrict.txt
echo "ZRUPDATE:$notmygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt

echo
echo "# attempt to ZRUPDATE a non-existent file (expect RESTRICTEDOP error)"
$gtm_dist/mumps -run %XCMD 'zrupdate "NoCodeIsBuglessCode"'

echo
echo "# create, ZLINK and ZRUPDATE a M program (expect RESTRICTEDOP error)"
echo " write 6*6,!" > w6x6.m
echo "#  ZLINK:"
$gtm_dist/mumps -run %XCMD 'zlink "w6x6"'
echo "#  ZRUPDATE:"
$gtm_dist/mumps -run %XCMD 'zrupdate "w6x6"'
echo "# files:"
ls -1 w6x6*
rm -f w6x6*

echo
echo '# ---- test SET $ZROUTINES ----'

echo
echo "# restrict.txt does not exist"
rm -f $gtm_dist/restrict.txt
echo '# attempt to SET $ZROUTINES (expect no error)'
$gtm_dist/mumps -run %XCMD 'set $zroutines="."'

echo
echo "# create restrict.txt with ZROUTINES allowed"
rm -f $gtm_dist/restrict.txt
echo "ZROUTINES:$mygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt
echo '# attempt to SET $ZROUTINES (expect no error)'
$gtm_dist/mumps -run %XCMD 'set $zroutines="."'

echo
echo "# create restrict.txt with ZROUTINES disabled"
rm -f $gtm_dist/restrict.txt
echo "ZROUTINES:$notmygid" > $gtm_dist/restrict.txt
chmod a-w $gtm_dist/restrict.txt
echo '# attempt to SET $ZROUTINES (expect RESTRICTEDOP error)'
$gtm_dist/mumps -run %XCMD 'set $zroutines="."'

echo
echo "# ---- cleanup ----"

echo "# release port number"
$gtm_tst/com/portno_release.csh
