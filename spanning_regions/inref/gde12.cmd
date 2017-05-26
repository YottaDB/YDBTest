! Test of following map where X, X(1,2) and X) exists 
! To make sure namespaces added by subscripted map entry removal are not overridden by later map processing of X) and X.
add -name X       -region=AREG
add -name X(1)    -region=AREG
add -name X(1,:2) -region=AREG	! this is redundant given X(1) maps to AREG; should be optimized away in GDE SHOW -NAME
add -name X(1,2:) -region=BREG
add -name X(1:)   -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
