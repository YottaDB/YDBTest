! Check sub-ranges are allowed : Variation of gde60.cmd in terms of the order of the ADD -NAME commands. Expect same output
add -name a(40:) -region=a4
add -name a(10:) -region=a1
exit
add -region A4 -dyn=A4 -stdnullcoll
add -segment A4 -file=A4.dat
add -region A1 -dyn=A1 -stdnullcoll
add -segment A1 -file=A1.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
