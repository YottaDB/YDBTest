#!/usr/local/bin/tcsh -f
#
# this script copies the already prepared V4 database to the sub-test in execution.
cp ../dbprepare/mumps.dat .
cp ../dbprepare/mumps.gld .
# If reverse collation is enabled randomly by v4dbprepare then we have to do
# the following
if (-e ../dbprepare/libreverse${gt_ld_shl_suffix}) then
	cp ../dbprepare/libreverse${gt_ld_shl_suffix} .
	setenv gtm_collate_10 "./libreverse${gt_ld_shl_suffix}"
	setenv gtm_local_collate 10
endif
if ( -e settings.csh ) then
	cat ../dbprepare/settings.csh >>! settings.csh
else
	cp ../dbprepare/settings.csh .
endif
#

# if there are any errors in the V4 DB prep, we want the subtest to squeal
cp ../dbprepare/v4dbprepare.log .
