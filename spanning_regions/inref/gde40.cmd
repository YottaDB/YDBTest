! Check sub-ranges that map to different regions than super-range
add -name b(1) -reg=AREG
add -name b(1,"a":"z") -reg=BREG
add -name b(1,"b":"e") -reg=CREG
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
