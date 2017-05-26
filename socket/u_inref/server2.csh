#! /usr/local/bin/tcsh -f
#
#
echo ENTERING SOCKET SERVER2
#
#
$GTM << \doserver2
d ^server2(0)
h 3
d ^server2(2)
h 3
d ^server2(4)
h
\doserver2
#
#
echo LEAVING SOCKET SERVER2
#
#
