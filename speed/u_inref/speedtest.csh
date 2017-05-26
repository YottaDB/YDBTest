#!/usr/local/bin/tcsh -f
# $1 = Local or, Global or, Global+reorg or, TP
# $2 = Sequential collating order of Keys or, Random Keys for successive updates
# $3 = Journal vs No journal
# $4 = number of region
# $5 = number of processes
# $6 = Number of types of operations to test (SET is one type, READ is another, $GET is another)
# $7 = Number of repeat of inner most test loop
#
# In case replication is on, $3 is not applicable.
# All tests will be run with journaling ON
setenv gtm_test_mupip_set_version "disable"
setenv gtm_test_disable_randomdbtn
source $gtm_tst/$tst/u_inref/setvar.csh
#
echo "Speed Test Starts"
#
echo "Global Variable: Ordered Keys: No Journaling: Multi-Process"
$gtm_tst/$tst/u_inref/main.csh "LOCKI" "SEQOP" "NOJNL" "1" "6" "1" "1"
#
echo "Profile Local Variable Test (Using Array) : No Journaling: Single-Process"
$gtm_tst/$tst/u_inref/main.csh "ZDSRTST1" "RANDOP" "NOJNL" "1" "1" "1" "1"
#
echo "Profile Local Variable Test (Using Named Locals) : No Journaling: Single-Process"
$gtm_tst/$tst/u_inref/main.csh "ZDSRTST2" "RANDOP" "NOJNL" "1" "1" "1" "1"
#
echo "Local Variable: Ordered Keys : No Journaling: Single-Process"
$gtm_tst/$tst/u_inref/main.csh "LCL" "SEQOP" "NOJNL" "6" "1" "2" "1" 
#
echo "Local Variable: Random Keys : No Journaling: Single-Process"
$gtm_tst/$tst/u_inref/main.csh "LCL" "RANDOP" "NOJNL" "6" "1" "8" "1" 
#
#
echo "Global Variable: Ordered Keys: No Journaling: Single-Process"
$gtm_tst/$tst/u_inref/main.csh "GBLS" "SEQOP" "NOJNL" "6" "1" "2" "1"
#
echo "Global Variable: Random Keys: No Journaling : Single-Process : READs done after MUPIP REORG"
$gtm_tst/$tst/u_inref/main.csh "GBLREORG" "RANDOP" "NOJNL" "6" "1" "2" "1"
#
echo "Global Variable: Random Keys: No Journaling : Single-Process"
$gtm_tst/$tst/u_inref/main.csh "GBLS" "RANDOP" "NOJNL" "6" "1" "2" "1"
#
#
echo "Global Variable: Random Keys: No Journaling : Multi-Process"
$gtm_tst/$tst/u_inref/main.csh "GBLM" "RANDOP" "NOJNL" "6" "6" "8" "1"
#
#
echo "Global Variable: Random Keys: No Journaling : TP BATCH : Multi-Process"
$gtm_tst/$tst/u_inref/main.csh "TPBA" "RANDOP" "NOJNL" "6" "6" "1" "1"
#
echo "Global Variable: Random Keys: Journaling : TP BATCH : Multi-Process"
$gtm_tst/$tst/u_inref/main.csh "TPBA" "RANDOP" "JNL" "6" "6" "1" "1"
#
echo "Global Variable: Random Keys: Journaling : TP ONLINE : Multi-Process"
$gtm_tst/$tst/u_inref/main.csh "TPON" "RANDOP" "JNL" "6" "6" "1" "1"
#
###
### Following is for computing speed test reference speed from ^run number of runs
### And Save the result files to LOGS directory
###
$gtm_tst/$tst/u_inref/check_result.csh
echo "Speed Test Ends..."
