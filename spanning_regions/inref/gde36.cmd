! Similar to gde35.cmd but slightly different
add -name a* -reg=AREG
add -name ab* -reg=BREG
add -name aba(1) -reg=CREG
add -name aba(2) -reg=AREG
add -name aba(3) -reg=BREG
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
