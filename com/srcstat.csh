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
# srcstat.csh <message to  print> <logfilestamp>
# Prints source side status (checkhealth and backlog)
# if <logfilestamp> is not specified, will use default logfiles

if (! $?gtm_test_instsecondary ) then
	setenv gtm_test_instsecondary "-instsecondary=$gtm_test_cur_sec_name"
	# reset gtm_test_instsecondary back to null if we see the current GT.M version used is pre multisite_replic
	setenv ver_chk `echo $gtm_exe:h:t`
	if ( ("V4" == `echo $ver_chk|cut -c1-2`) || ("V50000" == `echo $ver_chk|cut -c1-6`) ) setenv gtm_test_instsecondary
endif
cd $PRI_SIDE
setenv msg "No_Msg"
if ("$1" != "") setenv msg "$1"
if ("$2" == "") then
	setenv chlogfile src_checkhealth.log
	setenv sblogfile src_showbacklog.log
else
	setenv chlogfile src_checkhealth_$2.log
	setenv sblogfile src_showbacklog_$2.log
endif

echo "--------------------------------------------" >>&! $chlogfile
echo "--------------------------------------------" >>&! $sblogfile
echo "Current Time:`date +%H:%M:%S`" >>&! $chlogfile
echo "Current Time:`date +%H:%M:%S`" >>&! $sblogfile
echo $msg >>&! $chlogfile
echo $msg >>&! $sblogfile
$MUPIP replicate -source $gtm_test_instsecondary -checkhealth >>& $chlogfile
$MUPIP replicate -source $gtm_test_instsecondary -showbacklog >>& $sblogfile
$gtm_tst/com/get_dse_df.csh "$msg"
