#! /usr/local/bin/tcsh -f
#
#
echo ENTERING SOCKET CLIENT2
#
#
$GTM << \doclient2
d ^client2
s ^client2done=1
h
\doclient2
#
#
echo LEAVING SOCKET CLIENT2
#
#
