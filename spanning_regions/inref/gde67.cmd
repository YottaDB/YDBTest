! Test OBJNOTFND error from DELETE with a NAME that contains binary characters prints it in zwr format (using $c() notation)
delete -name MODELNUM($char(0):)
exit

