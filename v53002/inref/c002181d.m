ick
	s $zt="w !,""got to $zt"",! ZG "_$ZL_":base+tst^"_$T(+0)
base	I $I(tst) s $zstep="foobar"
	I $I(tst) s $zstep="w !,""got to zstep"",! do nolab"
	I $I(tst) zb lab:"zst"
lab	I $I(tst) w !,"got past error"
	q