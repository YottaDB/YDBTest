#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2006, 2013 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
#
# This script is called by multisite_replic.awk to refresh active_links information file for a particular link
# It checks for the active servers running on the link by doing checkhealth operation and update the
# msr_active_links.txt accordingly.
#
if !( $?inside_multisite_replic ) then
	echo "TEST-E-REFRESHLINK error.This script should only be called thro'\$MSR action and not directly"
	echo "Sample Usage:"
	echo "\$MSR REFRESHLINKS INST1 INST2"
	exit 1
endif
set file=$tst_working_dir/msr_active_links.txt
# the name of this tmpfile is important for MSR scripts to recognize the change in link informations
set tmpfile=$tst_working_dir/msr_links_temp.txt
set refresh_file=$tst_working_dir/refreshlinks_${gtm_test_replic_timestamp}.out
#
cp $file $tmpfile
# collect current status
$pri_shell "$pri_getenv; cd $PRI_SIDE;"'$MUPIP'" replicate -source -instsecondary=$gtm_test_cur_sec_name -checkhealth" >&! refreshlinks_pri_checkhealth_${gtm_test_replic_timestamp}.outx
$grep -q 'Source server is alive' refreshlinks_pri_checkhealth_${gtm_test_replic_timestamp}.outx
set pri_health = $status

$sec_shell "$sec_getenv; cd $SEC_SIDE;"'$MUPIP'" replicate -receiver -checkhealth" >&! refreshlinks_sec_checkhealth_${gtm_test_replic_timestamp}.outx
$grep -q 'Receiver server is alive' refreshlinks_sec_checkhealth_${gtm_test_replic_timestamp}.outx
set sec_health = $status

$grep "ACTIVE_LINKS_SRCTO	$pri_node	" $file |& $grep -q $sec_node
set pri_link_stat = $status
$grep -q "ACTIVE_LINKS_RCVFROM	$sec_node	$pri_node" $file
set sec_link_stat = $status
#
# update primary side of the link
if ( ($pri_health) && (!($pri_link_stat)) ) then
	# action -removal
	$tst_awk '{if ($0 ~ /ACTIVE_LINKS_SRCTO	'$pri_node'	/) {gsub(/,'$sec_node'/,"",$0);gsub(/'$sec_node',/,"",$0);gsub(/'$sec_node'/,"",$0)};print $0}' $file >&! $tmpfile
	# we need one more iteration to ensure and remove the empty srcto link after the above operation
	$tst_awk '{if ($3 != "") print $0}' $tmpfile >&! /tmp/emptylink_{$$}
	mv /tmp/emptylink_{$$} $tmpfile
	echo "REMOVED - ACTIVE_LINKS_SRCTO $pri_node $sec_node from the links file" >&! $refresh_file
else if ( (!($pri_health)) && ($pri_link_stat) ) then
	# action -addition
	if (`$grep "ACTIVE_LINKS_SRCTO	$pri_node	" $file|wc -l`) then
		$tst_awk '{if ($0 ~ /ACTIVE_LINKS_SRCTO	'$pri_node'	/) print $0",'$sec_node'"}' $file >&! $tmpfile
	else
		echo "ACTIVE_LINKS_SRCTO	$pri_node	$sec_node" >&! tmptmpfile
	endif
	echo "ADDED - ACTIVE_LINKS_SRCTO $pri_node $sec_node to the links file" >&! $refresh_file
else
	echo "MSR-I-REFRESHLINKS, no refresh on the PRIMARY side required.links info uptodate!" >&! $refresh_file
endif
# the cp again is for a refresh that needs both ends updation.No harm in doing it for regular RUN stuffs too.
cp $tmpfile $file
# update secondary side of the link
if ( ($sec_health) && (!($sec_link_stat)) ) then
	# action -removal
	$tst_awk '{if ($0 !~ /ACTIVE_LINKS_RCVFROM	'$sec_node'	'$pri_node'/) print $0}' $file >&! $tmpfile
	echo "REMOVED - ACTIVE_LINKS_RCVFROM $sec_node $pri_node form the links file" >>&! $refresh_file
else if ( (!($sec_health)) && ($sec_link_stat) ) then
	# action -addition
	echo "ACTIVE_LINKS_RCVFROM	$sec_node	$pri_node" >>&! tmptmpfile
	echo "ADDED - ACTIVE_LINKS_RCVFROM $sec_node $pri_node to the links file" >>&! $refresh_file
else
	echo "MSR-I-REFRESHLINKS, no refresh on the RECEIVER side required.Links info uptodate!" >>&! $refresh_file
endif
if ( -e tmptmpfile ) then
	cat tmptmpfile >>&! $tmpfile
	\rm -f tmptmpfile
endif
#
