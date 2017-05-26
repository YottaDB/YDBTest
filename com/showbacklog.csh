#!/usr/local/bin/tcsh -f
#########################################################################################################
# checks the backlog for a particular replication link
# The script is here is very simple right now
# It might be modified to check the backlog of the source of a link or just the receiver of a link
#########################################################################################################
if ($?gtm_test_replic_timestamp) then
	setenv chk_timestamp $gtm_test_replic_timestamp
else
	setenv chk_timestamp `date +%H:%M:%S`
endif
@ exit_status = 0
if ( "SRC" == "$1" ) then
	set otherargs = "$2"
	set sblog=`$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP replicate -source -showbacklog -instsecondary='$gtm_test_cur_sec_name' '$otherargs' >&! backlog'_${chk_timestamp}'.out;$grep "backlog number" backlog'_${chk_timestamp}'.out'|$tst_awk '{print $1}'`
	echo "Source backlog saved in $PRI_SIDE/backlog_${chk_timestamp}.out"
	if (0 != $sblog) then
		if ( "" == $sblog ) then
			# We don't print the error nor we set error exit status here.
			# Because as per MULTISITE flow sometimes we don't expect source/receiver to be up at this moment
			# instead we just give a message reporting the same
			echo "Source server NOT ALIVE at this point in time"
			echo "Pls. check $PRI_SIDE/backlog_${chk_timestamp}.out"
			@ exit_status = $exit_status + 1
		else
			# Backlog exists for source instance
			# echo "#$pri_shell "cat $PRI_SIDE/backlog_${chk_timestamp}.out"
		endif
	endif
endif
if ( "RCVR" == "$1" ) then
	set rblog=`$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP replicate -receiver -showbacklog >&! backlog'_${chk_timestamp}'.out;$grep "number of backlog " backlog'_${chk_timestamp}'.out'|$tst_awk '{print $1}'`
	echo "Receiver backlog saved in $SEC_SIDE/backlog_${chk_timestamp}.out"
	if (0 != $rblog) then
		if ( "" == $rblog ) then
			echo "Receiver server NOT ALIVE at this point in time"
			echo "Pls. check $SEC_SIDE/backlog_${chk_timestamp}.out"
			@ exit_status = $exit_status + 1
		else
			# Backlog exists for receiver instance
			# $sec_shell "cat $SEC_SIDE/backlog_${chk_timestamp}.out"
		endif
	endif
endif
exit $exit_status
#
