#!/usr/local/bin/tcsh
#
# D9H02-002642 PROFILE screen function keys do not work with GT.M V5.2 on AIX/Solaris/HPUX
#

setenv TERM xterm
cat $gtm_tst/$tst/u_inref/D9H02002642.exp | sed 's,$gtm_dist,'$gtm_dist',g' > D9H02002642.exp
expect -f D9H02002642.exp
