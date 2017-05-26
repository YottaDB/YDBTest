! Test of more subscripted namespaces (similar to gde9.cmd and gde10.cmd but subtle difference)
add -name X(1)     -region=CREG
add -name X(1,1:2) -region=AREG
add -name X(1,2:3) -region=BREG
add -name X(1,3:)  -region=AREG
add -name X(1:2)   -region=AREG
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
