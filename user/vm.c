#include <inc/lib.h>
#include <inc/elf.h>
#include <inc/vminc.h>

#define EntryPt 0x7000

void umain(int argc, char** argv)
{
	int ret;
	envid_t guest;

	if ((ret = sys_env_makeguest( GUEST_MEM_SZ, EntryPt )) < 0) {
		cprintf("Error creating a guest OS env: %e\n", ret );
		exit();
	}
	guest = ret;
	// return 0;
}