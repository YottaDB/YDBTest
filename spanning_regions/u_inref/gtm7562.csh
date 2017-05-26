#!/usr/local/bin/tcsh -f
#################################################################
#								#
#	Copyright 2013, 2014 Fidelity Information Services, Inc	#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# GTM-7562 : DSE silently switches to the wrong region if same global exists in multiple .dat files

if !($?gtm_test_replay) then
	set gtm7562_gde_dse = `$gtm_exe/mumps -run rand 2`
	echo "setenv gtm7562_gde_dse $gtm7562_gde_dse	# set by gtm7562.csh"	>>&! settings.csh
endif
setenv gtm_dirtree_collhdr_always 1
source $gtm_tst/com/cre_coll_sl_reverse.csh 1
setenv gtmgbldir mumps1.gld
$GDE << GDE_EOF >&! gde_mumps1.out
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=mumps
change -segment DEFAULT -file=a
GDE_EOF

setenv gtmgbldir mumps2.gld
$GDE << GDE_EOF >&! gde_mumps2.out
add -name a -region=areg
add -region areg -dyn=aseg
add -segment aseg -file=a
change -segment DEFAULT -file=mumps.dat
GDE_EOF

if (0 == $gtm7562_gde_dse) then
	$GDE << GDE_EOF >&! gde_gblname_x.out
	add -gblname x -coll=1
GDE_EOF

endif

$MUPIP create

if (1 == $gtm7562_gde_dse) then
	$DSE << DSE_EOF >&! dse_col_change.out
	find -region=DEFAULT
	change -file -def=1
DSE_EOF

endif

$GTM << GTM_EOF
for i=65:1:75 set ^a(\$char(i))=\$j(i,20)
for i=65:1:105 set ^x(\$char(i))=\$j(i,20)
GTM_EOF

setenv gtmgbldir mumps1.gld
$GTM << GTM_EOF
for i=65:1:105 set ^a(\$char(i))=\$j(i,20)
for i=65:1:75 set ^x(\$char(i))=\$j(i,20)
GTM_EOF

setenv gtmgbldir mumps2.gld

$DSE << DSE_EOF >&! dse_dumps.out
        find -region=AREG
        dump -block=3
        find -region=DEFAULT
        dump -block=2
        dump -block=5
        dump -fileheader
DSE_EOF

# The actual dump is endian specific, the 4th byte is not initialized etc. We are interested only in the headers
# and the name of the region, so filter out the other details
$tst_awk '{if ($_ !~ /^ /) { print}}' dse_dumps.out

# Use this setup to also test the below (unrelated test case) from the test plan :
# DSE commands where a key is specified need to be tested for cases where the .gld specifies a non-zero collation for
# the global name. For example DSE FIND -KEY, DSE ADD -REC etc. all specify keys. If the global name corresponding
# to the key has a non-zero collation in the .gld file, we need to make sure the user-specified string subscript
# is transformed using the collation xform functions before storing in the subscript representation in the database
setenv gtmgbldir mumps2.gld
$DSE << DSE_EOF
	find -region=DEFAULT
	add -block=5 -rec=5 -key="^x(""ff"")" -data="999"
DSE_EOF

$DSE << DSE_EOF >&! dse_collation_xform.out
	find -region=DEFAULT
	dump -block=5 -rec=5
	find -key="^x(""ff"")"
DSE_EOF

# The last DSE> prompt will not have newline character
# when the file is passed to sed, on hp-ux ia64 the line isn't printed in the output. So add a dummy newline
echo "" >> dse_collation_xform.out
sed 's/: |\(.*\)\(99.*\)/: |##FILTERED## \2/;s/|\(.*\)9  9  9/|##FILTERED##           9  9  9/' dse_collation_xform.out
