! Enhanced version of gde50.cmd
add -name X(1:10)  -region=AREG
add -name X(20:30) -region=AREG
add -name X(40:50) -region=AREG
add -name X(60:70) -region=AREG
add -name X(10:65) -region=AREG
add -name X(5:25)  -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
