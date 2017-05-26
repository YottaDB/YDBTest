#! /usr/local/bin/tcsh -f
set drv="ctrlc"

if ( !($?gtm_tst)) then
	setenv gtm_tst $0:h:h:h
	setenv tst $0:h:h:t
	source $gtm_tst/com/set_specific.csh
	mkdir -p /testarea1/$user/${gtm_verno}/drive_${drv}
	cd /testarea1/$user/${gtm_verno}/drive_${drv}
endif

$gtm_tst/$tst/u_inref/${drv}.csh |& tee ${drv}.outx
$grep -c "^PASS" ${drv}.outx
$grep -c "^FAIL" ${drv}.outx

exit 0
