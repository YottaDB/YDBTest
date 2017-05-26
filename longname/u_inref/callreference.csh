#!/usr/local/bin/tcsh -f
# The test checks for call-by-reference mechanism in long names
#
# "refvars" routine checks for 31char longnames & some arbitrary length of <31 char longnames
echo "refvars.m begins to check 31char longnames"
$GTM <<eof
do ^refvars
halt
eof
#
# "pcntvars" routine checks for 31char longnames & some arbitrary length of <31 char longnames beginning with %
echo "pcntvars.m begins to check 31char longnames beginning with %"
$GTM <<eof1
do ^pcntvars
halt
eof1
#
echo "xcessvar.m begins to check >31char longnames getting truncated"
# "xcessvar" routine checks for proper truncation of 31 char longnames if length exceeds 31"
$GTM <<eof2
do ^xcessvar
halt
eof2
