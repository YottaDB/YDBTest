#!/usr/local/bin/tcsh
# This test has BADCHAR writes as labels in routine which will trigger GTM-E-BADCHAR so avoid that
# our intention is to test only badlabels and not bad characters here. So switch to M mode.
$switch_chset "M" >&! switch_chset.log
$GTM << aaa
d ^mbadlabels
h
aaa
