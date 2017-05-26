#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2015 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# Test TRIGREPLSTATE error
#
# Test the following scenarios (N = non-replicated, non-journaled database, R = replicated dataase)
#
#  e.g. N -> R -> R
#	/* implies 3 levels of update spanning from $ztlevel=0 through $ztlevel=1 to $ztlevel=2 */
#	/* the $ztlevel=0 update happens in non-replicated, non-journaled database and others happen */
#	/* in a replicated database */
#
#	^h* maps to 	non-replicated, non-journaled database HREG
#	^b* maps to     journaled database BREG
#
# ----  --------------    --------------------    -------------------------
#  #    Scenario          Actual globals used     Expected outcome
# ----  --------------    --------------------    -------------------------
#  0)   N -> N            ^h0 -> ^h00             Should work fine
#  1)   N -> R            ^h1 -> ^b11             Should ISSUE ERROR
#  2)   R -> N            ^b2 -> ^h22             Should work fine
#  3)   R -> R            ^b3 -> ^b33             Should work fine
#  4)   N -> N -> N       ^h4 -> ^h44 -> ^h444    Should work fine
#  5)   N -> N -> R       ^h5 -> ^h55 -> ^b555    Should ISSUE ERROR
#  6)   R -> N -> N       ^b6 -> ^h66 -> ^h666    Should work fine
#  7)   R -> N -> R       ^b7 -> ^h77 -> ^b777    Should work fine
#  8)   R -> R -> N       ^b8 -> ^b88 -> ^h888    Should work fine
#  9)   R -> R -> R       ^b9 -> ^b99 -> ^b999    Should work fine
# ----  --------------    --------------------    -------------------------
#

# ------------------------------------------------------
# --- Create trigreplstate.trg file (input for mupip trigger)
cat << CAT_EOF  > trigreplstate.trg
-*
+^h0(subs=:)   -command=S -xecute="set ^h00(subs)=\$ztval+1"
+^h1(subs=:)   -command=S -xecute="set ^b11(subs)=\$ztval+1"
+^b2(subs=:)   -command=S -xecute="set ^h22(subs)=\$ztval+1"
+^b3(subs=:)   -command=S -xecute="set ^b33(subs)=\$ztval+1"
+^h4(subs=:)   -command=S -xecute="set ^h44(subs)=\$ztval+1"
+^h44(subs=:)  -command=S -xecute="set ^h444(subs)=\$ztval+1"
+^h5(subs=:)   -command=S -xecute="set ^h55(subs)=\$ztval+1"
+^h55(subs=:)  -command=S -xecute="set ^b555(subs)=\$ztval+1"
+^b6(subs=:)   -command=S -xecute="set ^h66(subs)=\$ztval+1"
+^h66(subs=:)  -command=S -xecute="set ^h666(subs)=\$ztval+1"
+^b7(subs=:)   -command=S -xecute="set ^h77(subs)=\$ztval+1"
+^h77(subs=:)  -command=S -xecute="set ^b777(subs)=\$ztval+1"
+^b8(subs=:)   -command=S -xecute="set ^b88(subs)=\$ztval+1"
+^b88(subs=:)  -command=S -xecute="set ^h888(subs)=\$ztval+1"
+^b9(subs=:)   -command=S -xecute="set ^b99(subs)=\$ztval+1"
+^b99(subs=:)  -command=S -xecute="set ^b999(subs)=\$ztval+1"
+^h0(subs=:)   -command=K -xecute="kill ^h00(subs)"
+^h1(subs=:)   -command=K -xecute="kill ^b11(subs)"
+^b2(subs=:)   -command=K -xecute="kill ^h22(subs)"
+^b3(subs=:)   -command=K -xecute="kill ^b33(subs)"
+^h4(subs=:)   -command=K -xecute="kill ^h44(subs)"
+^h44(subs=:)  -command=K -xecute="kill ^h444(subs)"
+^h5(subs=:)   -command=K -xecute="kill ^h55(subs)"
+^h55(subs=:)  -command=K -xecute="kill ^b555(subs)"
+^b6(subs=:)   -command=K -xecute="kill ^h66(subs)"
+^h66(subs=:)  -command=K -xecute="kill ^h666(subs)"
+^b7(subs=:)   -command=K -xecute="kill ^h77(subs)"
+^h77(subs=:)  -command=K -xecute="kill ^b777(subs)"
+^b8(subs=:)   -command=K -xecute="kill ^b88(subs)"
+^b88(subs=:)  -command=K -xecute="kill ^h888(subs)"
+^b9(subs=:)   -command=K -xecute="kill ^b99(subs)"
+^b99(subs=:)  -command=K -xecute="kill ^b999(subs)"
CAT_EOF

# This test relies on the default region configuration, disable spanning regions
setenv gtm_test_spanreg 0

setenv gtm_test_disable_randomdbtn
setenv test_specific_trig_file `pwd`/trigreplstate.trg
# Since we need ONLY ONE of the regions to be non-replicated, non-journaled, use gtm_test_repl_norepl to
# tell SRC.csh NOT to turn ON replication on HREG.
setenv gtm_test_repl_norepl 1
$gtm_tst/com/dbcreate.csh mumps 9

# --- Create trigreplstate.m application program
cat << \CAT_EOF  > trigreplstate.m
	set $etrap="do etr^trigreplstate"
	write "-----------------------",!
	write "# Do SETs",!
	write "-----------------------",!
	set i=-1
	set ^h0($increment(i))=i
	set ^h1($increment(i))=i
	set ^b2($increment(i))=i
	set ^b3($increment(i))=i
	set ^h4($increment(i))=i
	set ^h5($increment(i))=i
	set ^b6($increment(i))=i
	set ^b7($increment(i))=i
	set ^b8($increment(i))=i
	set ^b9($increment(i))=i
	write "-----------------------",!
	write "# Globals after the SET",!
	write "-----------------------",!
	do gbldisp
	;
	write "-----------------------",!
	write "# Do KILLs",!
	write "-----------------------",!
	set i=-1
	set ^b11(1)=2
	set ^b555(5)=7
	kill ^h0($increment(i))
	kill ^h1($increment(i))
	kill ^b2($increment(i))
	kill ^b3($increment(i))
	kill ^h4($increment(i))
	kill ^h5($increment(i))
	kill ^b6($increment(i))
	kill ^b7($increment(i))
	kill ^b8($increment(i))
	kill ^b9($increment(i))
	write "-----------------------",!
	write "# Globals after the KILL",!
	write "-----------------------",!
	do gbldisp
	quit
gbldisp	;
	; ------------------------------------------------------
	; display all global variables defined at this point
	;
	set x="^%" for  set x=$order(@x,1) q:x=""  set xstr="zwrite "_x  xecute xstr
	quit
etr	;
	write $zstatus,!
	set $ecode=""
	quit
\CAT_EOF

$gtm_exe/mumps -run trigreplstate

$gtm_tst/com/dbcheck.csh -extract
