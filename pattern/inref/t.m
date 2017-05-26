t ;
 s f="edmpattable"
 v "PATLOAD":f
 w !,"loaded file"
 v "PATCODE":"EDM"
 w !,"activated table"
 ;
m ;
 ; NOTE: the following line can always be compiled
 s h1=$h
 w !,"abc"?1v2k
 s h2=$h
 s dif=$$^difftime(h2,h1)
 w !,"TIME: (t.m) ",dif,!
 ;w !,"Now trying Y and Z:"
 ; NOTE: the following line can ONLY be compiled if the current
 ;       pattern table contains entries for ZvowelZ and YconsonY
 ; w !,"abc"?1ZvowelZ1YconsonY1k
 q
