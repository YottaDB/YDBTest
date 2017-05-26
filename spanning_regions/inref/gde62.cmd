! Slight variation of gde59.cmd
add -name PRODAGE("10":"20") -region=DECADE1
add -name PRODAGE("30":) -region=DECADE3
add -name PRODAGE(20:) -r=D2
delete -name PRODAGE("10":"20")
exit
add -region D2 -dyn=D2 -stdnullcoll
add -segment D2 -file=D2.dat
add -region DECADE3 -dyn=DECADE3 -stdnullcoll
add -segment DECADE3 -file=DECADE3.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
