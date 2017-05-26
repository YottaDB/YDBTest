# Sanitize the output of Online Rollback for a clean reference file
/RLBKJNSEQ/ {
	if (resyncseqnolist >= rollseqno && jnlseqno >= rollseqno) {
		if ($(NF-1)>rollseqno) {
			print "TEST-E-FAIL : RESYNC Seqno does not match RLBKJNSEQNO"
		}
	} else {
		if ("" != debug) {print "TEST-I-INFO : RESYNC Seqno is less than rollseqno"}
	}
}
/(GTM-E-|JNLSUCCESS|ORLBKCMPLT)/{
	print $0
}
