#!/usr/local/bin/tcsh -f
#
# cur_jnlseqno.csh [RESYNC|REGION] [number_to_subtract_in_decimal]
# If not parameter is passed, "REGION" and "0" are used
#
setenv gtm_test_parm_to_gtm $2
#
echo "Current Time:`date +%H:%M:%S`" >>&! cur_jnlseqno.out
$GDE << GDE_EOF >&! gde_reg.out
show -reg
GDE_EOF
if ($status) cat gde_reg.out
#
echo "Regions found:" >>&! cur_jnlseqno.out
#
awk '{if ((NF==7) &&($1!="Region")) print $1}' gde_reg.out >>&! cur_jnlseqno.out
#
foreach region (`awk '{if ((NF==7) &&($1!="Region")) print $1}' gde_reg.out`)
	$DSE << DSE_EOF >&! df.out
	find -REG=$region
	d -f 
DSE_EOF
	if ($1 == "RESYNC") then
		egrep "Resync Seqno"  df.out | $tst_awk '{printf("%s\n",$3);}' >>&! allseqno.out
	else
		egrep "Region Seqno"  df.out | $tst_awk '{printf("%s\n",$6);}' >>&! allseqno.out
	endif
end
#
$GTM << \GTM_EOF >>&! cur_jnlseqno.out
d ^maxrsno("allseqno.out",$ztrnlnm("gtm_test_parm_to_gtm"),"cur_jnlseqno.txt")
h
\GTM_EOF
setenv ctime `date +%H_%M_%S`
\mv allseqno.out allseqno_${ctime}.out
cat cur_jnlseqno.txt
