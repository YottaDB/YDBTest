add -name X(2:50)  -reg=AREG
add -name X(10:20) -reg=BREG
add -name X(3:40)  -reg=AREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
