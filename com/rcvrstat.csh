#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2002, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# rcvrstat.csh <message to  print> <logfilestamp>
# Prints receiver side status (checkhealth and backlog)
# if <logfilestamp> is not specified, will use default logfiles

if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_pri_name"
	# reset gtm_test_instsecondary back to null if we see the current GT.M version used is pre multisite_replic
	setenv ver_chk `echo $gtm_exe:h:t`
	if ( ("V4" == `echo $ver_chk|cut -c1-2`) || ("V50000" == `echo $ver_chk|cut -c1-6`) ) setenv gtm_test_instsecondary
endif
cd $SEC_SIDE
setenv msg ""
if ("$1" != "") setenv msg "$1"
if ("$2" == "") then
	setenv chlogfile rcvr_checkhealth.log
	setenv sblogfile rcvr_showbacklog.log
else
	setenv chlogfile rcvr_checkhealth_$2.log
	setenv sblogfile rcvr_showbacklog_$2.log
endif

echo "Current Time:`date +%H:%M:%S`" >>&! $chlogfile
echo "Current Time:`date +%H:%M:%S`" >>&! $sblogfile
echo $msg >>&! $chlogfile
echo $msg >>&! $sblogfile

$MUPIP replicate -receiv -checkhealth >>& $chlogfile
# no_passive.out will be created by RCVR.csh when it decides to not start any passive source server and so we check that
# condition here.
if !(-e no_passive_$gtm_test_cur_pri_name.out ) $MUPIP replicate -source $gtm_test_instsecondary -checkhealth >>& $chlogfile
if (1 == $test_replic_suppl_type) $MUPIP replicate -source -instsecondary=supp_${gtm_test_cur_sec_name} -checkhealth >>& $chlogfile
$MUPIP replicate -receiv -showbacklog >>& $sblogfile
$gtm_tst/com/get_dse_df.csh "$msg"
