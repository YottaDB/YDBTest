#!/usr/local/bin/tcsh -f
$gtm_tst/com/dbcreate.csh mumps 1

echo "Valid M code in the Xecute string"
cat > compile_pass.trg << TFILE
+^a -command=S -xecute="xecute ""write \$ZTCOde,!"""
+^a -command=S -xecute="set b=""\$ztco"" xecute ""write @b,!"""
TFILE

# TODO move to manually start
# Run only on a system with smallfs
echo "Checking what happens with disk space issues GTM_DEFAULT_TMP / P_tmpdir"
setenv gtm_tmp `pwd`/nyah
mkdir -p $gtm_tmp
echo "Exhausting Disk Space!!"

# Use dd to fill disk
# need to validate the AWK script and /dev/zero
dd if=/dev/zero of=nyah/deleteme bs=1k count=`$df . | $tail -n 1 | awk '{print $4}'`
$load compile_pass.trg

# reclaim space!
rm -rf nyah

$gtm_tst/com/dbcheck.csh -extract
