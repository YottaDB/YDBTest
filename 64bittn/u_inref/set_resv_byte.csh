#! /usr/local/bin/tcsh -f
$gtm_tst/com/create_reg_list.csh
set reg_list = `cat reg_list.txt | $tst_awk '{print $0}'`
foreach reg ($reg_list)
	$DSE << DSE_EOF
	find -reg=$reg
	change -file -reserve=8
DSE_EOF
end

