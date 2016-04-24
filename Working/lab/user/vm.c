#include <inc/lib.h>
#include <inc/elf.h>

#define GUEST_KERN "kernel"
#define GUEST_BOOT "boot"
#define GUEST_MEM_SZ 16 * 1024 * 1024
#define JOS_ENTRY 0x7000

static int
map_guest(envid_t guest,uintptr_t guestpa, size_t memsz,int fd, size_t filesz,off_t fileoffset)
{
	int i,r=0;
	if ((i = PGOFF(guestpa))) {
		guestpa -= i;
		memsz += i;
		filesz += i;
		fileoffset -= i;
	}

	for (i = 0; i < memsz; i += PGSIZE) {
		if (i >= filesz) {
			// allocate a blank page
			if ((r = sys_page_alloc(guest, (void*) (guestpa + i), PTE_P|PTE_U|PTE_W)) < 0)
				return r;
		} else {
			// from file
			if ((r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W)) < 0)
				return r;
			if ((r = seek(fd, fileoffset + i)) < 0)
				return r;
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i))) < 0)
				return r;
			if ((r = sys_page_map(0, UTEMP, guest, (void*) (guestpa + i), PTE_P|PTE_U|PTE_W)) < 0)
				panic("spawn: sys_page_map data: %e", r);
			sys_page_unmap(0, UTEMP);
		}
	}
	return 0;
}

static int 
copy_kernel(envid_t guest, char* filname)
{
	cprintf("%s\n",filname);
	int fd = open(filname,O_RDONLY);
	if(fd < 0){
		cprintf("here\n");
		return -E_NOT_FOUND;	
	}
	char data[512];
	if (readn(fd, data, sizeof(data)) != sizeof(data)) {
		close(fd);
		return -E_NOT_FOUND;
	}
	struct Elf *elfhdr = (struct Elf*)data;
	if (elfhdr->e_magic != ELF_MAGIC) {
		close(fd);
		return -E_NOT_EXEC;
	}
	struct Proghdr* ph = (struct Proghdr*) (data + elfhdr->e_phoff);
	struct Proghdr* eph = ph + elfhdr->e_phnum;
	int r = 0;
	for (; ph < eph; ph++) {
    	if (ph->p_type == ELF_PROG_LOAD) {
			// Call map_in_guest if needed.
			r = map_guest(guest, ph->p_pa, ph->p_memsz, fd, ph->p_filesz, ph->p_offset);
			if (r < 0) {
				close(fd);
				return -2;
			}
		}
	}
	close(fd);
	return r;
}

void umain(int argc, char** argv)
{
	int ret;
	envid_t guest;

	if((ret = sys_env_mkguest(GUEST_MEM_SZ,JOS_ENTRY)) <0)
	{
		cprintf("Error creating a guest OS env: %e\n", ret );
		exit();
	}
	guest = ret;
	if((ret = copy_kernel(guest,GUEST_KERN)) < 0)
	{
		cprintf("Error copying page into the guest - %d\n.", ret);
		exit();
	}

	int fd;
	if ((fd = open( GUEST_BOOT, O_RDONLY)) < 0 ) {
		cprintf("open %s for read: %e\n", GUEST_BOOT, fd );
		exit();
	}

	if ((ret = map_guest(guest, JOS_ENTRY, 512, fd, 512, 0)) < 0) {
		cprintf("Error mapping bootloader into the guest - %d\n.", ret);
		exit();
	}
	printf("Done loading lab1\n");
	sys_env_set_status(guest,ENV_RUNNABLE);
	wait(guest);
}