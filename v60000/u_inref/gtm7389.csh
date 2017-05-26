#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2012-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

setenv check_all "DFL :|DFS :|JFL :|JFS :|JBB :|JFB :|JFW :|JRL :|JRP :|JRE :|JRO :|JRI :|JEX :|DEX :"
alias stats 	'$DSE dump -file -gvstats | & $grep -E "$check_all"'
alias mask 	"sed 's/0x................/0x##MASKED##/'"
alias resetstat '$DSE change -file -gvstatsreset >>& reset_stats.out ; if ($status) echo "gvststsreset FAILED"'


# Since there is nothing much to test without journaling on, enable it
setenv gtm_test_jnl "SETJNL"
# set epoch_interval to 300 to make sure JRI kicks in for sure before JRE
# set allocation and extension higher than the current defaults (2048) so that
# if the defaults are increased later, the number of updates required to make exactly one JEX and DEX need not change
setenv tst_jnl_str "$tst_jnl_str,epoch_interval=300,allocation=10240,extension=10240"
$gtm_tst/com/dbcreate.csh mumps 1

echo "# jnl str : GTM_TEST_DEBUGINFO $tst_jnl_str"
# Note down if it is before or nobefore image journaling, in order to compare against the right reference file
set b4nob4 = "nobefore"
echo $tst_jnl_str | $grep "nobefore" >& /dev/null
if ($status) set b4nob4 = "before"
cat << EOF
# test : Only DFL should exist when no global updates are done
# test : when a dse dump is done (i.e db flushed), DFL is incremented
EOF

stats >&! noupdate1.out
stats >&! noupdate2.out
$GTM << GTM_EOF
	do ^setenv("noupdate1.out","a")
	do ^setenv("noupdate2.out","b")
GTM_EOF

source noupdate1.out_env.csh
source noupdate2.out_env.csh
@ expected_DFL = $DFL_a + 1
if ("$DFL_b" == "$expected_DFL") then
	echo "STATS-I-PASS : On doing a dse dump, DFL increased exactly by 1"
else
	echo "STATS-E-DFL : On doing a dse dump DFL is expected to increment by 1. But did not happen"
	echo "Changed from $DFL_a to $DFL_b"
endif

echo "# Expect only DFL to be shown below"
stats | mask

cat << EOF
# test : For just one update, most of the stats should be deterministic. Do a diff with existing output
EOF

cat >> jnl_before.stat << jnlstat_EOF
  DFL : # of Database FLushes                   0x##MASKED##
  DFS : # of Database FSyncs                    0x0000000000000001
  JFL : # of Journal FLushes                    0x0000000000000002
  JFS : # of Journal FSyncs                     0x0000000000000004
  JBB : # of Bytes written to Journal Buffer    0x##MASKED##
  JFB : # of Bytes written to Journal File      0x##MASKED##
  JFW : # of Journal File Writes                0x000000000000000.
  JRL : # of Logical Journal Records            0x0000000000000001
  JRP : # of Pblk Journal Records               0x0000000000000002
  JRE : # of Regular Epoch Journal Records      0x0000000000000001
  JRO : # of Other Journal Records              0x0000000000000003
jnlstat_EOF


cat >> jnl_nobefore.stat << jnlstat_EOF
  DFL : # of Database FLushes                   0x##MASKED##
  JFL : # of Journal FLushes                    0x0000000000000002
  JFS : # of Journal FSyncs                     0x0000000000000004
  JBB : # of Bytes written to Journal Buffer    0x##MASKED##
  JFB : # of Bytes written to Journal File      0x##MASKED##
  JFW : # of Journal File Writes                0x000000000000000.
  JRL : # of Logical Journal Records            0x0000000000000001
  JRE : # of Regular Epoch Journal Records      0x0000000000000001
  JRO : # of Other Journal Records              0x0000000000000003
jnlstat_EOF

$gtm_exe/mumps -run %XCMD 's ^a=1'
stats >&! 1update.out
$tst_awk ' {if ($0 ~ /DFL : |JBB :|JFB :/) {sub("0x.*","0x##MASKED##")} ; if ($0 ~ /JFW :/) {sub("000[3-9]","000.")} ; print}' 1update.out >&! 1update_filtered.out
diff 1update_filtered.out jnl_{$b4nob4}.stat

# second set of updates
$gtm_exe/mumps -run %XCMD 'for i=1:1:25000 set ^a(1)=$j(1,200)'
stats >&! 2update.out

$GTM << GTM_EOF
	do ^setenv("1update.out",1)
	do ^setenv("2update.out",2)
GTM_EOF

source 1update.out_env.csh
source 2update.out_env.csh

cat << EOF
# test : JBB and JFB should be non-zero and increase for every global update
# test : JFW should increase by everytime we write jnlfile on disk
EOF

if ( ($JBB_2 > $JBB_1) && ($JFB_2 > $JFB_1) && ($JFW_2 > $JFW_1) ) then
	echo "STATS-I-PASS : JBB, JFB and JFW increased after jnl write operaion"
else
	echo "STATS-E-JBB. JBB, JFB and JFW should increase for every jnl write operation. Check 1update.out and 2update.out"
endif

cat << EOF
# test : JFB should be greater than JBB
EOF

if ( $JFB_2 > $JBB_2 ) then
	echo "STATS-I-PASS : JFB is greater than JBB as expected"
else
	echo "STATS-E-JFB : JFB is not greater than JBb, which is unexpected. Check 2update.out"
endif

cat << EOF
# test : JFL and JFS should increase for every journal update
EOF

if ( ($JFL_2 > $JFL_1) && ($JFS_2 > $JFS_1) ) then
	echo "STATS-I-PASS : JFL and JFS increased after jnl write operation"
else
	echo "STATS-E-JFL. JFL and JFS should increase for every jnl write. Check 1update.out and 2update.out"
endif

cat << EOF
# test : The set/kill above should have increased the JRL count
# test : The process that did set/kill will write a pini/pfin record and thus increase the JRO count
EOF

if ( ($JRL_2 > $JRL_1) && ($JRO_2 > $JRO_1) ) then
	echo "STATS-I-PASS : JRL and JRO increased after a global update operation"
else
	echo "STATS-E-JRL. JRL and JRO should have been increased by the process writing a global and exiting"
endif

cat << EOF
# test : For the updates done above, journal extension should have been seen
# test : Since the updates all happened to the same global, database extension should not have happened
EOF

if !($?JEX_2) set JEX_2 = 0
if ($JEX_2 == 1) then
	echo "STATS-I-JEX. JEX is 1 as expected"
else
	echo "STATS-E-JEX. JEX is expected to be 1 but is $JEX_2"
endif

if !($?DEX_2) then
	echo "STATS-I-DEX. DEX is not seen as expected"
else
	echo "STATS-E-DEX. DEX was not expected to happen at this point but has the value $DEX_2"
endif

# do sufficient updates to force exactly 1 database extension
$gtm_exe/mumps -run %XCMD 'for i=1:1:500 s ^a(i)=$j(1,200)'
stats >&! 3update.out
$GTM << GTM_EOF
	do ^setenv("3update.out",3)
GTM_EOF

source 3update.out_env.csh
cat << EOF
# test : For the updates done above database extension should have happened
EOF

if !($?DEX_3) set DEX_3 = 0
if ($DEX_3 == 1) then
	echo "STATS-I-DEX. DEX is 1 as expected"
else
	echo "STATS-E-DEX. DEX is expected to be 1, but is $DEX_3"
endif

# do sufficient updates to force more database and journal extensions
$gtm_exe/mumps -run %XCMD 'for i=1:1:50000 s ^b(i)=$j("DEX",200)'
stats >&! 4update.out
$GTM << GTM_EOF
	do ^setenv("4update.out",4)
GTM_EOF

source 4update.out_env.csh
cat << EOF
# test : For the updates done above more than one database and journal extensions should have happened
EOF

if ( ($JEX_4 > 2) && ($DEX_4 > 2) ) then
	echo "STATS-I-[JD]EX. JEX and DEX has increased as expected"
else
	echo "STATS-E-[JD]EX. For the updates done above, JEX and DEX is expected to increase higher, but is at JEX : $JEX_4 ; DEX : $DEX_4"
endif
# The hang 6 below is to write JRI stat.
# 1 second for db flush timer to kick in and flush the update, 5 seconds for the idle epoch timer to kick in and bump JRI, 4 more seconds to account load
# If JRI is not written in 10 seconds, let it error out and we will have to analyze
# do a ZSHOW "G":a before the "set ^jri=1" to set up the local variable "a" with enough memory structures allocated
# so later zshow "G" in the for loop does not call gtm_malloc which defers dbsync timer
# and in turn delays JRI appearance enough to cause false test failures <gtm7389_jri_gtm_malloc>
$gtm_exe/mumps -run %XCMD 'zshow "G":a set ^jri=1 hang 6 for i=7:1:10 zshow "G":a set jri=$piece($piece(a("G",0),"JRI:",2),",",1) quit:jri  hang 1'
stats >&! 5update.out
$GTM << GTM_EOF
	do ^setenv("5update.out",5)
GTM_EOF

source 5update.out_env.csh
cat << EOF
# test : After the single update and hang of more than 6 seconds, a JRI record should have been written
EOF

if !($?JRI_4) set JRI_4 = 0
if !($?JRI_5) set JRI_5 = 0
@ JRI_expected = $JRI_4 + 1
if ("$JRI_expected" == "$JRI_5") then
	echo "STATS-I-JRI. JRI increased by 1 as expected"
else
	echo "STATS-E-JRI. JRI was expected to increase by 1. but it changed from $JRI_4 to $JRI_5"
endif
$gtm_tst/com/dbcheck.csh
