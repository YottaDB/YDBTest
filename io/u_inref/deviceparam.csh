# To avoid HP-UX issue with Direct mode output (+1^GTM$DMOD    (Direct mode) ), filter it
$gtm_tst/$tst/u_inref/deviceparam_base.csh >&! deviceparam_base_out.txt
sed 's/.*GTM$DMOD[ 	]*(Direct mode)/##Direct mode##/g' deviceparam_base_out.txt
