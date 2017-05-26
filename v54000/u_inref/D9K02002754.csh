#!/usr/local/bin/tcsh -f
#
# D9K02-002754 [Roger] GDE should not lose ranges constructed of maximum length names
#

cp $gtm_tst/$tst/u_inref/D9K02002754.gde .

$GDE << GDE_EOF >& gde1.out
@D9K02002754.gde
GDE_EOF

$GDE << GDE_EOF >& gde2.out
Show -Map
GDE_EOF

# Previously, gde1.out AND a "diff" of gde1.out and gde2.out was kept as part of the reference file to minimize
# its size. But various Unix platforms have varying diff outputs for the same content so having a common reference
# file is difficult. Hence including the contents of both gde1.out and gde2.out as part of the reference file.
cat gde1.out	# keep map output as part of reference file
cat gde2.out	# Check that map is still intact
