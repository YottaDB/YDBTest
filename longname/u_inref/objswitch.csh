#!/usr/local/bin/tcsh -f
# test compiled obj files across versions
# switch to older versions
set old_ver = $1
source $gtm_tst/com/switch_gtm_version.csh $old_ver $tst_image
#
$GTM << eof
write \$ZV
do ^objformt(1)
halt
eof
# take a backup of the compiled obj.
cp -p objformt.o objformtold.o
#
# switch back to the version being tested
source $gtm_tst/com/switch_gtm_version.csh $tst_ver $tst_image
$GTM << eof
write \$ZV
do ^objformt(1)
halt
eof
# This is to ensure the test throws error if obj file is not re-compiled
cmp objformt.o objformtold.o >& /dev/null
if ($?) then
	echo "CORRECT behavior routine is re-compiled"
else
	echo "TEST-E-ERROR OBJECT NOT RECOMPILED"
endif
# remove compiled object file & the source file from inrefdir. move the backedup obj. file to check in V5
rm -f objformt.o objformt.m
mv objformtold.o objformt.o
# this should error out
$GTM << eof
do ^objformt(1)
halt
eof
