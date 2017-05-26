#! /usr/local/bin/tcsh -f
#################################################################
#								#
# Copyright (c) 2003-2016 Fidelity National Information		#
# Services, Inc. and/or its subsidiaries. All rights reserved.	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################
echo "Test case 21: redirect_qualifier"
$gtm_tst/com/dbcreate.csh mumps 1
if ("ENCRYPT" == $test_encryption) then
	sed 's/mumps\.dat/redir.dat/' $gtm_dbkeys > ${gtm_dbkeys}.all
	cat $gtm_dbkeys >> ${gtm_dbkeys}.all
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.all gtmcrypt.cfg.all
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.all >>&! $gtmcrypt_config
endif
$gtm_tst/com/backup_dbjnl.csh save "*.dat" cp nozip
echo "mupip set -journal=enable,on,[no]before -reg *"
$MUPIP set $tst_jnl_str -reg "*"
$GTM << EOF
f i=1:1:5 s ^a(i)="a"_i
h
EOF
rm *.dat
echo -REDIRECT qualifier needs a value
echo mupip journal -recover -forw -redir mumps.mjl
$MUPIP journal -recover -forw -redir mumps.mjl
echo "------------------------------------------------------------------------"
$MUPIP journal -recover -forw -redir="mumps.dat=redir.dat" mumps.mjl
echo "------------------------------------------------------------------------"
cp ./save/mumps.dat redir.dat
echo mupip journal -recover -forw -redir="mumps.dat=redir.dat" mumps.mjl
$MUPIP journal -recover -forw -redir="mumps.dat=redir.dat" mumps.mjl
cp redir.dat mumps.dat
$GTM << EOF
f i=1:1:5 w ^a(i),!
EOF
echo "------------------------------------------------------------------------"
$gtm_tst/com/dbcheck.csh
$gtm_tst/com/backup_dbjnl.csh backup1 "*.dat *.mjl*" mv nozip
mv ./save backup1
setenv gtmcrypt_config gtmcrypt.cfg
$gtm_tst/com/dbcreate.csh mumps 4
if ("ENCRYPT" == $test_encryption) then
	$grep mumps.dat $gtm_dbkeys | sed 's/mumps\.dat/redir1.dat/' > ${gtm_dbkeys}.all
	$grep a.dat $gtm_dbkeys | sed 's/a\.dat/redir1.dat/' >> ${gtm_dbkeys}.all
	$grep a.dat $gtm_dbkeys | sed 's/a\.dat/redir2.dat/' >> ${gtm_dbkeys}.all
	$grep b.dat $gtm_dbkeys | sed 's/b\.dat/redir2.dat/' >> ${gtm_dbkeys}.all
	$grep a.dat $gtm_dbkeys | sed 's/a\.dat/save\/redir1.dat/' >> ${gtm_dbkeys}.all
	$grep b.dat $gtm_dbkeys | sed 's/b\.dat/save\/redir2.dat/' >> ${gtm_dbkeys}.all
	cat $gtm_dbkeys >> ${gtm_dbkeys}.all
	$gtm_dist/mumps -run CONVDBKEYS ${gtm_dbkeys}.all gtmcrypt.cfg.all
	mv $gtmcrypt_config ${gtmcrypt_config}.orig
	sed "s|##GTM_TST##|$gtm_tst|" gtmtls.cfg >&! $gtmcrypt_config
	cat ${gtmcrypt_config}.all >>&! $gtmcrypt_config
endif
$gtm_tst/com/backup_dbjnl.csh save "*.dat" cp nozip
echo "mupip set -journal=enable,on,[no]before -reg *"
$MUPIP set $tst_jnl_str -reg "*" |& sort -f
$GTM << EOF
s (^a,^b,^c,^d)=1
h
EOF
rm *.dat
cp -f ./save/*.dat .
mv a.dat redir1.dat
mv b.dat redir2.dat
echo mupip journal -recover -redir=\"a.dat=redir2.dat,mumps.dat=redir1.dat\" -forw '"*"'
$MUPIP journal -recover -redir="a.dat=redir2.dat,mumps.dat=redir1.dat" -forw "*"
echo "------------------------------------------------------------------------"
echo mupip journal -recover -redir=\"a.dat=redir1.dat,b.dat=redir2.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
$MUPIP journal -recover -redir="a.dat=redir1.dat,b.dat=redir2.dat" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
mv redir1.dat a.dat ;mv redir2.dat b.dat
$GTM << EOF
w ^a,^b,^c,^d
EOF
echo "------------------------------------------------------------------------"
\rm  *.dat
cp -f ./save/*.dat .
\mv ./save/a.dat ./save/redir1.dat
\mv ./save/b.dat ./save/redir2.dat
echo mupip journal -recover -redir=\"a.dat=./save/redir1.dat,b.dat=./save/redir2.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
$MUPIP journal -recover -redir=\"a.dat=./save/redir1.dat,b.dat=./save/redir2.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
cp -f ./save/redir1.dat ./a.dat
cp -f ./save/redir2.dat ./b.dat
echo "Now verify data"
$GTM << EOF
 w ^a,^b,^c,^d
EOF
echo "------------------------------------------------------------------------"
echo "Check for duplicates"
echo mupip journal -recover -redir=\"a.dat=b.dat,a.dat=c.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
$MUPIP journal -recover -redir=\"a.dat=b.dat,a.dat=c.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
echo mupip journal -recover -redir=\"a.dat=b.dat,c.dat=b.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
$MUPIP journal -recover -redir=\"a.dat=b.dat,c.dat=b.dat\" -forw mumps.mjl,a.mjl,b.mjl,c.mjl
echo "End of test"
$gtm_tst/com/dbcheck.csh
