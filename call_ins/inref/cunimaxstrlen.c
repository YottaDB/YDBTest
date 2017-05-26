#include "gtm_string.h"
#include "gtm_stdio.h"
#include <sys/types.h>
#include "gtmxc_types.h"

int main()
{
	gtm_status_t	status;
	char		err[500];
	gtm_char_t	*astr, *aptr, *substr;
	int 		i, substrlen;

	status = gtm_init();
	if (status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
	aptr = astr = (gtm_char_t*)gtm_malloc((1024 * 1024) + 1024);	/* Max strlen plus some padding to play with */

	substr = "β";
	substrlen = strlen(substr);
	for (i = 16383; 0 < i; i--)
	{
		memcpy(aptr, substr, substrlen);
		aptr += substrlen;
	}
	*aptr = 0;
	status = gtm_ci("unimaxstr", astr, substr);
	if (status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}

	aptr = astr;
	substr = "私";
	substrlen = strlen(substr);
        for (i = 21845; 0 < i; i--)
        {
                memcpy(aptr, substr, substrlen);
                aptr += substrlen;
        }
        *aptr = 0;
        status = gtm_ci("unimaxstr", astr, substr);
	if (status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}

	aptr = astr;
	substr = "𠞉𠞉𠞉𠞉𠞉𠞉𠞉𠞉";
	substrlen = strlen(substr);
        for (i = 32768; 0 < i; i--)
        {
                memcpy(aptr, substr, substrlen);
                aptr += substrlen;
        }
        *aptr = 0;
	status = gtm_ci("unimaxstr", astr, "𠞉");
	if (status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}

	/* Note appending to previously built string */
	substr = "𠞉𠞉𠞉";
	/* aptr still set from before pointing at string ending null (note we copy null) */
	memcpy(aptr, substr, strlen(substr) + 1);
	PRINTF("The following call will give max_strlen error\n");
	status = gtm_ci("unimaxstr", astr, "β");
	if (status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
	gtm_free(astr);

	status = gtm_exit();
	if (status)
	{
		gtm_zstatus(&err[0], 500);
		PRINTF(" %s\n", err);
	}
}
