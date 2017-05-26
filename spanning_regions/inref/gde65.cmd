! Test that OBJDUP error with a NAME that contains binary characters prints it in zwr format (using $c() notation)
add -name MODELNUM($char(0):) -region=STRING
show -name
show -map
add -name MODELNUM($char(0):) -region=STRING
exit
add -region STRING -dyn=STRING -stdnullcoll
add -segment STRING -file=STRING.dat
change -region DEFAULT -stdnullcoll

