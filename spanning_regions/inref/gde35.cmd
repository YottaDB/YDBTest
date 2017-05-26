! Test that aa(2) gets optimized out
add -name a* -reg=AREG
add -name aa(1) -reg=CREG
add -name aa(2) -reg=AREG
add -name aa(3) -reg=BREG
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
