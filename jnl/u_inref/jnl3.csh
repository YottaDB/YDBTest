#!
# Once we add a good test for ZTP with lookback/since time disable this test.
#
#! jnl_1b1sp.csh: - 1 BG region (1b)
#!		  - 1 process terminating with success (1s)
#!		  - backward recovery followed by forward recovery
#!		  - fences processed (p)
#!
#!"*************** 1B1SP: 1 BG REGION, 1 PROC. , first BACK then FORWARD RECOVERY, FENCES PROCESSED ***************"
#
setenv gtmgbldir "myjnl3.gld"
source $gtm_tst/com/dbcreate.csh myjnl3 1 . . . 1000 256
#
#
if ($?test_replic == 0) then
	$MUPIP set -file -journal=enable,on,before,buff=2308 myjnl3.dat
endif
if (-f tmp.dat) then
    \rm -f tmp.dat
endif
cp myjnl3.dat tmp.dat
#
#
sleep 2
$GTM <<xxyy
w "s pass=16,start=1,commit=0",!  s pass=16,start=1,commit=0
w "d ^jnlbasf0",!  d ^jnlbasf0
w "h",!  h
xxyy
#
if (-f forward.mjl) then
    \rm -f forward.mjl
endif
cp myjnl3.mjl forward.mjl
$gtm_tst/com/dbcheck.csh "myjnl3" -extract
#
#!"***************"
#!"DB RECOVERY WITH ROLL BACKWARD"
#!"***************"
#
# Since time was saved after the ZTS record. So default lookback time will cause it to undo the broken transaction
set since_time = `cat time1.txt`
echo "$MUPIP journal -recover -verify -verbose -backward -since=$since_time -error=0 myjnl3.mjl" >& 1b1sp_roll_backward.log
$MUPIP journal -recover -verify -backward -verbose -since=\"$since_time\" -error=0 myjnl3.mjl >& 1b1sp_roll_backward.log
set stat1 = $status
#
$grep "successful" 1b1sp_roll_backward.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Jnl3 TEST FAILED" 
	cat  1b1sp_roll_backward.log
	exit 1
endif
#
$GTM <<yyxx
w "s pass=16",!  s pass=16
w "d ^jnlbasf1",!  d ^jnlbasf1
w "h",!  h
yyxx
#
#
$gtm_tst/com/dbcheck.csh "myjnl3"
if (-f myjnl3.dat) then
    \rm -f myjnl3.dat
endif
\cp -f tmp.dat myjnl3.dat
#
#!"***************"
#!"		DB RECOVERY WITH ROLL FORWARD "
#!"***************"
$MUPIP set -file -journal=off myjnl3.dat
echo "$MUPIP journal -recover -verify -forward -error=0 forward.mjl" >& 1b1sp_roll_forward.log
$MUPIP journal -recover -verify -forward -error=0 forward.mjl >& 1b1sp_roll_forward.log
set stat1 = $status
#
$grep "successful" 1b1sp_roll_forward.log
set stat2 = $status
if ($stat1 != 0 || $stat2 != 0) then
	echo "Jnl3 TEST FAILED" 
	cat  1b1sp_roll_forward.log
	exit 1
endif
#
$GTM <<xyxy
w "s pass=16",!  s pass=16
w "d ^jnlbasf1",!  d ^jnlbasf1
w "h",!  h
xyxy
#
#
$gtm_tst/com/dbcheck_base.csh "myjnl3"
#
#!"*************** 1B1SP COMPLETE ***************"
