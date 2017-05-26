! Check sub-ranges that map to different regions than super-range; Subtle variation of gde41.cmd
add -name b(1) -reg=AREG
add -name b(1,1:9) -reg=BREG
add -name b(1,2:8) -reg=CREG
add -name b(1,3:7) -reg=BREG
add -name b(1,4:6) -reg=EREG
add -name b(1,5:5) -reg=BREG
exit
add -region AREG -dyn=AREG -stdnullcoll
add -segment AREG -file=AREG.dat
add -region BREG -dyn=BREG -stdnullcoll
add -segment BREG -file=BREG.dat
add -region CREG -dyn=CREG -stdnullcoll
add -segment CREG -file=CREG.dat
add -region EREG -dyn=EREG -stdnullcoll
add -segment EREG -file=EREG.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
