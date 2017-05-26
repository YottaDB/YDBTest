#!/usr/local/bin/tcsh -f
#
setenv msg ""
if ($1 != "") setenv msg $1

echo "==================================" >>&! dse_df.log
echo "Current Time:`date +%H:%M:%S`" >>&! dse_df.log
echo $msg >>&  dse_df.log
$DSE << DSE_EOF >>&! dse_df.log
find -REG=DEFAULT
d -f -a
find -REG=AREG
d -f -a
find -REG=BREG
d -f -a
find -REG=CREG
d -f -a
find -REG=DREG
d -f -a
find -REG=EREG
d -f -a
find -REG=FREG
d -f -a
find -REG=GREG
d -f -a
find -REG=HREG
d -f -a
quit
DSE_EOF
echo "==================================" >>&! dse_df.log
