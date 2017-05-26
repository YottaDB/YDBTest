! Test of maps with different levels of subscripts and no ++ entries
add -name X(2,3:4)   -region=CREG
add -name X(2,4)     -region=CREG
add -name X(2,4,2:5) -region=AREG
add -name X(2,4,5:)  -region=BREG
add -name X(2,4:5)   -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region CREG -dyn=CREG -stdnullcoll
add -segment CREG -file=CREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
