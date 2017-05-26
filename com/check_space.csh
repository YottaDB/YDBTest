#!/usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2002-2015 Fidelity National Information 	#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
# Uses cleanup.csh to determine directories to be checked.
# read/process the cleanup.csh passed in and do the analysis for all hosts/dirs listed in there
# If more directories are involved in a test run in the future, if cleanup.csh
# is kept up-to-date for the directories involved, no changes will be necessary
# to this script.

# backslash_quote is required to avoid Unmatched ' error
set backslash_quote
setenv sec_com 'echo HOSTNAME: $HOST; echo HOSTOS: $HOSTOS '
# Limit for disk space
# If this is invoked by submit.csh/gtmtest.csh i.e even before $tst_general_dir is created, redirect everything to /tmp
if ("submit" == "$1") then
	set tmpoutfile = ${TMP_FILE_PREFIX}_check_space_tmp.out
	set outfile = ${TMP_FILE_PREFIX}_check_space.out
	echo $sec_com | $tst_tcsh 	 >&! $tmpoutfile
	$df $tst_dir 			>>&! $tmpoutfile
else
	set cleanup_script = $tst_general_dir/cleanup.csh
	set tmpoutfile = check_space_$$_tmp.out
	set outfile = check_space_$$.out
	# The following is done in multiple sed commands just to keep the command and
	# quotation simple. We just use cleanup.csh to get list of host-directory
	# combinations and turn it into a list of commands that do df on those hosts
	# for those directories. We add the dummy "rm -rf $tst_general_dir" as well
	# since that is not listed in cleanup.csh, and it should be checked, and this
	# way it will be part of the list of commands. The contents of cleanup.csh plus
	# $tst_general_dir is the complete list of directories we need to check.
	( echo "rm -rf $tst_general_dir"; $grep "rm -rf" $cleanup_script ) | \
	   sed "s/$gtm_tst_out.*//g" | \
	   sed "/$ssh/s/[\']*rm -rf/\'$sec_com; $df /;/$ssh"'/s/$/\'/' | \
	   sed 's/rm -rf/tcsh -c \"$sec_com\"; $df/' | \
	   $grep -w df | \
	   uniq  | $tst_tcsh  >&! $tmpoutfile
endif

#now process that output and assess the situation
$tst_awk 'BEGIN {ll = '$gtm_test_disk_limit'}				\
	  {								\
		print $0;						\
		if ($1 ~ /HOSTNAME/) host = $2;				\
		if ($1 ~ /HOSTOS/) hostos = $2;				\
		dfline--;						\
		dffieldoffset = 0;					\
		if (prevline ~ /Filesystem/)				\
			dfline = 1;					\
		if ((0 < dfline) && (1 == NF))				\
			{dffieldoffset = 1; dfline++; next}		\
		if ("OS/390" == hostos)					\
			{x= NF-2; sub("/.*", "", $x); dffield = x}	\
		else							\
			{x= NF-2; dffield = x}				\
		dffield = dffield - dffieldoffset;			\
		if (0 < dfline)						\
		{							\
			dfval = $dffield;				\
			if (ll > dfval)					\
				print "TEST-E-SPACE, not enough space ("dfval" vs "ll") on " host " " $NF;\
		}							\
	  	prevline = $0;						\
	  }' $tmpoutfile > $outfile

$grep "TEST-E-SPACE" $outfile >& /dev/null
if (! $status) then
	echo "TEST-E-DISK, Number of free blocks is less than the acceptable limit. See $outfile for details"
	cat $outfile
	# If this is called by submit.csh/gtmtest.csh, send mail about space issue immediately as the entire test queue will be aborted.
	if ("submit" == "$1") then
		set ta = `$tst_awk '/TEST-E-SPACE/ {print $NF}' $outfile`
		du -ks $ta/* | sort -nr >>&! $outfile
		if (!($?tst_dont_send_mail)) then
			cat $outfile |  mailx -s "$HOST:r:r:r Lack of Space. Check du output" $mailing_list
		endif
	endif
	exit 1
endif
exit

