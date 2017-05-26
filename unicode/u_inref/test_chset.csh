#!/usr/local/bin/tcsh
#
# print $ZCHSET value based on environment variable gtm_chset
# accepts two arguments
# Sample Usage: $gtm_tst/$tst/u_inref/print_chset.csh <$gtm_chset value to be set> <expected result>
if ( 2 > $#argv ) then
	echo "TEST-E-USAGE ERROR, test_chset.csh requires two arguments"
	echo 'Usage: $gtm_tst/$tst/u_inref/test_chset.csh <$gtm_chset value to be set> <expected result>'
	exit 1
endif
$switch_chset $1
$echoline
$GTM << gtm_eof
write "setenv gtm_chset $1",!
write "ZCHSET="_\$ZCHSET,!
do ^examine("$2",\$ZCHSET)
halt
gtm_eof
#
