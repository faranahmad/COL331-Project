#include <inc/lib.h>
#include <inc/elf.h>

#define GUEST_KERN "kernel"
#define GUEST_BOOT "boot"
#define GUEST_MEM_SZ 16 * 1024 * 1024
#define JOS_ENTRY 0x7000

static int map_guest(envid_t guest,uintptr_t guestpa, size_t memsz,int fd, size_t filesz,off_t fileoffset)
{
	int i,r=0;
	i = 0;
	while(i < memsz) 
	{
		if (i < filesz) 
		{
			// from file
			r = sys_page_alloc(0, UTEMP, PTE_P|PTE_U|PTE_W);
			if (r < 0)
			{
				return r;
			}
			r = seek(fd, fileoffset + i);
			if (r < 0)
			{
				return r;
			}
			r = readn(fd, UTEMP, MIN(PGSIZE, filesz-i));
			if (r < 0)
			{
			 	return r;
			}
			r = sys_page_map(0, UTEMP, guest, (void*) (guestpa + i), PTE_P|PTE_U|PTE_W);
			if (r < 0)
			{
				// panic("spawn: sys_page_map data: %e", r);
				panic("in vm.c in map guest");
			}
			sys_page_unmap(0, UTEMP);
		} 
		else 
		{
			// allocate a blank page
			r = sys_page_alloc(guest, (void*) (guestpa + i), PTE_P|PTE_U|PTE_W);
			if (r < 0)
			{
				return r;
			}
		}
		i += PGSIZE;
	}
	return 0;
}

static int copy_kernel(envid_t guest, char* filname)
{
	cprintf("%s\n",filname);
	char data[512];
	int fd = open(filname,O_RDONLY);
	if(fd < 0)
	{
		cprintf("here\n");
		return -E_NOT_FOUND;	
	}
	size_t t = readn(fd, data, sizeof(data));
	if (t != sizeof(data)) 
	{
		close(fd);
		return -E_NOT_FOUND;
	}
	struct Elf *elfhdr = (struct Elf*)data;
	if (elfhdr->e_magic != ELF_MAGIC) 
	{
		close(fd);
		return -E_NOT_EXEC;
	}
	struct Proghdr* ph = (struct Proghdr*) (data + elfhdr->e_phoff);
	struct Proghdr* eph = ph + elfhdr->e_phnum;
	int r = 0;
	while(ph < eph) 
	{
    	if (ph->p_type == ELF_PROG_LOAD) 
    	{
			// Call map_in_guest if needed.
			r = map_guest(guest, ph->p_pa, ph->p_memsz, fd, ph->p_filesz, ph->p_offset);
			if (r < 0) {
				close(fd);
				return -2;
			}
		}
		ph++;
	}
	close(fd);
	return r;
}

void umain(int argc, char** argv)
{
	int ret;
	envid_t guest;
	ret = sys_env_mkguest(GUEST_MEM_SZ,JOS_ENTRY);
	if(ret <0)
	{
		cprintf("Error creating a guest OS env in vm.c umain: %e\n", ret );
		exit();
	}
	guest = ret;
	int i=0;
	while(i < 1024)
	{
		sys_page_alloc(guest,(void*) (i*4096),PTE_P|PTE_U|PTE_W);
		i++;
	}
	ret = copy_kernel(guest,GUEST_KERN);
	if(ret < 0)
	{
		cprintf("Error copying page into the guest in vm.c umain - %d\n.", ret);
		exit();
	}

	int fd;
	fd = open(GUEST_BOOT, O_RDONLY);
	if (fd < 0) 
	{
		cprintf("open %s for read: %e\n in vm.c umain", GUEST_BOOT, fd );
		exit();
	}
	int d; 
	d = 512;
	ret = map_guest(guest, JOS_ENTRY, d, fd, d, 0);
	if (ret < 0) 
	{
		cprintf("Error mapping bootloader into the guest in vm.c main - %d\n.", ret);
		exit();
	}
	printf("Done loading lab1\n");
	sys_env_set_status(guest,ENV_RUNNABLE);
	wait(guest);
}