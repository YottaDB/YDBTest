c003344	;
	; A simple TP transaction with 100 sets. However, the tcommit will happen ONLY on the final retry. This is so that we do the
	; dsk_read in the final retry and expect it to work correctly. In GT.M versions < V5.4-003, RECOVER could leave the database
	; with REUSABLE V4 blocks but cs_data->fully_upgraded being set to TRUE. In such a case, if a dsk_read is done while holding
	; crit, we will end up reading a V4 block and assume it is a V5 block (since cs_data->fully_upgraded is TRUE). This is an
	; out-of-design situation
	tstart ():serial
	for i=1:1:100  set ^d(i)=$justify(i,10)
	if ($trestart<3) trestart
	tcommit
