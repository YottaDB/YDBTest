#! /usr/local/bin/tcsh -f
# If gtmdbglvl had been set, reset it unconditionally since otherwise we will be doing malloc storage chain 
# verification for EVERY malloc/free. This test involves a LOT of mallocs during the compiles. This would cause
# the test take excessive time and system resources to run. To avoid this situation, we turn off gtmdbglvl 
# checking for this test.
unsetenv gtmdbglvl
$gtm_tst/com/dbcreate.csh .
$GTM << \xyz
w "do ^actundef",!    do ^actundef
w "do ^donargl",!     do ^donargl
w "do ^extgot1",!     do ^extgot1
w "do ^newpara",!     do ^newpara
w "do ^qt",!          do ^qt
w "do ^undefi",!      do ^undefi
w "do ^zgonolab",!    do ^zgonolab
w "do ^zlirout",!     do ^zlirout
w "do ^zstfor1",!     do ^zstfor1
w "do ^compstress",!  do ^compstress	; Creates compstrsA/B/C
w "do ^compstrsA",!   do ^compstrsA
w "do ^compstrsB",!   do ^compstrsB
w "do ^C9L06003432",! do ^C9L06003432
h
\xyz
$gtm_tst/com/dbcheck.csh
