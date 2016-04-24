
int virtualmachinerun(struct Env *);
struct PageInfo * vmx_init_vmcs();

#define GUEST_ESP                                     0x0000681C
#define GUEST_EIP                                     0x0000681E
