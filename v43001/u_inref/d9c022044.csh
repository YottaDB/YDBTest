# D9C02-002044 Platform specific code compilation no longer works
echo "Entering D9C02-2044 subtest"
echo "IF <condition that evaluates to false> <bad GT.M ref>"
echo "Should complain at compile time"
echo "However the object should run without error"
\cp $gtm_tst/$tst/inref/iftest.m .
echo "zcompile iftest.m"
$GTM <<xyz
zcompile "iftest.m"
xyz
echo "now d^iftest"
$GTM <<xyz
d ^iftest
xyz
echo "Leaving D9C02-2044 subtest"
