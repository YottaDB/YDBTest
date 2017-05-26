setenv dbname mumps
/bin/rm -f mumps.dat reg1.dat reg2.dat mumps.gld tmp.com
$GDE <<CREATE_REG >>&! dbcreate.dmp
A -N A1 -R=REG1
A -N B1 -R=REG1
A -N A2 -R=REG2
A -N B2 -R=REG2
A -R REG1 -D=SEG1
A -R REG2 -D=SEG2
A -S SEG1 -F=reg1.dat
A -S SEG2 -F=reg2.dat
EXIT
CREATE_REG
