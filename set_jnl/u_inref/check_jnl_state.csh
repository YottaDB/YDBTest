#!/usr/local/bin/tcsh -f
#
# Before coming here we must have called create_reg_list.csh to create region list in reg_list.txt
#
\rm -f df.out
foreach region (`cat reg_list.txt`)
$DSE << DSE_EOF >>& df.out
find -REG=$region
dump -fileheader
q
DSE_EOF
end
if ("$1" != "") then
	grep "$1" df.out
else
	grep "Journal State" df.out
endif
