! Test range coalesce happens as part of ADD -NAME itself (does not need to wait until SHOW -NAME)
add -name X(1:10)  -region=AREG
add -name X(20:30) -region=AREG
add -name X(10:20) -region=AREG
add -name X(5:25)  -region=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
