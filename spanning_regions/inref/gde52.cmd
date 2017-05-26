! Test range coalesce happens as part of ADD -NAME itself : Enhanced version of gde51.cmd
add -name x(1:5)   -region=AREG
add -name x(7:10)  -region=BREG
add -name x(13:16) -region=AREG
add -name x(4:14)  -region=AREG
show -name
show -map
add -name x(2:15)  -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll

