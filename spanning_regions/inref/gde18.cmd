! Test of lots of subscripted names with ranges that reduce to few maps 
add -name X(2,3:4)    -region=DREG
add -name X(2,4)      -region=DREG
add -name X(2,4,:1)   -region=DREG
add -name X(2,4,1)    -region=DREG
add -name X(2,4,1,5:) -region=CREG
add -name X(2,4,1:2)  -region=CREG
add -name X(2,4,2:5)  -region=AREG
add -name X(2,4,5:)   -region=BREG
add -name X(2,4:5)    -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region CREG -dyn=CREG -stdnullcoll
add -segment CREG -file=CREG.dat
add -region DREG -dyn=DREG -stdnullcoll
add -segment DREG -file=DREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map

