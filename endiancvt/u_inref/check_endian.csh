#!/usr/local/bin/tcsh -f

## This tool checks if the endian format of the given regions is as expected (using dse dump info)
## USAGE: check_endian.csh <endian> <region list>
## eg: check_endian.csh LITTLE AREG BREG DEFAULT
##     check_endian.csh BIG CREG

set endian_exp = $1
shift;

foreach region ($*)
	$DSE << EOF >&! dump_$region.out
	find -region=$region
	dump -fileheader
EOF
	set endian = `$grep "Endian Format" dump_$region.out | $tst_awk '{print $3}'`
	if($endian == $endian_exp) then
		echo "region $region has the expected endian format"
		\rm dump_$region.out
	else
		echo "TEST-E-ENDIAN $region has unexpected endian format. Check dump_$region.outx"
		mv dump_$region.out dump_$region.outx
	endif
end

