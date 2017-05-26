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

$gtm_tst/com/dbcreate.csh mumps

echo "======================="
echo "[GTM-7678] Changes to how -OPTIONS are treated by MUPIP TRIGGER"
echo "# The second line should error out because, -options is changed, but the entire -commands is not specified"
set ntest="gtm7678_a"
cat > ${ntest}.trg << TFILE
-*
+^b -commands=S -xecute="do ^twork(403111)" -options=NOC
+^b -commands=ZK,ZTR -xecute="do ^twork(403111)" -options=NOI
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_b"
echo "# The second line should error out because, -options is changed (to nothing), but the entire -commands is not specified"
cat > ${ntest}.trg << TFILE
-*
+^b -commands=S,K,ZK -pieces=2:20 -delim=":" -xecute="do ^twork(66)" -options=I,NOC
+^b -commands=ZK -xecute="do ^twork(66)"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_c"
echo "# The third trigger should error out because"
echo "# while changing -options it does not specify the entire list of commands in the matching trigger"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=S,K,ZK,ZTR -options=NOI,NOC -delim=";" -pieces=1:20 -xecute="do ^twork(34306)"
+^a -commands=S                           -delim=";" -pieces=2:20 -xecute="do ^twork(34306)"
+^a -commands=S,K        -options=NOC     -delim=";" -pieces=2:20 -xecute="do ^twork(34306)"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_d"
echo "# The third trigger should not error out even if it does not specify the entire lis of commands because"
echo "# -options is ignored in case of trigger deletes."
cat > ${ntest}.trg << TFILE
-*
+^a -commands=S,K,ZK,ZTR -options=NOI,NOC -delim=";" -pieces=1:20 -xecute="do ^twork(34306)"
+^a -commands=S                           -delim=";" -pieces=2:20 -xecute="do ^twork(34306)"
-^a -commands=S,K        -options=NOC     -delim=";" -pieces=2:20 -xecute="do ^twork(34306)"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_e"
echo "# The second trigger should error out because the trigger matches, but the name does not match"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=S -name=x -xecute="do ^twork"
-^a -commands=S -name=x2 -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_f"
echo "# The second trigger should be a no-op because the commands are different"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=S -name=x -xecute="do ^twork"
-^a -commands=K -name=x -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_g"
echo "# The second trigger should be a no-op because the commands are different"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=K -name=x -xecute="do ^twork"
-^a -commands=S -name=x -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_h"
echo "# The second trigger should error out because the trigger matches, but the name does not match"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=K -name=x -xecute="do ^twork"
-^a -commands=S -name=x2 -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_i"
echo "# The second trigger should be a no-op because both the name and the commands differ"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=K,S -name=x -xecute="do ^twork" -delim=":" -pieces=2:3
-^a -commands=S -name=x2 -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_j"
echo "# The second trigger should be a no-op because the commands are different"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=K -name=x -xecute="do ^twork"
-^a -commands=S,ZK -name=x -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

set ntest="gtm7678_k"
echo "# The second trigger should modify the trigger because the commands partially match"
cat > ${ntest}.trg << TFILE
-*
+^a -commands=K,ZK -name=x -xecute="do ^twork"
-^a -commands=S,ZK -name=x -xecute="do ^twork"
TFILE

$MUPIP trigger -trig=${ntest}.trg -noprompt

$gtm_tst/com/dbcheck.csh
