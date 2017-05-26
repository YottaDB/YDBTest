#!/usr/local/bin/tcsh -f
# rfstatus.csh <message to  print>
# Prints status on source and receiver side
$pri_shell "$pri_getenv; $gtm_tst/com/srcstat.csh $1 < /dev/null"
$sec_shell "$sec_getenv; $gtm_tst/com/rcvrstat.csh $1 < /dev/null"
