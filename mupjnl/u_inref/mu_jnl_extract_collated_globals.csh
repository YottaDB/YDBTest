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
#
# If run with journaling, this test requires BEFORE_IMAGE so set that unconditionally even if test was started with -jnl nobefore
source $gtm_tst/com/gtm_test_setbeforeimage.csh
unset backslash_quote
alias check_mjf 'unset echo; $tst_awk -f $gtm_tst/$tst/inref/extract.awk -v "user=$USER" -v "host=$HOST:r:r:r" -v detail=1 \!:*; '

source $gtm_tst/com/cre_coll_sl_straight.csh 12
source $gtm_tst/com/cre_coll_sl_reverse.csh 21
echo $gtm_collate_12
echo $gtm_collate_21
$gtm_tst/com/dbcreate.csh . 1

$GTM << EOF
set x=\$\$set^%GBLDEF("^adata",1,21)      ; set collation number 1 for global "^adata" with nct = 0;
if 1'=x w "TEST-E-COL error setting up collation",!  ; we expect x to be 1 otherwise error in setting collation
write \$\$get^%GBLDEF("^adata")          ; we expect return value of 1,21,0
set x=\$\$set^%GBLDEF("^cdata",0,12)      ; set collation number 1 for global "^cdata" with nct = 0;
if 1'=x w "TEST-E-COL error setting up collation",!  ; we expect x to be 1 otherwise error in setting collation
write \$\$get^%GBLDEF("^cdata")          ; we expect return value of 0,12,0
h
EOF

# we turn journaling on after the collation of the globals were set as
# there is a known issue (the above commands do not write proper records to the jnl file)
$gtm_tst/com/jnl_on.csh
cp mumps.dat bak.dat

$GTM << EOF
SET ^adata("abcd",1,"zyxw")=\$C(10,11,12)
SET ^adata("zyxw",2,"abcd")=\$C(18,27,43)
SET ^adata(1)=1
SET ^adata(9)=9
SET ^bdata("efgh",3,"vuts")=\$C(57,69,78)
SET ^bdata("vuts",4,"efgh")=\$C(88,97,103)
SET ^bdata(1)=1
SET ^bdata(9)=9
SET ^cdata("ijkl",5,"rqpo")="data5"
SET ^cdata("rqpo",6,"ijkl")="data6"
SET ^cdata(1)=1
SET ^cdata(9)=9
d ^%G

*

EOF

echo $MUPIP journal -extract -for mumps.mjl -detail
$MUPIP journal -extract -for mumps.mjl -detail >& extract.out
$grep -v MUJNLSTAT extract.out
check_mjf mumps.mjf
#Expected result: Verify that the globals are extracted properly
#Return status: Extraction success

cp bak.dat mumps.dat
echo $MUPIP journal -recover -for mumps.mjl
$MUPIP journal -recover -for mumps.mjl >& recover.out
$grep -v MUJNLSTAT recover.out
$GTM << EOF
d ^%G

*

EOF
$gtm_tst/com/dbcheck.csh
