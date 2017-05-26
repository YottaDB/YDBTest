#!/usr/local/bin/tcsh -f

#
# A $ZInterrupt executing a ZWRITE or MERGE that got an error did not
# recover gracefully. Assert fails or error loops depending on build type.
#
setenv TERM xterm
expect -f $gtm_tst/$tst/u_inref/GTM6940.exp $gtm_dist > GTM6940_expect.log
