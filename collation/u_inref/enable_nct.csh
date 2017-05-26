#!/usr/local/bin/tcsh -f
# The caller (col_nct.csh) invokes the script (both in the primary and the secondary) at a point where the mumps.repl
# is not yet created. Furthermore, if $gtm_custom_errors is set, then the below global references tries to initialize journal pool
# at which point it encounters FTOKERR/ENO2 errors due to non-existent mumps.repl file. So, unset gtm_custom_errors. No need to
# restore the value since the parent script "executes" this script and so the environment mods are not reflected back.
unsetenv gtm_custom_errors
$GTM << \aaa
set enabled=$$set^%GBLDEF("^AGLOBALVAR1",1,0) do ^examine(enabled,1,"GBLDEF for ^AGLOBALVAR1 ")
set enabled=$$set^%GBLDEF("^BGLOBALVAR1",1,0) do ^examine(enabled,1,"GBLDEF for ^BGLOBALVAR1 ")
set enabled=$$set^%GBLDEF("^morefill",1,0) do ^examine(enabled,1,"GBLDEF for ^morefill ")
set enabled=$$set^%GBLDEF("^TESTINGLONGGLOBALNAME2345678901",1,0) do ^examine(enabled,1,"GBLDEF for ^TESTINGLONGGLOBALNAME2345678901")
write "NCT Enabled",!
halt
\aaa
