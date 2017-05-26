! Test miscellaneous scenarios
add -name X(1)    -region=AREG
add -name X(1,2:) -region=BREG
add -name X(1:)   -region=BREG
add -name X*      -region=AREG
add -name Y(2)    -region=BREG
add -name Y(2,3:) -region=DEFAULT
add -name Y(2:)   -region=DEFAULT
add -name Y*      -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
