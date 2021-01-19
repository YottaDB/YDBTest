#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2021 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
echo "# This tests -stdin/-stdout for mupip trigger"

source $gtm_tst/com/dbcreate.csh mumps 5

cat > triggers.trg  <<TFILE
+^a	-command=SET	-xecute="do ^twork"
+^b	-command=SET	-xecute="do ^twork"
+^c	-command=SET	-xecute="do ^twork"
+^d	-command=SET	-xecute="do ^twork"
+^a(0,:,:) -xecute="do tsubrtn^twork" -options=i -command=sEt,KilL
+^a(:) -command=zTkIll,zw,s -xecute="do ^twork"
+^a(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=s,zkILL -options=noc,noi
+^a(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4;5;6 -command=s -xecute="do tsubrtn^twork" -options=i,c
+^a(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,c
+^b(0,:,:) -xecute="do tsubrtn^twork" -options=i -command=sEt,KilL
+^c(:) -command=zTkIll,zw,s -xecute="do ^twork"
+^b(:"b";"m":"x") -piece=1:8 -xecute="do ^tkilla" -delim="\`"  -command=zkILL,s -options=noc,noi
+^drek(tvar=:,tvar2="t":"z",tvar3=:10;20) -delim="""" -piece=4;5;6 -command=s -xecute="do tsubrtn^twork" -options=i,c
+^drek(tvar=:,tvar2="a";"g":"z",tvar3=:10;20) -delim="^" -piece=4;5;6 -command=s  -xecute="do tsubrtn^twork" -options=i,c
TFILE
sed 's/^+/-/' triggers.trg > triggersm.trg

cat > trmall.trg <<TFILE
-*
TFILE


echo
echo "# Loading triggers from -stdin"
$MUPIP trigger -stdin < triggers.trg

echo
echo "# -select with -stdout"
$MUPIP trigger -select -stdout

echo
echo "# -select with global to file (pre-existing behavior)"
$MUPIP trigger -select="d*" d_globals_triggers.trg
cat d_globals_triggers.trg

echo
echo "# -select all to prompted file name (pre-existing behavior)"
echo all_globals_triggers.trg | $MUPIP trigger -select
cat all_globals_triggers.trg

echo
echo "# -select all to stdout after null file name (pre-existing behavior)"
echo | $MUPIP trigger -select

echo
echo "# Delete triggers from file (pre-existing behavior)"
$MUPIP trigger -triggerfile=triggersm.trg

echo
$MUPIP trigger -triggerfile=triggers.trg

echo
echo "# Test that PROMPT still works for -* deletions"
echo "# Load"
$MUPIP trigger -triggerfile=triggers.trg >&/dev/null
echo "# Prompt, answer N then answer Y"
echo "N" | $MUPIP trigger -triggerfile=trmall.trg
echo "Y" | $MUPIP trigger -triggerfile=trmall.trg
echo "# Load and remove without prompting with -NOPROMPT"
$MUPIP trigger -triggerfile=triggers.trg >&/dev/null
$MUPIP trigger -noprompt -triggerfile=trmall.trg

echo
echo "# Test that -* from STDIN sets NOPROMPT"
$MUPIP trigger -triggerfile=triggers.trg >&/dev/null
$MUPIP trigger -stdin <<END
-*
END
