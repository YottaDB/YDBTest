#! /usr/local/bin/tcsh -f
if ($1 == "rwrw") then
echo "**** R/W b.dat R/W b.mjl ****"
chmod 666 b.dat
chmod 666 b.mjl
endif
if ($1 == "rwro") then
echo "**** R/W b.dat R/O b.mjl ****"
chmod 666 b.dat
chmod 444 b.mjl
endif
if ($1 == "rorw") then
echo "**** R/O b.dat R/W b.mjl ****"
chmod 444 b.dat
chmod 666 b.mjl
endif
if ($1 == "roro") then
echo "**** R/O b.dat R/O b.mjl ****"
chmod 444 b.dat
chmod 444 b.mjl
endif
