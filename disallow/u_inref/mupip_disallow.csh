#!/usr/local/bin/tcsh -f
#
# D9D09002364 [Narayanan] 
#
cp $gtm_tst/$tst/inref/mupip_cmd_disallow.txt .	# copy the mupip_disallow.txt file from inref
#
$GTM <<EOF
	do ^d002364("mupip_cmd_disallow.txt","$MUPIP")
EOF
