! Test range specification subtlety
add -name X(:)   -region=AREG
add -name X(2,:) -region=BREG
add -name Y(:)   -region=AREG
add -name Y(2)   -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
