! Test sub-ranges where starting point is identical but greater ending point (10) is lexically before smaller ending point (3)
add -name x(2:10)  -region=BREG
add -name x(2:3)   -region=CREG
exit
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region CREG -dyn=CREG -stdnullcoll
add -segment CREG -file=CREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
