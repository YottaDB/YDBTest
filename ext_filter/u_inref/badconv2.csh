#!/usr/local/bin/tcsh -f
echo "External Filter test with second mini-transaction given bad journal and stream sequence numbers by filter"
echo "The second transaction in a wrapped transaction is also given bad journal and stream sequence numbers by filter"
setenv gtm_tst_ext_filter_rcvr \""$gtm_exe/mumps -run ^badconv2"\"
$gtm_tst/com/dbcreate.csh mumps 1
setenv rcvrlogfile $SEC_SIDE/RCVR_*.log
setenv startout $SEC_SIDE/START_*.out

# Get the receiver server pid
setenv pidrcvr `$tst_awk '/Receiver server is alive/ {print $2}' $startout`

# Do the updates that would cause the FILTERBADCONV error in the receiver server log due to imposed bad jnlrec seqno for second one
$GTM << EOF
set ^abc=1234
set ^def=3456
tstart
set ^trabc="3456"
set ^trdef="4567"
tcommit
tstart
set ^trghi="3456"
set ^trjkl="4567"
tcommit

EOF
$gtm_tst/com/dbcheck.csh -extract
# Create mumps.mjf on secondary directory for analysis
(cd $SEC_SIDE; $gtm_tst/$tst/u_inref/analyze_mjf.csh)
echo
echo "Globals on secondary after badconv2:"
cat sec*.glo
