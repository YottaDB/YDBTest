#!/usr/local/bin/tcsh -f
rm -f gde.out
rm -f reg_list.txt
$GDE << GDE_EOF >&! gde.out
show -reg
quit
GDE_EOF
$tst_awk '{if ((NF==7) &&($1!="Region")) print $1}' gde.out > reg_list.txt
