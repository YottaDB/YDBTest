#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2010-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#                                                               #
# Copyright (c) 2017-2022 YottaDB LLC and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
#-------------------------------------------------------------------------------------
# List of subtests of the form "subtestname [author] description"
# parse_valid		[ABS] test parsing of valid entries in trigger file
# parse_validname	[ABS] test parsing of valid names in trigger file
# parse_longname	[ABS] test parsing of long names in trigger file
# parse_invalidname	[ABS] test parsing of invalid names in trigger file
# parse_invalid		[ABS] test parsing of invalid entries in trigger file
# parse_invplusminus	[ABS] test parsing of invalid triggers using plus and minus
# mupiptrigger		[ABS] test mupip trigger [-triggerfile=] [-select=""] operations
# compile		[ABS] test compilation of XECUTE string in a trigger for load and execution
# isvcheck		[ABS] test trigger ISV inside and outside of triggers
# poundt		[ABS] test ^#t visibility (runtime,extract,load) and no triggers are invoked during a mupip load
# testxecute		[ABS] test trigger execution
# testpieces		[ABS] test the execution of triggers with pieces
# testxecutedepth	[ABS] test trigger execution depth
# zgoto			[ABS] test Goto and ZGoto within triggers
# journaltrigger	[ABS] test the basic functionality for triggers and journalling
# replictrigger		[ABS] test the basic functionality for triggers and repliccation
# merrorhandling	[ABS] trigger error handling in M
# mupiperror		[ABS] trigger error handling in mupip
#### restarts		[ABS] TRESTART testing using trigger loads to restart transactions - removed in favor of trigthrash
# stringpool		[ABS] special test to validate garbage collection is working correctly
# dbbadkynm		[MSC] test to show that a global ^#var other than ^#t gives an integrity error
# nested_error		[NR]  test of a secondary (nested) error inside $etrap AFTER a primary COMITROLBKINTRG error
# trigreplstate		[NR]  test TRIGREPLSTATE error
# updateerrors		[ABS] testing whether updates occur when $ECODE is and isn't cleared
# trig_nest_err		[MSC] show error generated for triggered external call doing a call-in
# ztworm_restart_rlbk 	[S7KK] test ztwormhole records across multi-region tp transaction and TRESTARTS/TROLLBACKS
# ztriginvact		[ABS] test ZTRIGINVACT error
# trigzintrpt		[MSC] test $ZJOBEXAM and $ZINTERRUPT with triggered global
# trigreference		[MSC] show $reference is maintained by triggers inspite of .gld file changes
# trigrlbk		[S7KK] test that trollback inside triggers works as expected and TRIGTLVLCHNG is issued appropriately
# trigcommit		[S7KK] test that tcommit inside triggers works issues TRIGTCOMMIT appropriately
# trigincrement		[MSC] show $increment operation with triggers
# trigmupipload		[MSC] test to show mupip load does not fire triggers on primary or secondary
# trigcompfail		[MSC] modify trigger in database and get error message when executing. Change it back and run again
# ztworepl		[ABS] test $ztwormhole in the journal and replication stream
# triginvchset		[S7KK] test that errors (like TRIGINVCHSET) issued while trigger processing does not leave things
#				in a bad state (eg. gv_currkey and gv_target out-of-sync)
# ztwo2big		[ABS] test ZTWORMHOLE2BIG error
# trignameuniq 		[s7kk] test TRIGNAMEUNIQ error
# file_output		[SLJ] Make sure trigger load information can be captured in a file
# ztrig_nonull		[SLJ] Test that $ztrigger doesn't put a NULL on the following commands mval
# trigdefbad		[S7KK] Test TRIGDEFBAD error
# trigcol		[SE] Collation in trigger range test
# trigsubscrange	[ABS] Test trigsubscrange error
# isvstacking		[MSC] Test the nesting of intrinsic special variables related to triggers
# maxparse_small	[ABS] test parsing of maximum values with an ultra small DB waiting on C9J10-003204
# maxparse_default	[ABS] test parsing of maximum values with a default sized DB
# maxparse_medium	[ABS] test parsing of maximum values with a medium (aka half of max values) sized DB
# maxparse_large	[ABS] test parsing of maximum values with a large (all max values) sized DB
# trigzsy		[ABS] test zsystem calls from a trigger
# ztrigio		[MSC] test io inside of triggers
# symmetry		[ABS] symmetry of trigger installation
# chainVnest		[ABS] test for a bug in trigger matching
# trigmprof		[ABS] test mprofiling with triggers
# ztriggvn		[ABS] update GVN with the result of $ztrigger
# gvsuboflow		[ABS] op_fnztrigger should take care NOT to restore gv_currkey->top
# testxecuteunicode	[ABS] test matching of unicode subscripts
# testpiecesunicode	[ABS] test delimiting and pieces of unicode $ztvalues
# trigcolunicode	[ABS] test external collation library with triggers
# trigbadchar		[ABS] generate BADCHAR from trigger installs, put unicode characters where they should not go
# trigdefnosync 	[S7KK] test trigged definition out-of-sync between primary and secondary
# utf8erroflow		[LP] test error message buffer overflow UTF-8 mode
# merroflow		[LP] test error message buffer overflow M mode
# msg_append		[SLJ] Check that error message from a trapped error does not print as part of a $ztrigger error
# zsyconflict		[ABS] hit TPNOTACID inside an implicit transaction
# trigblocksplit	[ABS] test where the explicit update causes an extra block split
# ztslate		[ABS] test the properties of ztslate
# ztriggercmd		[ABS] test the ztrigger command
# multiline		[ABS] Test multiline trigger support
# dztriggerintp		[ABS] $ztrigger function inside an explicit transaction
# implicitrlbk		[ABS] test implicit rollbacks on halt for implicit transactions (testing halt in triggers)
# lvnstacking		[ABS] test the stacking of local variables used for subscripts
# trigzsyxplode		[ABS] hit TPNOTACID using zsystems in implicit and explicit transaction started many ways
# nodztrigintrig	[ABS] $ztrigger function not allowed inside an implicit transaction
# zbspfortrig		[ABS] ZPrint, ZStep and ZBreak with triggers
# trigreplstack 	[ABS] using $STACK to drop below the trigger stack frame yields interesting results
# trigzsource		[ABS] trigger compilation should not affect zsource
# trigthrash		[SE] various trigger thrash (stress) subtests
# trigmodintp		[nars] Test that triggers can be installed & fired inside the same TP transaction without any TRIGMODINTP errors
# trigxcalls		[ABS] testing external calls from a trigger
# trigreadonly 		[SE] Test setting/using triggers on a R/O database
# nullsub		[zouc] Test null subscript for triggers
# gtm7509		[HK] primary and secondary can have different sets of triggers and can continue to replicate fine with on-the-fly trigger changes on primary
# gtm8019		[HK] Trigger deletion by name should not error out if the named trigger does not exist
# randomtriggers	[nars] Test MUPIP TRIGGER with randomly generated triggers
# xecutelimits		[nars] Test multi-line trigger XECUTE string limits
# gtm7522a		[nars] Test that TRIGGER SELECT operations happen under a TP fence
# gtm7522b		[nars] Test $ztrigger output with incremental trollbacks AND explicit restarts
# gtm7522c		[nars] Test $ztrigger output with concurrency related restarts
# gtm7522d		[nars] Test for MREP <imptp_process_terminates> (spurious trigger-already-exists error from trigger inserts)
# gtm6901		[kishore] Triggers visibility test case related to GTM-6901 - trigger operations with different globaldirs, different DEFAULT regions and a shared region
# gtm6901a		[nars] Test TRIGGER LOADS & DSE ADD -REC honor new max-rec-size convention (only value part, key not included)
# gtm7678		[kishore] Changes to how -OPTIONS are treated by mupip trigger
# gtm7877		[kishore] support GT.M triggers for globals that span multiple regions
# gtm7877a		[kishore] support GT.M triggers for globals that span multiple regions
# trigxcalls		[ABS] testing external calls from a trigger
# gtm8207stdnull	[ABS] Ensure that $ztwormhole is not corrupted by internal filters doing NULLSUBSC_TRANSFORM_IF_NEEDED
# gtm7083/gtm7083a	[kishore] mupip trigger -upgrade test cases
# zprint		[kishore] various test cases for zprint/$text()/zbreak
# gtm8273		[ABS] ZPrint and $Text() using just label+offset now work inside of triggers
# gtm8389		[ABS] ZPrint and $TEXT() of a deleted trigger that was previously ZPrint or $TEXT() should still work
# gtm8399		[shaha] Trigger deletion should delete ^#t entries even in the face of TRIGDEFBAD
# gtm8342		[shaha] Test to verify that MUPIP TRIGGER does not prompt for user input more than once
# ydb500		[SE] Test simpleapi SET of global driving trigger driving nonexistent routine recovers properly
# ydb596		[nars] Test that $ZTDELIM is also maintained for KILL/ZKILL/ZTRIG trigger actions
#-------------------------------------------------------------------------------------

setenv gtm_test_trigger 1

unsetenv gtm_trigger_etrap

setenv gtm_poollimit 0 # setting gtm_poollimit causes transactions to restart. A lot of subtests rely on restarts not happening.

setenv load "$gtm_tst/com/trigger_load.csh"
setenv append "$gtm_tst/com/trigger_load.csh"
setenv remove "$gtm_tst/com/trigger_load.csh"
setenv drop "$gtm_tst/com/trigger_unload.csh"
setenv show "$gtm_tst/com/trigger_select.csh"

# Test on-the-fly trigger upgrade code if prior GT.M versions are available
if (! $?gtm_test_nopriorgtmver) then
	setenv gtm_test_trig_upgrade 1
endif

# the tst_ld_sidedeck change is required for external call in trig_nest_err
if ( "os390" == $gtm_test_osname ) then
	# Save the normal LIBPATH and append the desired paths for call ins to work
	set old_libpath=${LIBPATH}
	setenv LIBPATH ${tst_working_dir}:${gtm_exe}:.:${LIBPATH}
	# Apparently on z/OS the the sidedeck must be specified for the call out DLL
	setenv tst_ld_sidedeck "-L$gtm_dist $tst_ld_yottadb"
else
	setenv tst_ld_sidedeck ""
endif

echo "triggers test BEGIN."

# List the subtests separated by spaces under the appropriate environment variable name
setenv subtest_list_common     "parse_valid parse_validnames parse_longnames "
setenv subtest_list_common     "$subtest_list_common parse_invalidnames parse_invalid parse_invplusminus"
setenv subtest_list_common     "$subtest_list_common mupiptrigger symmetry"
setenv subtest_list_common     "$subtest_list_common testxecute testpieces testxecutedepth"
setenv subtest_list_common     "$subtest_list_common zgoto isvcheck compile"
setenv subtest_list_common     "$subtest_list_common journaltrigger stringpool ztriginvact"
setenv subtest_list_common     "$subtest_list_common trigzintrpt trigreference trigincrement trigmupipload"
setenv subtest_list_common     "$subtest_list_common ztwo2big file_output ztrig_nonull trigcol"
setenv subtest_list_common     "$subtest_list_common isvstacking trigzsy ztriggvn gvsuboflow"
setenv subtest_list_common     "$subtest_list_common overflow msg_append zsyconflict trigblocksplit"
setenv subtest_list_common     "$subtest_list_common ztslate ztriggercmd multiline"
setenv subtest_list_common     "$subtest_list_common dztriggerintp implicitrlbk lvnstacking"
setenv subtest_list_common     "$subtest_list_common trigmodintp gtm8019 randomtriggers xecutelimits"
setenv subtest_list_common     "$subtest_list_common gtm7522a gtm7522b gtm7522c gtm7522d trigmemleak"

# Non-replic tests
setenv subtest_list_non_replic "dbbadkynm merrorhandling trig_nest_err updateerrors trigrlbk trigcommit"
setenv subtest_list_non_replic "$subtest_list_non_replic trigcompfail triginvchset trignameuniq"
setenv subtest_list_non_replic "$subtest_list_non_replic trigdefbad nested_error trigsubscrange"
setenv subtest_list_non_replic "$subtest_list_non_replic maxparse_default maxparse_medium maxparse_large"
setenv subtest_list_non_replic "$subtest_list_non_replic ztrigio chainVnest trigmprof nodztrigintrig trigzsyxplode"
setenv subtest_list_non_replic "$subtest_list_non_replic zbspfortrig trigzsource trigxcalls trigreadonly nullsub"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm6901 gtm6901a gtm7678 gtm7877 gtm7877a gtm7083 zprint"
setenv subtest_list_non_replic "$subtest_list_non_replic gtm8273 gtm8389 gtm8399 gtm8342 poundt ydb500 ydb596"

setenv subtest_list_non_replic_FE "trigthrash"

# Replic tests
setenv subtest_list_replic     "replictrigger ztworm_restart_rlbk ztworepl trigreplstate trigdefnosync"
setenv subtest_list_replic     "$subtest_list_replic trigreplstack gtm7509 gtm8207stdnull gtm7083a"

# Unicode tests
setenv unicode_testlist		"testxecuteunicode testpiecesunicode trigcolunicode "
setenv unicode_testlist		"$unicode_testlist trigbadchar"
if ($?test_replic == 1) then
	setenv subtest_list "$subtest_list_common $subtest_list_replic"
else
	setenv subtest_list "$subtest_list_common $subtest_list_non_replic"
	if ("L" != $LFE) then
		setenv subtest_list "$subtest_list $subtest_list_non_replic_FE"
	endif
endif

# Exclude tests that we know will fail due to randomization changes
# All
setenv subtest_exclude_list ""
# Non-replic
setenv subtest_exclude_list "$subtest_exclude_list zbspfortrig "

# The following subtest is temporarily disabled. Remove the below line when GTM-7507 is fixed.
setenv subtest_exclude_list "$subtest_exclude_list trigrlbk"

# filter out some subtests for some servers
set hostn = $HOST:r:r:r

## test unicode condition ##
if ("TRUE" == $gtm_test_unicode_support) then
	setenv subtest_list "$subtest_list $unicode_testlist"
else
	# hosts that don't support Unicode (like beowulf OSF1/Tru64) cannot run this test.
	# triginvchset is a unicode specific test, so it must be remove here.
	setenv subtest_exclude_list "$subtest_exclude_list triginvchset"
endif

# On a non-gg server, filter out tests that require specific GG setup
if ($?gtm_test_noggtoolsdir) then
	# trigthrash subtest requires $cms_tools/gtmpcatfldbld.csh
	setenv subtest_exclude_list "$subtest_exclude_list trigthrash"
endif

# If the platform/host does not have prior GT.M versions, disable tests that require them
if ($?gtm_test_nopriorgtmver) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm7083 gtm7083a"
else if ("dbg" == "$tst_image") then
       # We do not have dbg builds of versions [V54002,V62000] needed by the gtm7083 subtest so disable it.
       setenv subtest_exclude_list "$subtest_exclude_list gtm7083"
else if ("suse" == $gtm_test_linux_distrib) then
	# Disable gtm7083 subtest on SUSE Linux as we don't have the needed old versions
	# on that distribution (due to no libncurses.so.5 package)
	setenv subtest_exclude_list "$subtest_exclude_list gtm7083"
endif

# For the gtm7083a subtest, look at two things (env var and dbg builds) to decide whether to disable it or not.
set exclude_gtm7083a = 0
if ($?ydb_test_exclude_gtm7083a) then
	if ($ydb_test_exclude_gtm7083a) then
		# An environment variable is defined to indicate the below subtest needs to be disabled on this host
		set exclude_gtm7083a = 1
	endif
endif
if ("dbg" == "$tst_image") then
       # We do not have dbg builds of V62000 needed by the gtm7083a subtest so disable it.
	set exclude_gtm7083a = 1
endif
if ($exclude_gtm7083a) then
       setenv subtest_exclude_list "$subtest_exclude_list gtm7083a"
endif

# Submit the list of subtests
$gtm_tst/com/submit_subtest.csh

if ( "os390" == $gtm_test_osname ) then
	# Restore the normal LIBPATH
	setenv LIBPATH $old_libpath
	unsetenv tst_ld_sidedeck
endif

echo "triggers test END."
