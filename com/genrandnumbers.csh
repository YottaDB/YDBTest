#!/usr/local/bin/tcsh -f

# This tool generates 'count' random numbers between 'lower' and 'upper' limit (both inclusive)

# Usage:
# $gtm_tst/com/genrandnumbers.csh <count> <lower-limit> <upper-limit>
# Note:
# If no parameters are passed, the defaults are count = 1 , lower = 0 , upper = 1

set count = "$1"
set lower = "$2"
set upper = "$3"

if ("" == "$count") set count = 1
if ("" == "$lower") set lower = 0
if ("" == "$upper") set upper = 1

echo | $tst_awk -f $gtm_tst/com/genrandnumbers.awk -v count=$count -v lower=$lower -v upper=$upper
