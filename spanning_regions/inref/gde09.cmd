! Test of more subscripted namespaces (similar to gde8.cmd but subtle difference)
add -name X(1,2:3) -region=BREG
add -name X(1:2)   -region=AREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
