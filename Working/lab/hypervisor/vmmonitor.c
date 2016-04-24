void host_init()
{
	
}


void assembly_run(struct Trapframe *tf)
{
	tf->tf_ds = curenv->env_runs;
	tf->tf_es = 0;
	asm(
            "push %%edx; push %%ebp;"
            "push %%ecx \n\t" /* placeholder for guest rcx */
            "push %%ecx \n\t"
	    /* Set the VMCS rsp to the current top of the frame. */
		/* Taken completely from linux kvm */
			//"cmp %%rsp, %c[host_rsp](%0) \n\t"
			//"je 1f \n\t"
			"mov %%esp, %c[host_esp](%0) \n\t"
		    "vmwrite %%esp, %%edx \n\t"
            /* Your code here */
            "1: \n\t"
            /* Reload cr2 if changed */
            "mov %c[cr2](%0), %%eax \n\t"
            "mov %%cr2, %%edx \n\t"
            "cmp %%eax, %%edx \n\t"
            "je 2f \n\t"
            "mov %%eax, %%cr2 \n\t"
            "2: \n\t"

            "cmpl $1, %c[launched](%0) \n\t"
            /* Load guest general purpose registers from the trap frame.  Don't clobber flags. 
	     *
	     */
			"mov %c[eax](%0), %%eax \n\t"
			"mov %c[ebx](%0), %%ebx \n\t"
			"mov %c[edx](%0), %%edx \n\t"
			"mov %c[esi](%0), %%esi \n\t"
			"mov %c[edi](%0), %%edi \n\t"
			"mov %c[ebp](%0), %%ebp \n\t"

			"mov %c[ecx](%0), %%ecx \n\t" /* kills %0 (ecx) imp! */

			"jne 1f \n\t"
			"vmlaunch \n\t"
			"jmp 2f \n\t"
			"1: \n\t" 
			"vmresume \n\t"
			"2: \n\t"

			".Lvmx_return: "

	    /* POST VM EXIT... */
            "mov %0, %c[wordsize](%%esp) \n\t"
            "pop %0 \n\t"
            /* Save general purpose guest registers and cr2 back to the trapframe.
	     *
	     * Be careful that the number of pushes (above) and pops are symmetrical.
	     */
	    /* Your code here */
			"mov %%eax, %c[eax](%0) \n\t"
			"mov %%ebx, %c[ebx](%0) \n\t"
			"pop %c[ecx](%0) \n\t"
			"mov %%edx, %c[edx](%0) \n\t"
			"mov %%esi, %c[esi](%0) \n\t"
			"mov %%edi, %c[edi](%0) \n\t"
			"mov %%ebp, %c[ebp](%0) \n\t"

			"mov %%cr2, %%eax   \n\t"
			"mov %%eax, %c[cr2](%0) \n\t"
            
			"pop  %%ebp; pop  %%edx \n\t"

			"setbe %c[fail](%0) \n\t"
            : : "c"(tf), "d"((unsigned long)HOST_ESP), 
            [launched]"i"(offsetof(struct Trapframe, tf_ds)),
            [fail]"i"(offsetof(struct Trapframe, tf_es)),
			[host_esp]"i"(offsetof(struct Trapframe, tf_esp)),
            [eax]"i"(offsetof(struct Trapframe, tf_regs.reg_eax)),
            [ebx]"i"(offsetof(struct Trapframe, tf_regs.reg_ebx)),
            [ecx]"i"(offsetof(struct Trapframe, tf_regs.reg_ecx)),
            [edx]"i"(offsetof(struct Trapframe, tf_regs.reg_edx)),
            [esi]"i"(offsetof(struct Trapframe, tf_regs.reg_esi)),
            [edi]"i"(offsetof(struct Trapframe, tf_regs.reg_edi)),
            [ebp]"i"(offsetof(struct Trapframe, tf_regs.reg_ebp)),
            [cr2]"i"(offsetof(struct Trapframe, tf_err)),
            [wordsize]"i"(sizeof(uint32_t))
                : "cc", "memory"
                    , "eax", "ebx", "edi", "esi"
    );
	if(tf->tf_es)
	{
		cprintf("Error\n");
	}
	else
	{
		curenv -> env_tf.tf_esp = GUEST_ESP;
		curenv -> env_tf.tf_eip = GUEST_EIP;
		vmexit();
	}
}

struct PageInfo* vmx_init_vmcs()
{
	struct PageInfo *p = page_alloc(ALLOC_ZERO);
	if(!p)
	{
		return NULL;
	}
	return p;
}

int virtualmachinerun(struct Env *e)
{
	if(e->env_type != ENV_TYPE_VIRTUAL)
	{
		return -1;
	}
	uint8_t er;
	if(e->env_runs == 1)
	{
		physaddr_t vmcs_phy_addr = PADDR(e->env_vmxinfo.vmcontrolstate);
		er = vmclr(vmcs_phy_addr);
		if(error)
			return -1;
		er = vmload(vmcs_phy_addr);
		if(er)
			return -1;
		init_host();
		init_guest();
	}
	else
	{
		er = vmload(PADDR(e->env_vmxinfo.vmcontrolstate));
		if(er)
			return -1;
	}
	curenv -> env_tf.tf_esp = GUEST_ESP;  // see what is this
	curenv -> env_tf.tf_eip = GUEST_EIP;  // see what is this
	assembly_run(&e->env_tf);
	return 0;
}