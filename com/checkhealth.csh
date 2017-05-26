#!/usr/local/bin/tcsh -f
###################################################################################################
# checks whether the given replication link is alive
###################################################################################################
if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
endif
# Let's have one more variable as gtm_test_instsecondary_1 as this script deals with both primary and secondary sides.
if (! $?gtm_test_instsecondary_1 ) then
	setenv gtm_test_instsecondary_1 "-instsecondary=$gtm_test_cur_pri_name"
endif
if ($?gtm_test_replic_timestamp) then
	setenv chk_timestamp $gtm_test_replic_timestamp
else
	setenv chk_timestamp `date +%H:%M:%S`
endif

# Chechhealth may return non-zero status because of fake enospc. For this reason, we explicitly look for "server is alive" string from checkhealth output.
# We put results to checkhealth_${chk_timestamp}.out file because multisite_replic does a "cat *${chk_timestamp}*". We have outrefs that depend on particular sequence
# of this so we can't break checkhealth_${chk_timestamp}.out into smaller files.
@ exit_status = 0
if ( "RCVR" != "$1" ) then
	echo "$MUPIP replicate -source $gtm_test_instsecondary -checkhealth" >&! checkhealth_${chk_timestamp}.out
	$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP'" replicate -source $gtm_test_instsecondary -checkhealth |& tee chk_part_${chk_timestamp}.out >>&! checkhealth_${chk_timestamp}.out"
	set pri_stat = `$pri_shell "$pri_getenv; cd $PRI_SIDE; "'$grep'" -q 'server is alive' chk_part_${chk_timestamp}.out; echo '$status'; rm chk_part_${chk_timestamp}.out"`
	if ($pri_stat) then
		echo "##############################################################"
	#	we don't flag it as TEST-E- messages because for multisite we expect it to be that way sometimes.
		echo "Active source server not alive for instance at "$PRI_SIDE
		$pri_shell "cat $PRI_SIDE/checkhealth_${chk_timestamp}.out"
		echo "##############################################################"
		@ exit_status = $exit_status + 1
	endif
endif
if ( "SRC" != "$1" ) then
	echo "$MUPIP replicate -source $gtm_test_instsecondary -checkhealth" >&! checkhealth_${chk_timestamp}.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP'" replicate -source $gtm_test_instsecondary_1 -checkhealth |& tee chk_part_${chk_timestamp}.out >>&! checkhealth_${chk_timestamp}.out"
	set sec_stat_p = `$sec_shell "$sec_getenv; cd $SEC_SIDE; "'$grep'" -q 'server is alive' chk_part_${chk_timestamp}.out; echo '$status'; rm chk_part_${chk_timestamp}.out"`
	echo "$MUPIP replicate -receiver -checkhealth" >>&! checkhealth_${chk_timestamp}.out
	$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP'" replicate -receiver -checkhealth |& tee chk_part_${chk_timestamp}.out >>&! checkhealth_${chk_timestamp}.out"
	set sec_stat_r = `$sec_shell "$sec_getenv; cd $SEC_SIDE; "'$grep'" -q 'server is alive' chk_part_${chk_timestamp}.out; echo '$status'; rm chk_part_${chk_timestamp}.out"`
	if ($sec_stat_p) then
		echo "##############################################################"
		echo "Passive source server not alive for instance at "$SEC_SIDE
		$sec_shell "cat $SEC_SIDE/checkhealth_${chk_timestamp}.out"
		echo "##############################################################"
		@ exit_status = $exit_status + 1
	endif
	if ($sec_stat_r) then
		echo "##############################################################"
		echo "Receiver server not alive for instance at "$SEC_SIDE
		$sec_shell "cat $SEC_SIDE/checkhealth_${chk_timestamp}.out"
		echo "##############################################################"
		@ exit_status = $exit_status + 1
	endif
endif
exit $exit_status
#
