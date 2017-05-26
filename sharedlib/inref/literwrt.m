literwrt    ; test if we write to literal table        
       k
       s x="sOcKeT"
       S portno=$ztrnlnm("portno")
       open "test"_$j:(connect="localhost:"_portno_":TCP":attach="client"):2:x
       if x="SOCKET" w "Wrote to literal table, bad GT.M",!
       e  w "Did not write to literal table, good GT.M",!
       close "test"_$j
       q
