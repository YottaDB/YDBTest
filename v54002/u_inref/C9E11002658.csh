#!/usr/local/bin/tcsh -f
#
# C9E11-002658 [Roger] GDE should not lose maximum length names
#

cp $gtm_tst/$tst/inref/C9E11002658.gde ./
$GDE @C9E11002658.gde
diff C9E11002658_create.log C9E11002658_reload.log 
