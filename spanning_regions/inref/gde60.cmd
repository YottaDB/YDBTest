! Check sub-ranges are allowed
add -name a(10:) -region=a1
add -name a(40:) -region=a4
exit
add -region A4 -dyn=A4 -stdnullcoll
add -segment A4 -file=A4.dat
add -region A1 -dyn=A1 -stdnullcoll
add -segment A1 -file=A1.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
