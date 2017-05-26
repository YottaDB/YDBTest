! Test OBJNOTFND error from CHANGE with a NAME that contains binary characters prints it in zwr format (using $c() notation)
change -name MODELNUM($char(0):) -region=STRING
exit

