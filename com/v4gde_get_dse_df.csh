#!/usr/local/bin/tcsh -f
#
setenv msg ""
if ($1 != "") setenv msg $1

echo "Current Time:`date +%H:%M:%S`" >>&! dse_df.log
echo $msg >>&  dse_df.log
$GDE << GDE_EOF >&! gde_reg.log
show -reg
GDE_EOF

if ($status) cat gde_reg.log

echo "Regions found:" >>&! dse_df.log
awk '{if ((NF==7) &&($1!="Region")) print $1}' gde_reg.log >>&! dse_df.log
foreach region (`awk '{if ((NF==7) &&($1!="Region")) print $1}' gde_reg.log`)
$DSE << DSE_EOF >>&! dse_df.log
find -REG=$region
d -f 
DSE_EOF
end
