#include <string.h>
#include "gtm_stdlib.h"
#include "gtm_stdio.h"

#include "gtmxc_types.h"
#include "shrenv.h"

/*void *GTM_MALLOC(size_t);*/
#define ENV_VAR         "GTM_CALLIN_START"

GTM64_ONLY( typedef long     (*int_fptr)();)
NON_GTM64_ONLY( typedef int     (*int_fptr)();)

int_fptr        GTM_MALLOC;
int_fptr        GTM_FREE;
void init_functable()
{

	char 	*pcAddress;
	long  	lAddress;
	void 	**functable;
	void 	(*setup_timer)  ();
	void 	(*cancel_timer) ();

	pcAddress = GETENV(ENV_VAR);
	if (pcAddress == NULL)
	{
		FPRINTF(stdout, "\nsca_AlarmSetup: Failed to get environment variable %s.\n", ENV_VAR);
	}
	lAddress = -1;
	lAddress = STRTOUL(pcAddress, NULL, 10);
	if (lAddress == -1)
	{
		FPRINTF(stdout, "\nsca_AlarmSetup: Failed to convert %s to a valid address.", pcAddress);
	}
	functable = (void *)lAddress;
	setup_timer  = (void(*)()) functable[2];
	cancel_timer = (void(*)()) functable[3];
	GTM_MALLOC = (int_fptr) functable[4];
}

static xc_string_t tmp;
int gtm_env_oops(xc_string_t *ptr1, xc_string_t *ptr2, xc_string_t *ptr_zdir, xc_string_t *ret_ptr)
{

	init_functable();
	/*tmp.address = (char *) malloc(ptr2->length);*/
	tmp.address = (char *) GTM_MALLOC(ptr2->length);
	tmp.length = ptr2->length;
	/*memcpy(tmp.address,"$tt/tmp/x.gld",tmp.length);*/
	memcpy(tmp.address,ptr2->address,tmp.length);
	tmp.length=tmp.length;
	ret_ptr->length=tmp.length;
	ret_ptr->address=tmp.address;
	/*return -1;*/
	/*tmp.length = 0;*/
	return 0;

}
