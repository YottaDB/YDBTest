#!/usr/local/bin/tcsh -f
#
#######################################################################################
# the script checks databse after MUPIP reorg ( upgrade/downgrade)		      #
# the check is for INCTN,PBLK record existence.		 			      #
# usage of the script.								      #
# $gtm_tst/$tst/u_inref/check_inctn_pblk.csh <inctn pblk record value as given below> #
# <inctn pblk record value> accepts four values.				      #
# 00 - for "has no" inctn , "has no" pblk					      #
# 01 - for "has no" inctn , "has" pblk						      #
# 10 - for "has" inctn , "has no" pblk						      #
# 11 - for "has" inctn , "has" pblk						      #
#######################################################################################
#
# set variables to adjust condition check based on the caller
switch ($1)
case "00":
   set op1="!="
   set op2="!="
   breaksw
case "01":
   set op1="!="
   set op2="=="
   breaksw
case "10":
   set op1="=="
   set op2="!="
   breaksw
case "11":
   set op1="=="
   set op2="=="
   breaksw
default :
      echo "Pls. specify proper INCTN,PBLK value"
      breaksw
endsw
#
$MUPIP journal -extract=extr1.out -detail -forward mumps.mjl >>&! mupip_show.out
if ( 0 $op1 `grep "INCTN" extr1.out|wc -l` || 0 $op2 `grep "PBLK" extr1.out|wc -l` ) then
        echo "TEST-E-ERROR.INCTN,PBLK records incorect"
else
	echo ""
	echo "INCTN PBLK record check PASS"
	echo ""
endif
