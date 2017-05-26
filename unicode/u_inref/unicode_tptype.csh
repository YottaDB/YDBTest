#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2006-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
\rm -f *.o >>& obj.del
$switch_chset M
setenv gtmgbldir load.gld

# If null subscripts are not set in the secondary and if the npfill (done below) updates causes an update to a global with null
# subscripts, the update process on the secondary will issue a NULSUBSC error in the update process log. So, enable null susbcripts
# on the secondary as well by using test_specific_gde and executing it on both primary and secondary
#
cat << CAT_EOF >&! tptype.gde
change -segment DEFAULT -file=load.dat
add -name a* -region=areg
add -name A* -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a.dat
add -name b* -region=breg
add -name B* -region=breg
add -region breg -dyn=bseg
add -segment bseg -file=b.dat
change -reg DEFAULT -null=ALWAYS
change -reg AREG -null=ALWAYS
change -reg BREG -null=ALWAYS
CAT_EOF

$convert_to_gtm_chset tptype.gde
setenv test_specific_gde $tst_working_dir/tptype.gde

$gtm_tst/com/dbcreate.csh load 1

$GTM << xyz
do in2^npfill("set",2,2)
do in2^npfill("ver",2,2)
do in2^npfill("kill",2,2)
do ^unicodeJnlrec
h
xyz
\rm -f *.o >>& obj.del
$switch_chset UTF-8
$GTM << xyz
do in3^npfill("set",3,3)
do in3^npfill("ver",3,3)
do in3^npfill("kill",3,3)
h
xyz

# Since the journal will be switched and secondary side is extracted, sync primary and secondary
$gtm_tst/com/RF_sync.csh
# switch jornal file on primary side
$MUPIP set $tst_jnl_str -reg "*" >>& mup_set.log
# switch journal file on secondary side
$sec_shell "$sec_getenv; cd $SEC_SIDE; $MUPIP set $tst_jnl_str -reg '*' >>& mup_set.log "
set format="%d-%b-%Y %H:%M:%S"
set time1=`date +"$format"`
echo $time1 >& time1.txt
$GTM << bbb
  do ^c002201a
  do ^unicodeJnlrec
bbb
#
$gtm_tst/com/dbcheck.csh -extract
#
#
#TODO : In future put below in a script and use sec_shell, sec_getenv to call the script.
#       Otherwise, this is not good for multi-machine replication run
cd $SEC_SIDE
echo "extract file on secondary side on the journal file during c002201a"
set loadmjl = `ls -rt load.mjl | $tail -n 1`
echo $loadmjl >! loadmjl.filename
$MUPIP journal -extract=load2.mjf -for $loadmjl
echo "verify the secondary side extract file"
$tst_awk '{n=split($0,f,"\\"); if (f[1]=="05" || f[1]=="09") print f[n]}' load2.mjf
cd $PRI_SIDE
