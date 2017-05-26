#! /usr/local/bin/tcsh -f
#
#
echo ENTERING ONLINE7
#
#
setenv gtmgbldir online7.gld
setenv p_dir "`pwd`/online7"				# create the two testing directory
setenv bkp_dir "$p_dir/online7"
mkdir $p_dir
chmod 777 $p_dir
mkdir $bkp_dir
chmod 777 $bkp_dir
#
cd $p_dir
cp $gtm_tst/online_bkup/inref/mrtst.gde online7.gde		# create the two global directories and two sets of databases
$GDE << \cregbldir
@ online7.gde
exit
\cregbldir
$MUPIP create |& sort
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
$MUPIP set -reg "*" -journal=enable,on,nobefore |& sort
cd $bkp_dir
cp ../online7.gld .
$MUPIP create |& sort
source $gtm_tst/com/mupip_set_version.csh # re-do the mupip_set_version
source $gtm_tst/com/change_current_tn.csh # re-change the cur tn
#
cd $p_dir						# initiate testing database
$GTM << \mrtstinit
d ^mrtstbld
h
\mrtstinit
#							# start to restore from TCP for region ACCT
cd $bkp_dir
($MUPIP restore -nettimeout=240 acct.dat "tcp://${tst_host}:6200" &) >&! online77restore.log
#
cd $p_dir						# job the backup and start to update
$GTM << banking
s cmd="$MUPIP backup -i -t=1 -o -newjnlfiles -nettimeout=120 ACCT,ACNM,JNL,DEFAULT ""tcp://${tst_host}:6200"""
s cmd=cmd_",""./online7/acnm.inc"",""| gzip -c > ./online7/jnl.inc.gz"",""./online7/mumps.inc"""
w !,"cmd is ",cmd,!
job a^mrbackup(10,cmd):(out="online7b.out":err="online7b.log")
d ^mrtptst(10,3000)
d ^waitback
d ^mrverify
h
banking
#							# restore from the incremental backup.
cd $bkp_dir
($MUPIP restore jnl.dat "gzip -d -c jnl.inc.gz |" ) >&! online71restore.log
($MUPIP restore mumps.dat mumps.inc) >&! online72restore.log
($MUPIP restore acnm.dat acnm.inc) >&! online73restore.log 
grep "COMPLETED" online7*restore.log
#
cd $p_dir
cp $bkp_dir/*.dat $p_dir
$MUPIP journal -recover -noverify -fen=NONE -error=100 -forward acct.mjl,acnm.mjl,jnl.mjl,mumps.mjl
$GTM << \verify
d ^mrverify
h
\verify
#
echo LEAVING ONLINE7
