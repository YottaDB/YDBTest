#! /usr/local/bin/tcsh -f
echo "inside sec_upg_or_dwg.csh"
set pri_ver = $1
set sec_ver = $2
set tst_ver = $3
echo "pri_ver: $pri_ver : v4ver: $v4ver : tst_ver: $tst_ver, sec_ver = $sec_ver"
if ($pri_ver == $sec_ver) then
	exit # No update or downgrade is needed 
endif
if ( $pri_ver == $v4ver && $sec_ver == $tst_ver) then # primary V4 and secondary V5
	echo "upgrading backed up db (from primary side) in secondary side to V5"
	source $gtm_tst/com/switch_gtm_version.csh $pri_ver $pri_tst_image
	$MUPIP set -replication=OFF -journal=disable -region "*"
	ls *.dat
	ls *.gld
$GTM << aa
w \$zv
aa
	$DBCERTIFY scan -outfile=dbcertify_scanreport.txt DEFAULT
	if ($status) then
        	echo "TEST-E-ERROR. scan phase failed for $v4ver database"
        	exit 1
	endif
	$DBCERTIFY certify dbcertify_scanreport.txt < $gtm_tst/$tst/inref/yes.txt
	if ($status) then
        	echo "TEST-E-ERROR. certify phase failed for $v4ver database"
        	exit 1
	endif
	source $gtm_tst/com/switch_gtm_version.csh $sec_ver $sec_tst_image
$GTM << aa
w \$zv
aa
	echo "Upgrading global directory"
	$GDE exit
	$MUPIP upgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
	$MUPIP reorg -upgrade -reg DEFAULT
	$MUPIP set -replication=ON -region "*"
	echo "upgrade completed"
else if ( $pri_ver == $tst_ver && $sec_ver == $v4ver ) then # primary runs V5 and secondary runs V4
	echo "downgrading backed up db (from primary side) in secondary side to V4"
	#switch version here to V5 in order to use V5 executables
        source $gtm_tst/com/switch_gtm_version.csh $pri_ver $pri_tst_image
$GTM << aa
w \$zv
aa
	$MUPIP set -replication=OFF -journal=disable -region "*"
	$MUPIP reorg -downgrade -reg DEFAULT
	$MUPIP downgrade mumps.dat < $gtm_tst/$tst/inref/yes.txt
	#switch back to original secondary version
	echo "switch back to v4 gld"
	mv mumpsold.gld mumps.gld
	source $gtm_tst/com/switch_gtm_version.csh $sec_ver $sec_tst_image
$GTM << aa
w \$zv
aa
	$MUPIP set -replication=ON -region "*"
endif
echo "End of secondary upgrade or downgrade"
