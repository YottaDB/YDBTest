#!/usr/local/bin/tcsh -f
#
# cre_coll_sl_all.csh
# 
# This script builds all alternative collation sequences
# needed by the test system
#
source $gtm_tst/com/cre_coll_sl.csh straight 1
source $gtm_tst/com/cre_coll_sl.csh reverse 2
source $gtm_tst/com/cre_coll_sl.csh polish 3
source $gtm_tst/com/cre_coll_sl.csh polish_rev 4
source $gtm_tst/com/cre_coll_sl.csh chinese 5
source $gtm_tst/com/cre_coll_sl.csh complex 6
