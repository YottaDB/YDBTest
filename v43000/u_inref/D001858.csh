echo "D9B05-001858 Certain patterns can trigger a memory access segmentation violation."
$GTM << FIN
s RES="string"
w (RES?.E1N1N.N.N1"-"1N.N.N.N.N.N.N.P.P.P.P.E)
w (RES?.E1N.N1"-"1N.E),!
w (RES?.E1N1N.N1"-"1N.N.N.N.E),!
w (RES?.E1N1N.N1"-"1N.N.N.P.E),!
w (RES?.E1N1N.N.N1"-"1N.N.N.N.N.N.N.P.P.P.P.E),!
w (RES?.E1N1N.N.N1"-"1N.E1A.L.N.P.E),!
w (RES?.E1N.E1N.E.P.E3.E1"-"1"-"1"-"1"-".N.E.N.E.E.E.E),!
w (RES?.E.P.E.P1E.E.E.P3.E1"-".N.E.N.A.C.L.E),!
w (RES?.E1N1N.N1"-"1A.L.N.P.E),!
w (RES?.E1N.N1"-"1N.N3N4A7L.N.E.E1N1E1A3N),!
w (RES?.E1N.N1N.N.E1.A3.P),!
w (RES?.E1N.N1"-"1N.N.E),!

h
FIN
$gtm_exe/mumps -run D001858
