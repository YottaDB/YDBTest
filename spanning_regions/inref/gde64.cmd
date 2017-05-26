! Test case from Kishore : GDE SHOW -NAME should output subscripts in collation order (not lexical order)
add -name a(1:10)    -region=a1
add -name a(120:300) -region=a2
add -name a(60:75)   -region=a3
exit
add -region A1 -dyn=A1 -stdnullcoll
add -segment A1 -file=A1.dat
add -region A2 -dyn=A2 -stdnullcoll
add -segment A2 -file=A2.dat
add -region A3 -dyn=A3 -stdnullcoll
add -segment A3 -file=A3.dat
change -region DEFAULT -stdnullcoll
show -name
show -map
