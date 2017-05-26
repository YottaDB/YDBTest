#include <stdio.h>
#include "mdef.h"
#include "cli.h"

GBLDEF	CLI_ENTRY	*cmd_ary = NULL; /* This test does not have any command tables so initialize command array to NULL */

int main()
{
	int pi = 255; 			/* test positive integer */
	int ni = -255; 			/* test negative integer */
	char schar = 'A';		/* test char */
	INTPTR_T sptr = (INTPTR_T)-1;	/* test negative values of size = platform pointer size */
	gtm_uint64_t vlong = 0x0000AABBCCDDEEFF;	/* test 64 bit values */
	gtm_uint64_t *vlongptr=&vlong;	/* used to test dereferencing '@' */

	gtm_threadgbl_init();
	/* 
	 * Note: The output of printf is 'grep'ed by test_fao.csh and used as reference to compare with the output
	 * of util_out_print. If the printf statment is changed please make the corresponding changes into test_fao.csh
	 */
	printf(" Memory address used %lX %lu %ld\n", &pi, &pi, &pi);
	util_out_print(" XB !XB SB !SB UB !UB ZB !ZB", TRUE, schar, schar, schar, schar);
	util_out_print(" XW !XW SW !SW UW !UW ZW !ZW", TRUE, pi, pi, pi, pi);
	util_out_print(" XL !XL SL !SL UL !UL ZL !ZL", TRUE, pi, pi, pi, pi);
	util_out_print(" XL !XL SL !SL UL !UL ZL !ZL", TRUE, ni, ni, ni, ni);
	util_out_print(" XJ !XJ SJ !SJ UJ !UJ ZJ !ZJ", TRUE, &pi, &pi, &pi, &pi);
	util_out_print(" XJ !XJ SJ !SJ UJ !UJ ZJ !ZJ", TRUE, sptr, sptr, sptr, sptr);

	util_out_print(" @XQ !@XQ @UQ !@UQ @ZQ !@ZQ", TRUE, vlongptr, vlongptr, vlongptr, vlongptr);
	util_out_print(" @XJ !@XJ @UJ !@UJ @ZJ !@ZJ", TRUE, vlongptr, vlongptr, vlongptr, vlongptr);
	
	util_out_print(" 16@XQ !16@XQ 16@UQ !16@UQ 16@ZQ !16@ZQ", TRUE, vlongptr, vlongptr, vlongptr);
	util_out_print(" 16@XJ !16@XJ 16@UJ !16@UJ 16@ZJ !16@ZJ", TRUE, vlongptr, vlongptr, vlongptr);

	return 0;
}
