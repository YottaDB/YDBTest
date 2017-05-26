#!/usr/local/bin/tcsh

set repl_file = ""
if (-e mumps.repl) set repl_file = "mumps.repl"
$gtm_exe/ftok *.dat *.gld $repl_file > ftok.out
$tst_awk '{if ("" != $5) print $5}' ftok.out > ftok.list
$gtm_tst/com/ipcs -a | grep $USER > ipcs.list
$grep -f ftok.list ipcs.list 
exit (0 == $status)
