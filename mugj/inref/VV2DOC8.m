VV2DOC8	;VV2DOC V.7.1 -8-;TS,VV2DOC,VALIDATION VERSION 7.1;31-AUG-1987;
	;COPYRIGHT MUMPS SYSTEM LABORATORY 1987
	I IO="PRINTER" W #,!!!!!!
	W !
	F I=1:1 S A=$T(TEX+I) Q:A=""  W !,$P(A," ;",2,99)
	Q
TEX	;
	;                            Validation Content Part-II
	;
	;     II-140. Terminated by readcount characters
	;     II-141. Terminated by <CR>
	;     II-142. Indirection argument
	;
	;     READ lvn readcount timeout
	;
	;     II-143. Terminated by readcount characters
	;     II-144. Terminated by <CR>
	;     II-145. Terminated by timeout
	;     II-146. Test of $TEST  when timeout time is 0
	;     II-147. Indirection argument
	;
	;
	;Pattern match -1-
	;     (VV2PAT1)
	;
	;     II-148. expr ? . intlit2 patcode
	;     II-149. expr ? intlit1 . patcode
	;     II-150. expr ? intlit1 . intlit2 patcode
	;     II-151. '?
	;     II-152. Multi patatom
	;     II-153. expr ? repcount patcode  when expr is empty string
	;     II-154. expr contains control characters
	;
	;
	;Pattern match -2-
	;     (VV2PAT2)
	;
	;     II-155. Indirection pattern
	;     II-156. Nesting of pattern
	;     II-157. expr is 255 characters
	;     II-158. expr ? repcount strlit when strlit is empty string
	;     II-159. expr ? repcount strlit when expr is empty string
	;     II-160. Lower case letter pattern code "c"
	;        II-160.1  repcount
	;        II-160.2  its mapping
	;        II-160.3  lvn?5c
	;     II-161. Lower case letter pattern code "p"
	;        II-161.1  repcount
	;        II-161.2  its mapping
	;        II-161.3  lvn?5c
	;
	;
	;Pattern match -3-
	;     (VV2PAT3)
