setenv	GTMXC	gtmxc_shlib.tab
echo "`pwd`/libshlib${gt_ld_shl_suffix}" > $GTMXC
cat >> $GTMXC << xx
hello:		void	hello()
	GMSHLIBEXT = 
xx
