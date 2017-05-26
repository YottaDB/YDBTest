! Test case that Kishore came up with which exposed a bad assert
add -name PRODAGE("10":"20") -region=DECADE1
add -name PRODAGE("20":) -region=DECADE2
add -name PRODAGE(20:) -r=D2
delete -name PRODAGE("10":"20")
add -name PRODAGE(20:) -r=D2
exit
add -region D2 -dyn=D2 -stdnullcoll
add -segment D2 -file=D2.dat
add -region DECADE2 -dyn=DECADE2 -stdnullcoll
add -segment DECADE2 -file=DECADE2.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
