#!/usr/local/bin/tcsh -f

# Test that update process identifies null subscripts in the global that is being replicated and issues 
# NULSUBSC error in the update process log. Prior to V5.4-001, gv_currkey->prev was not set in update 
# process and the global (containing null subscripts) was written to the database file

# The error in update process (NULSUBSC) will bring down the update process. Later when the passive source 
# server is shutdown, we want to avoid assert failures during IPC cleanup. Set the whitebox test case to 
# let the processes being shutdown know that the scenario is expected. 
setenv gtm_white_box_test_case_enable 1
setenv gtm_white_box_test_case_number 23

$echoline
echo "Test that NULSUBSC error is issued by the update process"
$echoline
echo ""

$gtm_tst/com/dbcreate.csh mumps 1
$DSE change -file -null=TRUE

# M Program
cat << CAT_EOF > nullsubs.m
nullsubs	;
		set act="Set ^CIF(""FIRST"",2"
		set r=\$random(10)
		; Randomly set the last or the last but one subscript to ""
		if (r<5)  DO
		.	set act=act_","""")=""Last"""
		else  DO
		.	set act=act_","""",""NONNULL"")=""Third"""
		xecute act
		quit
CAT_EOF

# Attempt to replicate globals with NULL subscripts
$gtm_exe/mumps -run nullsubs

$echoline
echo "Check for NULSUBSC error"
$echoline
echo ""
echo ""
# Check if update process has issued NULSUBSC error.
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/wait_for_log.csh -log RCVR_*.log.updproc -message NULSUBSC"
$sec_shell "$sec_getenv; cd $SEC_SIDE; $gtm_tst/com/check_error_exist.csh RCVR_*.log.updproc NULSUBSC"


# By this time, Update process would have aborted because of the NULSUBSC error. dbcheck done below would by default
# try to shutdown the primary source server and secondary passive source and receiver servers. However, since the 
# update process is not alive, we will see errors thrown out from RF_sync which is called by RF_SHUT (in turn called by 
# dbcheck) which we want to avoid. So, pass -noshut. However, we don't want the servers to be lurking around either. So,
# shut them down with explicit MUPIP REPLIC commands.  Also, release portno reservation files (would have been done by
# RF_SHUT)
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP replic -receiv -shutdown -timeout=0 ; $MUPIP replic -source -shutdown -timeout=0" >&! secondary_shut.out
$MUPIP replic -source -shutdown -timeout=0 >&! primary_shut.out
$gtm_tst/com/portno_release.csh
$gtm_tst/com/dbcheck.csh -noshut	# Do not check the database extracts as they will not match due to the NULSUBSC errors above
