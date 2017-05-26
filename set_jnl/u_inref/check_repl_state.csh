#!/usr/local/bin/tcsh -f
$GDE << GDE_EOF >&! gde_reg.log
show -reg
quit
GDE_EOF
\rm -f check_repl_state.out
set region_list=`$tst_awk 'BEGIN{header_skip = 0}{if ((header_skip == 1) && (NF>=8)) {print $1} else if($0 ~ "------") {header_skip = 1}}' gde_reg.log`
foreach region ($region_list)
$DSE << DSE_EOF >>& check_repl_state.out
find -REG=$region
dump -fileheader
q
DSE_EOF
end
$tst_awk '/Replication State/ {print $3}' < check_repl_state.out
