# Test call in table parsing errors
# gtm_errors.csh
# 
echo "--------------------------------------------------------------------------------"
echo "TEST: Referenced label not specified in call-in table: "
source $gtm_tst/$tst/u_inref/cinoentry.csh
ccnoent 
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Invalid direction for passed parameters: "
source $gtm_tst/$tst/u_inref/cidirctv.csh
dirctv
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Missing/Invalid C identifier in call-in table: "
source $gtm_tst/$tst/u_inref/circalname.csh
cclerr
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Wrong type specification for O/IO, pointer type expected: "
source $gtm_tst/$tst/u_inref/cipartyp.csh
cpartyp
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Syntax errors in parameter specifications in call-in table: "
source $gtm_tst/$tst/u_inref/ciparnam.csh
cparnam
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Unknown parameter type specifcation:  "
source $gtm_tst/$tst/u_inref/ciuntype.csh
cuntype
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Invalid return type specifcation:  "
source $gtm_tst/$tst/u_inref/cirtntyp.csh
crtntyp
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Environment variable for call table:"
source $gtm_tst/$tst/u_inref/citabenv.csh
ctabenv
#unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Unable to open call table:"
source $gtm_tst/$tst/u_inref/citabopn.csh
ctabopn
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
echo "TEST: Multiple caret:"
source $gtm_tst/$tst/u_inref/cimulcar.csh
cmulcar
unsetenv GTMCI
echo "--------------------------------------------------------------------------------"
