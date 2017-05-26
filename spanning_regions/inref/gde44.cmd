! Check sub-ranges that map to different regions than super-range; Subtle variation of gde43.cmd
add -name b(1) -reg=AREG
add -name b(1,1:9) -reg=BREG
add -name b(1,2:8) -reg=CREG
add -name b(1,3:7) -reg=BREG
add -name b(1,4:6) -reg=BREG
add -name b(1,5:5) -reg=BREG
add -name b(1,4,100:"z") -reg=CREG
add -name b(1,4,2:88) -reg=BREG
add -name b(1,4,1) -reg=AREG
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
