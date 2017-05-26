gtmchk	;
	; D9D12-002404 - %GTM-F-GTMCHECK, Internal GT.M error
	; To verify that GT.M reports an LABELUNKNOWN at gtmchk+5^gtmchk
	;
	d labdef^d002404	; the label exists, d002404 is linked successfully
	d labundef^d002404(10)	; label doesn't exist. Should report LABELUNKNOWN.
	q
