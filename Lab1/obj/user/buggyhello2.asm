
obj/user/buggyhello2:     file format elf32-i386


Disassembly of section .text:

00800020 <_start>:
// starts us running when we are initially loaded into a new environment.
.text
.globl _start
_start:
	// See if we were started with arguments on the stack
	cmpl $USTACKTOP, %esp
  800020:	81 fc 00 e0 bf ee    	cmp    $0xeebfe000,%esp
	jne args_exist
  800026:	75 04                	jne    80002c <args_exist>

	// If not, push dummy argc/argv arguments.
	// This happens when we are loaded by the kernel,
	// because the kernel does not know about passing arguments.
	pushl $0
  800028:	6a 00                	push   $0x0
	pushl $0
  80002a:	6a 00                	push   $0x0

0080002c <args_exist>:

args_exist:
	call libmain
  80002c:	e8 1f 00 00 00       	call   800050 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_cputs(hello, 1024*1024);
  800039:	a1 00 20 80 00       	mov    0x802000,%eax
  80003e:	c7 44 24 04 00 00 10 	movl   $0x100000,0x4(%esp)
  800045:	00 
  800046:	89 04 24             	mov    %eax,(%esp)
  800049:	e8 c5 00 00 00       	call   800113 <sys_cputs>
}
  80004e:	c9                   	leave  
  80004f:	c3                   	ret    

00800050 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800050:	55                   	push   %ebp
  800051:	89 e5                	mov    %esp,%ebp
  800053:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800056:	e8 81 01 00 00       	call   8001dc <sys_getenvid>
  80005b:	25 ff 03 00 00       	and    $0x3ff,%eax
  800060:	c1 e0 02             	shl    $0x2,%eax
  800063:	89 c2                	mov    %eax,%edx
  800065:	c1 e2 05             	shl    $0x5,%edx
  800068:	29 c2                	sub    %eax,%edx
  80006a:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800070:	a3 08 20 80 00       	mov    %eax,0x802008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800079:	7e 0a                	jle    800085 <libmain+0x35>
		binaryname = argv[0];
  80007b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007e:	8b 00                	mov    (%eax),%eax
  800080:	a3 04 20 80 00       	mov    %eax,0x802004

	// call user main routine
	umain(argc, argv);
  800085:	8b 45 0c             	mov    0xc(%ebp),%eax
  800088:	89 44 24 04          	mov    %eax,0x4(%esp)
  80008c:	8b 45 08             	mov    0x8(%ebp),%eax
  80008f:	89 04 24             	mov    %eax,(%esp)
  800092:	e8 9c ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800097:	e8 02 00 00 00       	call   80009e <exit>
}
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000a4:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ab:	e8 e9 00 00 00       	call   800199 <sys_env_destroy>
}
  8000b0:	c9                   	leave  
  8000b1:	c3                   	ret    

008000b2 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b2:	55                   	push   %ebp
  8000b3:	89 e5                	mov    %esp,%ebp
  8000b5:	57                   	push   %edi
  8000b6:	56                   	push   %esi
  8000b7:	53                   	push   %ebx
  8000b8:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8000be:	8b 55 10             	mov    0x10(%ebp),%edx
  8000c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000c4:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000c7:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000ca:	8b 75 20             	mov    0x20(%ebp),%esi
  8000cd:	cd 30                	int    $0x30
  8000cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000d6:	74 30                	je     800108 <syscall+0x56>
  8000d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000dc:	7e 2a                	jle    800108 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000e1:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000ec:	c7 44 24 08 58 14 80 	movl   $0x801458,0x8(%esp)
  8000f3:	00 
  8000f4:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000fb:	00 
  8000fc:	c7 04 24 75 14 80 00 	movl   $0x801475,(%esp)
  800103:	e8 2c 03 00 00       	call   800434 <_panic>

	return ret;
  800108:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  80010b:	83 c4 3c             	add    $0x3c,%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5f                   	pop    %edi
  800111:	5d                   	pop    %ebp
  800112:	c3                   	ret    

00800113 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800113:	55                   	push   %ebp
  800114:	89 e5                	mov    %esp,%ebp
  800116:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800119:	8b 45 08             	mov    0x8(%ebp),%eax
  80011c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800123:	00 
  800124:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80012b:	00 
  80012c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800133:	00 
  800134:	8b 55 0c             	mov    0xc(%ebp),%edx
  800137:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80013b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80013f:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800146:	00 
  800147:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80014e:	e8 5f ff ff ff       	call   8000b2 <syscall>
}
  800153:	c9                   	leave  
  800154:	c3                   	ret    

00800155 <sys_cgetc>:

int
sys_cgetc(void)
{
  800155:	55                   	push   %ebp
  800156:	89 e5                	mov    %esp,%ebp
  800158:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80015b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800162:	00 
  800163:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80016a:	00 
  80016b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800172:	00 
  800173:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80017a:	00 
  80017b:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800182:	00 
  800183:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80018a:	00 
  80018b:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800192:	e8 1b ff ff ff       	call   8000b2 <syscall>
}
  800197:	c9                   	leave  
  800198:	c3                   	ret    

00800199 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800199:	55                   	push   %ebp
  80019a:	89 e5                	mov    %esp,%ebp
  80019c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80019f:	8b 45 08             	mov    0x8(%ebp),%eax
  8001a2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001a9:	00 
  8001aa:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001b1:	00 
  8001b2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001b9:	00 
  8001ba:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001c1:	00 
  8001c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c6:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001cd:	00 
  8001ce:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001d5:	e8 d8 fe ff ff       	call   8000b2 <syscall>
}
  8001da:	c9                   	leave  
  8001db:	c3                   	ret    

008001dc <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001dc:	55                   	push   %ebp
  8001dd:	89 e5                	mov    %esp,%ebp
  8001df:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001e2:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001e9:	00 
  8001ea:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001f1:	00 
  8001f2:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001f9:	00 
  8001fa:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800201:	00 
  800202:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800209:	00 
  80020a:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800211:	00 
  800212:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800219:	e8 94 fe ff ff       	call   8000b2 <syscall>
}
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <sys_yield>:

void
sys_yield(void)
{
  800220:	55                   	push   %ebp
  800221:	89 e5                	mov    %esp,%ebp
  800223:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800226:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80022d:	00 
  80022e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800235:	00 
  800236:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80023d:	00 
  80023e:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800245:	00 
  800246:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80024d:	00 
  80024e:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800255:	00 
  800256:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80025d:	e8 50 fe ff ff       	call   8000b2 <syscall>
}
  800262:	c9                   	leave  
  800263:	c3                   	ret    

00800264 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800264:	55                   	push   %ebp
  800265:	89 e5                	mov    %esp,%ebp
  800267:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80026a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80026d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800270:	8b 45 08             	mov    0x8(%ebp),%eax
  800273:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80027a:	00 
  80027b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800282:	00 
  800283:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800287:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80028b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80028f:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800296:	00 
  800297:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80029e:	e8 0f fe ff ff       	call   8000b2 <syscall>
}
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	56                   	push   %esi
  8002a9:	53                   	push   %ebx
  8002aa:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002ad:	8b 75 18             	mov    0x18(%ebp),%esi
  8002b0:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002b3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002bc:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002c0:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002c4:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002c8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d7:	00 
  8002d8:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002df:	e8 ce fd ff ff       	call   8000b2 <syscall>
}
  8002e4:	83 c4 20             	add    $0x20,%esp
  8002e7:	5b                   	pop    %ebx
  8002e8:	5e                   	pop    %esi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002f1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f7:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002fe:	00 
  8002ff:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800306:	00 
  800307:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80030e:	00 
  80030f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800313:	89 44 24 08          	mov    %eax,0x8(%esp)
  800317:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80031e:	00 
  80031f:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800326:	e8 87 fd ff ff       	call   8000b2 <syscall>
}
  80032b:	c9                   	leave  
  80032c:	c3                   	ret    

0080032d <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800333:	8b 55 0c             	mov    0xc(%ebp),%edx
  800336:	8b 45 08             	mov    0x8(%ebp),%eax
  800339:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800340:	00 
  800341:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800348:	00 
  800349:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800350:	00 
  800351:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800355:	89 44 24 08          	mov    %eax,0x8(%esp)
  800359:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800360:	00 
  800361:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800368:	e8 45 fd ff ff       	call   8000b2 <syscall>
}
  80036d:	c9                   	leave  
  80036e:	c3                   	ret    

0080036f <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80036f:	55                   	push   %ebp
  800370:	89 e5                	mov    %esp,%ebp
  800372:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800375:	8b 55 0c             	mov    0xc(%ebp),%edx
  800378:	8b 45 08             	mov    0x8(%ebp),%eax
  80037b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800382:	00 
  800383:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80038a:	00 
  80038b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800392:	00 
  800393:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800397:	89 44 24 08          	mov    %eax,0x8(%esp)
  80039b:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003a2:	00 
  8003a3:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003aa:	e8 03 fd ff ff       	call   8000b2 <syscall>
}
  8003af:	c9                   	leave  
  8003b0:	c3                   	ret    

008003b1 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003b1:	55                   	push   %ebp
  8003b2:	89 e5                	mov    %esp,%ebp
  8003b4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003b7:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ba:	8b 55 10             	mov    0x10(%ebp),%edx
  8003bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003c7:	00 
  8003c8:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003cc:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d3:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003db:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003e2:	00 
  8003e3:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003ea:	e8 c3 fc ff ff       	call   8000b2 <syscall>
}
  8003ef:	c9                   	leave  
  8003f0:	c3                   	ret    

008003f1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003f1:	55                   	push   %ebp
  8003f2:	89 e5                	mov    %esp,%ebp
  8003f4:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fa:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800401:	00 
  800402:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800409:	00 
  80040a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800411:	00 
  800412:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800419:	00 
  80041a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80041e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800425:	00 
  800426:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80042d:	e8 80 fc ff ff       	call   8000b2 <syscall>
}
  800432:	c9                   	leave  
  800433:	c3                   	ret    

00800434 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800434:	55                   	push   %ebp
  800435:	89 e5                	mov    %esp,%ebp
  800437:	53                   	push   %ebx
  800438:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80043b:	8d 45 14             	lea    0x14(%ebp),%eax
  80043e:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800441:	8b 1d 04 20 80 00    	mov    0x802004,%ebx
  800447:	e8 90 fd ff ff       	call   8001dc <sys_getenvid>
  80044c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80044f:	89 54 24 10          	mov    %edx,0x10(%esp)
  800453:	8b 55 08             	mov    0x8(%ebp),%edx
  800456:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80045a:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80045e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800462:	c7 04 24 84 14 80 00 	movl   $0x801484,(%esp)
  800469:	e8 e1 00 00 00       	call   80054f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80046e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800471:	89 44 24 04          	mov    %eax,0x4(%esp)
  800475:	8b 45 10             	mov    0x10(%ebp),%eax
  800478:	89 04 24             	mov    %eax,(%esp)
  80047b:	e8 6b 00 00 00       	call   8004eb <vcprintf>
	cprintf("\n");
  800480:	c7 04 24 a7 14 80 00 	movl   $0x8014a7,(%esp)
  800487:	e8 c3 00 00 00       	call   80054f <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80048c:	cc                   	int3   
  80048d:	eb fd                	jmp    80048c <_panic+0x58>

0080048f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80048f:	55                   	push   %ebp
  800490:	89 e5                	mov    %esp,%ebp
  800492:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800495:	8b 45 0c             	mov    0xc(%ebp),%eax
  800498:	8b 00                	mov    (%eax),%eax
  80049a:	8d 48 01             	lea    0x1(%eax),%ecx
  80049d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a0:	89 0a                	mov    %ecx,(%edx)
  8004a2:	8b 55 08             	mov    0x8(%ebp),%edx
  8004a5:	89 d1                	mov    %edx,%ecx
  8004a7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004aa:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004ae:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b1:	8b 00                	mov    (%eax),%eax
  8004b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b8:	75 20                	jne    8004da <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bd:	8b 00                	mov    (%eax),%eax
  8004bf:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004c2:	83 c2 08             	add    $0x8,%edx
  8004c5:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c9:	89 14 24             	mov    %edx,(%esp)
  8004cc:	e8 42 fc ff ff       	call   800113 <sys_cputs>
		b->idx = 0;
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004dd:	8b 40 04             	mov    0x4(%eax),%eax
  8004e0:	8d 50 01             	lea    0x1(%eax),%edx
  8004e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e6:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004e9:	c9                   	leave  
  8004ea:	c3                   	ret    

008004eb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004f4:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004fb:	00 00 00 
	b.cnt = 0;
  8004fe:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800505:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800508:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80050f:	8b 45 08             	mov    0x8(%ebp),%eax
  800512:	89 44 24 08          	mov    %eax,0x8(%esp)
  800516:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80051c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800520:	c7 04 24 8f 04 80 00 	movl   $0x80048f,(%esp)
  800527:	e8 bd 01 00 00       	call   8006e9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80052c:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800532:	89 44 24 04          	mov    %eax,0x4(%esp)
  800536:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80053c:	83 c0 08             	add    $0x8,%eax
  80053f:	89 04 24             	mov    %eax,(%esp)
  800542:	e8 cc fb ff ff       	call   800113 <sys_cputs>

	return b.cnt;
  800547:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80054d:	c9                   	leave  
  80054e:	c3                   	ret    

0080054f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80054f:	55                   	push   %ebp
  800550:	89 e5                	mov    %esp,%ebp
  800552:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800555:	8d 45 0c             	lea    0xc(%ebp),%eax
  800558:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80055b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80055e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800562:	8b 45 08             	mov    0x8(%ebp),%eax
  800565:	89 04 24             	mov    %eax,(%esp)
  800568:	e8 7e ff ff ff       	call   8004eb <vcprintf>
  80056d:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800570:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800573:	c9                   	leave  
  800574:	c3                   	ret    

00800575 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800575:	55                   	push   %ebp
  800576:	89 e5                	mov    %esp,%ebp
  800578:	53                   	push   %ebx
  800579:	83 ec 34             	sub    $0x34,%esp
  80057c:	8b 45 10             	mov    0x10(%ebp),%eax
  80057f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800582:	8b 45 14             	mov    0x14(%ebp),%eax
  800585:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800588:	8b 45 18             	mov    0x18(%ebp),%eax
  80058b:	ba 00 00 00 00       	mov    $0x0,%edx
  800590:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800593:	77 72                	ja     800607 <printnum+0x92>
  800595:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800598:	72 05                	jb     80059f <printnum+0x2a>
  80059a:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80059d:	77 68                	ja     800607 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80059f:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005a2:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005a5:	8b 45 18             	mov    0x18(%ebp),%eax
  8005a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ad:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005bb:	89 04 24             	mov    %eax,(%esp)
  8005be:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005c2:	e8 d9 0b 00 00       	call   8011a0 <__udivdi3>
  8005c7:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005ca:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005ce:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005d2:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005d5:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005d9:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8005eb:	89 04 24             	mov    %eax,(%esp)
  8005ee:	e8 82 ff ff ff       	call   800575 <printnum>
  8005f3:	eb 1c                	jmp    800611 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005f5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005fc:	8b 45 20             	mov    0x20(%ebp),%eax
  8005ff:	89 04 24             	mov    %eax,(%esp)
  800602:	8b 45 08             	mov    0x8(%ebp),%eax
  800605:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800607:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80060b:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80060f:	7f e4                	jg     8005f5 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800611:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800614:	bb 00 00 00 00       	mov    $0x0,%ebx
  800619:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80061c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80061f:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800623:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800627:	89 04 24             	mov    %eax,(%esp)
  80062a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062e:	e8 9d 0c 00 00       	call   8012d0 <__umoddi3>
  800633:	05 88 15 80 00       	add    $0x801588,%eax
  800638:	0f b6 00             	movzbl (%eax),%eax
  80063b:	0f be c0             	movsbl %al,%eax
  80063e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800641:	89 54 24 04          	mov    %edx,0x4(%esp)
  800645:	89 04 24             	mov    %eax,(%esp)
  800648:	8b 45 08             	mov    0x8(%ebp),%eax
  80064b:	ff d0                	call   *%eax
}
  80064d:	83 c4 34             	add    $0x34,%esp
  800650:	5b                   	pop    %ebx
  800651:	5d                   	pop    %ebp
  800652:	c3                   	ret    

00800653 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800653:	55                   	push   %ebp
  800654:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800656:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80065a:	7e 14                	jle    800670 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80065c:	8b 45 08             	mov    0x8(%ebp),%eax
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	8d 48 08             	lea    0x8(%eax),%ecx
  800664:	8b 55 08             	mov    0x8(%ebp),%edx
  800667:	89 0a                	mov    %ecx,(%edx)
  800669:	8b 50 04             	mov    0x4(%eax),%edx
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	eb 30                	jmp    8006a0 <getuint+0x4d>
	else if (lflag)
  800670:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800674:	74 16                	je     80068c <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800676:	8b 45 08             	mov    0x8(%ebp),%eax
  800679:	8b 00                	mov    (%eax),%eax
  80067b:	8d 48 04             	lea    0x4(%eax),%ecx
  80067e:	8b 55 08             	mov    0x8(%ebp),%edx
  800681:	89 0a                	mov    %ecx,(%edx)
  800683:	8b 00                	mov    (%eax),%eax
  800685:	ba 00 00 00 00       	mov    $0x0,%edx
  80068a:	eb 14                	jmp    8006a0 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80068c:	8b 45 08             	mov    0x8(%ebp),%eax
  80068f:	8b 00                	mov    (%eax),%eax
  800691:	8d 48 04             	lea    0x4(%eax),%ecx
  800694:	8b 55 08             	mov    0x8(%ebp),%edx
  800697:	89 0a                	mov    %ecx,(%edx)
  800699:	8b 00                	mov    (%eax),%eax
  80069b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006a0:	5d                   	pop    %ebp
  8006a1:	c3                   	ret    

008006a2 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006a2:	55                   	push   %ebp
  8006a3:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006a5:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006a9:	7e 14                	jle    8006bf <getint+0x1d>
		return va_arg(*ap, long long);
  8006ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	8d 48 08             	lea    0x8(%eax),%ecx
  8006b3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b6:	89 0a                	mov    %ecx,(%edx)
  8006b8:	8b 50 04             	mov    0x4(%eax),%edx
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	eb 28                	jmp    8006e7 <getint+0x45>
	else if (lflag)
  8006bf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006c3:	74 12                	je     8006d7 <getint+0x35>
		return va_arg(*ap, long);
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d0:	89 0a                	mov    %ecx,(%edx)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	99                   	cltd   
  8006d5:	eb 10                	jmp    8006e7 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006d7:	8b 45 08             	mov    0x8(%ebp),%eax
  8006da:	8b 00                	mov    (%eax),%eax
  8006dc:	8d 48 04             	lea    0x4(%eax),%ecx
  8006df:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e2:	89 0a                	mov    %ecx,(%edx)
  8006e4:	8b 00                	mov    (%eax),%eax
  8006e6:	99                   	cltd   
}
  8006e7:	5d                   	pop    %ebp
  8006e8:	c3                   	ret    

008006e9 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e9:	55                   	push   %ebp
  8006ea:	89 e5                	mov    %esp,%ebp
  8006ec:	56                   	push   %esi
  8006ed:	53                   	push   %ebx
  8006ee:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f1:	eb 18                	jmp    80070b <vprintfmt+0x22>
			if (ch == '\0')
  8006f3:	85 db                	test   %ebx,%ebx
  8006f5:	75 05                	jne    8006fc <vprintfmt+0x13>
				return;
  8006f7:	e9 05 04 00 00       	jmp    800b01 <vprintfmt+0x418>
			putch(ch, putdat);
  8006fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800703:	89 1c 24             	mov    %ebx,(%esp)
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80070b:	8b 45 10             	mov    0x10(%ebp),%eax
  80070e:	8d 50 01             	lea    0x1(%eax),%edx
  800711:	89 55 10             	mov    %edx,0x10(%ebp)
  800714:	0f b6 00             	movzbl (%eax),%eax
  800717:	0f b6 d8             	movzbl %al,%ebx
  80071a:	83 fb 25             	cmp    $0x25,%ebx
  80071d:	75 d4                	jne    8006f3 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80071f:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800723:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80072a:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800731:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800738:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80073f:	8b 45 10             	mov    0x10(%ebp),%eax
  800742:	8d 50 01             	lea    0x1(%eax),%edx
  800745:	89 55 10             	mov    %edx,0x10(%ebp)
  800748:	0f b6 00             	movzbl (%eax),%eax
  80074b:	0f b6 d8             	movzbl %al,%ebx
  80074e:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800751:	83 f8 55             	cmp    $0x55,%eax
  800754:	0f 87 76 03 00 00    	ja     800ad0 <vprintfmt+0x3e7>
  80075a:	8b 04 85 ac 15 80 00 	mov    0x8015ac(,%eax,4),%eax
  800761:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800763:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800767:	eb d6                	jmp    80073f <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800769:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80076d:	eb d0                	jmp    80073f <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80076f:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800776:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800779:	89 d0                	mov    %edx,%eax
  80077b:	c1 e0 02             	shl    $0x2,%eax
  80077e:	01 d0                	add    %edx,%eax
  800780:	01 c0                	add    %eax,%eax
  800782:	01 d8                	add    %ebx,%eax
  800784:	83 e8 30             	sub    $0x30,%eax
  800787:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80078a:	8b 45 10             	mov    0x10(%ebp),%eax
  80078d:	0f b6 00             	movzbl (%eax),%eax
  800790:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800793:	83 fb 2f             	cmp    $0x2f,%ebx
  800796:	7e 0b                	jle    8007a3 <vprintfmt+0xba>
  800798:	83 fb 39             	cmp    $0x39,%ebx
  80079b:	7f 06                	jg     8007a3 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079d:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007a1:	eb d3                	jmp    800776 <vprintfmt+0x8d>
			goto process_precision;
  8007a3:	eb 33                	jmp    8007d8 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a8:	8d 50 04             	lea    0x4(%eax),%edx
  8007ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8007ae:	8b 00                	mov    (%eax),%eax
  8007b0:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007b3:	eb 23                	jmp    8007d8 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007b5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b9:	79 0c                	jns    8007c7 <vprintfmt+0xde>
				width = 0;
  8007bb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007c2:	e9 78 ff ff ff       	jmp    80073f <vprintfmt+0x56>
  8007c7:	e9 73 ff ff ff       	jmp    80073f <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007cc:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007d3:	e9 67 ff ff ff       	jmp    80073f <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007d8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007dc:	79 12                	jns    8007f0 <vprintfmt+0x107>
				width = precision, precision = -1;
  8007de:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007e4:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007eb:	e9 4f ff ff ff       	jmp    80073f <vprintfmt+0x56>
  8007f0:	e9 4a ff ff ff       	jmp    80073f <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007f5:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007f9:	e9 41 ff ff ff       	jmp    80073f <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007fe:	8b 45 14             	mov    0x14(%ebp),%eax
  800801:	8d 50 04             	lea    0x4(%eax),%edx
  800804:	89 55 14             	mov    %edx,0x14(%ebp)
  800807:	8b 00                	mov    (%eax),%eax
  800809:	8b 55 0c             	mov    0xc(%ebp),%edx
  80080c:	89 54 24 04          	mov    %edx,0x4(%esp)
  800810:	89 04 24             	mov    %eax,(%esp)
  800813:	8b 45 08             	mov    0x8(%ebp),%eax
  800816:	ff d0                	call   *%eax
			break;
  800818:	e9 de 02 00 00       	jmp    800afb <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80081d:	8b 45 14             	mov    0x14(%ebp),%eax
  800820:	8d 50 04             	lea    0x4(%eax),%edx
  800823:	89 55 14             	mov    %edx,0x14(%ebp)
  800826:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800828:	85 db                	test   %ebx,%ebx
  80082a:	79 02                	jns    80082e <vprintfmt+0x145>
				err = -err;
  80082c:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80082e:	83 fb 09             	cmp    $0x9,%ebx
  800831:	7f 0b                	jg     80083e <vprintfmt+0x155>
  800833:	8b 34 9d 60 15 80 00 	mov    0x801560(,%ebx,4),%esi
  80083a:	85 f6                	test   %esi,%esi
  80083c:	75 23                	jne    800861 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80083e:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800842:	c7 44 24 08 99 15 80 	movl   $0x801599,0x8(%esp)
  800849:	00 
  80084a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80084d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800851:	8b 45 08             	mov    0x8(%ebp),%eax
  800854:	89 04 24             	mov    %eax,(%esp)
  800857:	e8 ac 02 00 00       	call   800b08 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80085c:	e9 9a 02 00 00       	jmp    800afb <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800861:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800865:	c7 44 24 08 a2 15 80 	movl   $0x8015a2,0x8(%esp)
  80086c:	00 
  80086d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800870:	89 44 24 04          	mov    %eax,0x4(%esp)
  800874:	8b 45 08             	mov    0x8(%ebp),%eax
  800877:	89 04 24             	mov    %eax,(%esp)
  80087a:	e8 89 02 00 00       	call   800b08 <printfmt>
			break;
  80087f:	e9 77 02 00 00       	jmp    800afb <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800884:	8b 45 14             	mov    0x14(%ebp),%eax
  800887:	8d 50 04             	lea    0x4(%eax),%edx
  80088a:	89 55 14             	mov    %edx,0x14(%ebp)
  80088d:	8b 30                	mov    (%eax),%esi
  80088f:	85 f6                	test   %esi,%esi
  800891:	75 05                	jne    800898 <vprintfmt+0x1af>
				p = "(null)";
  800893:	be a5 15 80 00       	mov    $0x8015a5,%esi
			if (width > 0 && padc != '-')
  800898:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80089c:	7e 37                	jle    8008d5 <vprintfmt+0x1ec>
  80089e:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008a2:	74 31                	je     8008d5 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ab:	89 34 24             	mov    %esi,(%esp)
  8008ae:	e8 72 03 00 00       	call   800c25 <strnlen>
  8008b3:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008b6:	eb 17                	jmp    8008cf <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008b8:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008bf:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008c3:	89 04 24             	mov    %eax,(%esp)
  8008c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c9:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008cb:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008cf:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008d3:	7f e3                	jg     8008b8 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008d5:	eb 38                	jmp    80090f <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d7:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008db:	74 1f                	je     8008fc <vprintfmt+0x213>
  8008dd:	83 fb 1f             	cmp    $0x1f,%ebx
  8008e0:	7e 05                	jle    8008e7 <vprintfmt+0x1fe>
  8008e2:	83 fb 7e             	cmp    $0x7e,%ebx
  8008e5:	7e 15                	jle    8008fc <vprintfmt+0x213>
					putch('?', putdat);
  8008e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ea:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ee:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	ff d0                	call   *%eax
  8008fa:	eb 0f                	jmp    80090b <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008fc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ff:	89 44 24 04          	mov    %eax,0x4(%esp)
  800903:	89 1c 24             	mov    %ebx,(%esp)
  800906:	8b 45 08             	mov    0x8(%ebp),%eax
  800909:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80090b:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80090f:	89 f0                	mov    %esi,%eax
  800911:	8d 70 01             	lea    0x1(%eax),%esi
  800914:	0f b6 00             	movzbl (%eax),%eax
  800917:	0f be d8             	movsbl %al,%ebx
  80091a:	85 db                	test   %ebx,%ebx
  80091c:	74 10                	je     80092e <vprintfmt+0x245>
  80091e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800922:	78 b3                	js     8008d7 <vprintfmt+0x1ee>
  800924:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800928:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80092c:	79 a9                	jns    8008d7 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092e:	eb 17                	jmp    800947 <vprintfmt+0x25e>
				putch(' ', putdat);
  800930:	8b 45 0c             	mov    0xc(%ebp),%eax
  800933:	89 44 24 04          	mov    %eax,0x4(%esp)
  800937:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80093e:	8b 45 08             	mov    0x8(%ebp),%eax
  800941:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800943:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800947:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80094b:	7f e3                	jg     800930 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80094d:	e9 a9 01 00 00       	jmp    800afb <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800952:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800955:	89 44 24 04          	mov    %eax,0x4(%esp)
  800959:	8d 45 14             	lea    0x14(%ebp),%eax
  80095c:	89 04 24             	mov    %eax,(%esp)
  80095f:	e8 3e fd ff ff       	call   8006a2 <getint>
  800964:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800967:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80096a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80096d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800970:	85 d2                	test   %edx,%edx
  800972:	79 26                	jns    80099a <vprintfmt+0x2b1>
				putch('-', putdat);
  800974:	8b 45 0c             	mov    0xc(%ebp),%eax
  800977:	89 44 24 04          	mov    %eax,0x4(%esp)
  80097b:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800982:	8b 45 08             	mov    0x8(%ebp),%eax
  800985:	ff d0                	call   *%eax
				num = -(long long) num;
  800987:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80098a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80098d:	f7 d8                	neg    %eax
  80098f:	83 d2 00             	adc    $0x0,%edx
  800992:	f7 da                	neg    %edx
  800994:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800997:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80099a:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009a1:	e9 e1 00 00 00       	jmp    800a87 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a6:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009a9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009ad:	8d 45 14             	lea    0x14(%ebp),%eax
  8009b0:	89 04 24             	mov    %eax,(%esp)
  8009b3:	e8 9b fc ff ff       	call   800653 <getuint>
  8009b8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009bb:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009be:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009c5:	e9 bd 00 00 00       	jmp    800a87 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009ca:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009d1:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d8:	8d 45 14             	lea    0x14(%ebp),%eax
  8009db:	89 04 24             	mov    %eax,(%esp)
  8009de:	e8 70 fc ff ff       	call   800653 <getuint>
  8009e3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8009e9:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8009ed:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009f0:	89 54 24 18          	mov    %edx,0x18(%esp)
  8009f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f7:	89 54 24 14          	mov    %edx,0x14(%esp)
  8009fb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a02:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a05:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a09:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	8b 45 08             	mov    0x8(%ebp),%eax
  800a17:	89 04 24             	mov    %eax,(%esp)
  800a1a:	e8 56 fb ff ff       	call   800575 <printnum>
			break;
  800a1f:	e9 d7 00 00 00       	jmp    800afb <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a24:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a27:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2b:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a32:	8b 45 08             	mov    0x8(%ebp),%eax
  800a35:	ff d0                	call   *%eax
			putch('x', putdat);
  800a37:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a3e:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a45:	8b 45 08             	mov    0x8(%ebp),%eax
  800a48:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a4a:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4d:	8d 50 04             	lea    0x4(%eax),%edx
  800a50:	89 55 14             	mov    %edx,0x14(%ebp)
  800a53:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a55:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a58:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a5f:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a66:	eb 1f                	jmp    800a87 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a68:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a6b:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6f:	8d 45 14             	lea    0x14(%ebp),%eax
  800a72:	89 04 24             	mov    %eax,(%esp)
  800a75:	e8 d9 fb ff ff       	call   800653 <getuint>
  800a7a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a7d:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a80:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a87:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a8b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a8e:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a92:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a95:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a99:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a9d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800aa0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aa3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aae:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	89 04 24             	mov    %eax,(%esp)
  800ab8:	e8 b8 fa ff ff       	call   800575 <printnum>
			break;
  800abd:	eb 3c                	jmp    800afb <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800abf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac6:	89 1c 24             	mov    %ebx,(%esp)
  800ac9:	8b 45 08             	mov    0x8(%ebp),%eax
  800acc:	ff d0                	call   *%eax
			break;
  800ace:	eb 2b                	jmp    800afb <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ad3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad7:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ade:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae1:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ae3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae7:	eb 04                	jmp    800aed <vprintfmt+0x404>
  800ae9:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800aed:	8b 45 10             	mov    0x10(%ebp),%eax
  800af0:	83 e8 01             	sub    $0x1,%eax
  800af3:	0f b6 00             	movzbl (%eax),%eax
  800af6:	3c 25                	cmp    $0x25,%al
  800af8:	75 ef                	jne    800ae9 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800afa:	90                   	nop
		}
	}
  800afb:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800afc:	e9 0a fc ff ff       	jmp    80070b <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b01:	83 c4 40             	add    $0x40,%esp
  800b04:	5b                   	pop    %ebx
  800b05:	5e                   	pop    %esi
  800b06:	5d                   	pop    %ebp
  800b07:	c3                   	ret    

00800b08 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b08:	55                   	push   %ebp
  800b09:	89 e5                	mov    %esp,%ebp
  800b0b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b0e:	8d 45 14             	lea    0x14(%ebp),%eax
  800b11:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b14:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b17:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b1b:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b29:	8b 45 08             	mov    0x8(%ebp),%eax
  800b2c:	89 04 24             	mov    %eax,(%esp)
  800b2f:	e8 b5 fb ff ff       	call   8006e9 <vprintfmt>
	va_end(ap);
}
  800b34:	c9                   	leave  
  800b35:	c3                   	ret    

00800b36 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b39:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3c:	8b 40 08             	mov    0x8(%eax),%eax
  800b3f:	8d 50 01             	lea    0x1(%eax),%edx
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4b:	8b 10                	mov    (%eax),%edx
  800b4d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b50:	8b 40 04             	mov    0x4(%eax),%eax
  800b53:	39 c2                	cmp    %eax,%edx
  800b55:	73 12                	jae    800b69 <sprintputch+0x33>
		*b->buf++ = ch;
  800b57:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b5a:	8b 00                	mov    (%eax),%eax
  800b5c:	8d 48 01             	lea    0x1(%eax),%ecx
  800b5f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b62:	89 0a                	mov    %ecx,(%edx)
  800b64:	8b 55 08             	mov    0x8(%ebp),%edx
  800b67:	88 10                	mov    %dl,(%eax)
}
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b6b:	55                   	push   %ebp
  800b6c:	89 e5                	mov    %esp,%ebp
  800b6e:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b71:	8b 45 08             	mov    0x8(%ebp),%eax
  800b74:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b80:	01 d0                	add    %edx,%eax
  800b82:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b85:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b8c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b90:	74 06                	je     800b98 <vsnprintf+0x2d>
  800b92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b96:	7f 07                	jg     800b9f <vsnprintf+0x34>
		return -E_INVAL;
  800b98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b9d:	eb 2a                	jmp    800bc9 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b9f:	8b 45 14             	mov    0x14(%ebp),%eax
  800ba2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba9:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bad:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bb0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bb4:	c7 04 24 36 0b 80 00 	movl   $0x800b36,(%esp)
  800bbb:	e8 29 fb ff ff       	call   8006e9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bc0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bc3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bc6:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bd1:	8d 45 14             	lea    0x14(%ebp),%eax
  800bd4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bd7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bda:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bde:	8b 45 10             	mov    0x10(%ebp),%eax
  800be1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800be5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bec:	8b 45 08             	mov    0x8(%ebp),%eax
  800bef:	89 04 24             	mov    %eax,(%esp)
  800bf2:	e8 74 ff ff ff       	call   800b6b <vsnprintf>
  800bf7:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bfd:	c9                   	leave  
  800bfe:	c3                   	ret    

00800bff <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c05:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c0c:	eb 08                	jmp    800c16 <strlen+0x17>
		n++;
  800c0e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c12:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c16:	8b 45 08             	mov    0x8(%ebp),%eax
  800c19:	0f b6 00             	movzbl (%eax),%eax
  800c1c:	84 c0                	test   %al,%al
  800c1e:	75 ee                	jne    800c0e <strlen+0xf>
		n++;
	return n;
  800c20:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c23:	c9                   	leave  
  800c24:	c3                   	ret    

00800c25 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c25:	55                   	push   %ebp
  800c26:	89 e5                	mov    %esp,%ebp
  800c28:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c32:	eb 0c                	jmp    800c40 <strnlen+0x1b>
		n++;
  800c34:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c38:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c3c:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c40:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c44:	74 0a                	je     800c50 <strnlen+0x2b>
  800c46:	8b 45 08             	mov    0x8(%ebp),%eax
  800c49:	0f b6 00             	movzbl (%eax),%eax
  800c4c:	84 c0                	test   %al,%al
  800c4e:	75 e4                	jne    800c34 <strnlen+0xf>
		n++;
	return n;
  800c50:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c53:	c9                   	leave  
  800c54:	c3                   	ret    

00800c55 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c55:	55                   	push   %ebp
  800c56:	89 e5                	mov    %esp,%ebp
  800c58:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5e:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c61:	90                   	nop
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	8d 50 01             	lea    0x1(%eax),%edx
  800c68:	89 55 08             	mov    %edx,0x8(%ebp)
  800c6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c6e:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c71:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c74:	0f b6 12             	movzbl (%edx),%edx
  800c77:	88 10                	mov    %dl,(%eax)
  800c79:	0f b6 00             	movzbl (%eax),%eax
  800c7c:	84 c0                	test   %al,%al
  800c7e:	75 e2                	jne    800c62 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c80:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c83:	c9                   	leave  
  800c84:	c3                   	ret    

00800c85 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c85:	55                   	push   %ebp
  800c86:	89 e5                	mov    %esp,%ebp
  800c88:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8e:	89 04 24             	mov    %eax,(%esp)
  800c91:	e8 69 ff ff ff       	call   800bff <strlen>
  800c96:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c99:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c9c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c9f:	01 c2                	add    %eax,%edx
  800ca1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ca4:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca8:	89 14 24             	mov    %edx,(%esp)
  800cab:	e8 a5 ff ff ff       	call   800c55 <strcpy>
	return dst;
  800cb0:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800cb5:	55                   	push   %ebp
  800cb6:	89 e5                	mov    %esp,%ebp
  800cb8:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbe:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cc1:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cc8:	eb 23                	jmp    800ced <strncpy+0x38>
		*dst++ = *src;
  800cca:	8b 45 08             	mov    0x8(%ebp),%eax
  800ccd:	8d 50 01             	lea    0x1(%eax),%edx
  800cd0:	89 55 08             	mov    %edx,0x8(%ebp)
  800cd3:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd6:	0f b6 12             	movzbl (%edx),%edx
  800cd9:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cdb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cde:	0f b6 00             	movzbl (%eax),%eax
  800ce1:	84 c0                	test   %al,%al
  800ce3:	74 04                	je     800ce9 <strncpy+0x34>
			src++;
  800ce5:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ced:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cf0:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cf3:	72 d5                	jb     800cca <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cf5:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cf8:	c9                   	leave  
  800cf9:	c3                   	ret    

00800cfa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d00:	8b 45 08             	mov    0x8(%ebp),%eax
  800d03:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d06:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d0a:	74 33                	je     800d3f <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d0c:	eb 17                	jmp    800d25 <strlcpy+0x2b>
			*dst++ = *src++;
  800d0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800d11:	8d 50 01             	lea    0x1(%eax),%edx
  800d14:	89 55 08             	mov    %edx,0x8(%ebp)
  800d17:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d1a:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d1d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d20:	0f b6 12             	movzbl (%edx),%edx
  800d23:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d25:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d29:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d2d:	74 0a                	je     800d39 <strlcpy+0x3f>
  800d2f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d32:	0f b6 00             	movzbl (%eax),%eax
  800d35:	84 c0                	test   %al,%al
  800d37:	75 d5                	jne    800d0e <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d39:	8b 45 08             	mov    0x8(%ebp),%eax
  800d3c:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d3f:	8b 55 08             	mov    0x8(%ebp),%edx
  800d42:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d45:	29 c2                	sub    %eax,%edx
  800d47:	89 d0                	mov    %edx,%eax
}
  800d49:	c9                   	leave  
  800d4a:	c3                   	ret    

00800d4b <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d4b:	55                   	push   %ebp
  800d4c:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d4e:	eb 08                	jmp    800d58 <strcmp+0xd>
		p++, q++;
  800d50:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d54:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d58:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5b:	0f b6 00             	movzbl (%eax),%eax
  800d5e:	84 c0                	test   %al,%al
  800d60:	74 10                	je     800d72 <strcmp+0x27>
  800d62:	8b 45 08             	mov    0x8(%ebp),%eax
  800d65:	0f b6 10             	movzbl (%eax),%edx
  800d68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6b:	0f b6 00             	movzbl (%eax),%eax
  800d6e:	38 c2                	cmp    %al,%dl
  800d70:	74 de                	je     800d50 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d72:	8b 45 08             	mov    0x8(%ebp),%eax
  800d75:	0f b6 00             	movzbl (%eax),%eax
  800d78:	0f b6 d0             	movzbl %al,%edx
  800d7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d7e:	0f b6 00             	movzbl (%eax),%eax
  800d81:	0f b6 c0             	movzbl %al,%eax
  800d84:	29 c2                	sub    %eax,%edx
  800d86:	89 d0                	mov    %edx,%eax
}
  800d88:	5d                   	pop    %ebp
  800d89:	c3                   	ret    

00800d8a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d8a:	55                   	push   %ebp
  800d8b:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d8d:	eb 0c                	jmp    800d9b <strncmp+0x11>
		n--, p++, q++;
  800d8f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d93:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d97:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d9b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d9f:	74 1a                	je     800dbb <strncmp+0x31>
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	84 c0                	test   %al,%al
  800da9:	74 10                	je     800dbb <strncmp+0x31>
  800dab:	8b 45 08             	mov    0x8(%ebp),%eax
  800dae:	0f b6 10             	movzbl (%eax),%edx
  800db1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800db4:	0f b6 00             	movzbl (%eax),%eax
  800db7:	38 c2                	cmp    %al,%dl
  800db9:	74 d4                	je     800d8f <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dbb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dbf:	75 07                	jne    800dc8 <strncmp+0x3e>
		return 0;
  800dc1:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc6:	eb 16                	jmp    800dde <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc8:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcb:	0f b6 00             	movzbl (%eax),%eax
  800dce:	0f b6 d0             	movzbl %al,%edx
  800dd1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd4:	0f b6 00             	movzbl (%eax),%eax
  800dd7:	0f b6 c0             	movzbl %al,%eax
  800dda:	29 c2                	sub    %eax,%edx
  800ddc:	89 d0                	mov    %edx,%eax
}
  800dde:	5d                   	pop    %ebp
  800ddf:	c3                   	ret    

00800de0 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800de0:	55                   	push   %ebp
  800de1:	89 e5                	mov    %esp,%ebp
  800de3:	83 ec 04             	sub    $0x4,%esp
  800de6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de9:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dec:	eb 14                	jmp    800e02 <strchr+0x22>
		if (*s == c)
  800dee:	8b 45 08             	mov    0x8(%ebp),%eax
  800df1:	0f b6 00             	movzbl (%eax),%eax
  800df4:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df7:	75 05                	jne    800dfe <strchr+0x1e>
			return (char *) s;
  800df9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfc:	eb 13                	jmp    800e11 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dfe:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e02:	8b 45 08             	mov    0x8(%ebp),%eax
  800e05:	0f b6 00             	movzbl (%eax),%eax
  800e08:	84 c0                	test   %al,%al
  800e0a:	75 e2                	jne    800dee <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e0c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e11:	c9                   	leave  
  800e12:	c3                   	ret    

00800e13 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e13:	55                   	push   %ebp
  800e14:	89 e5                	mov    %esp,%ebp
  800e16:	83 ec 04             	sub    $0x4,%esp
  800e19:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e1c:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e1f:	eb 11                	jmp    800e32 <strfind+0x1f>
		if (*s == c)
  800e21:	8b 45 08             	mov    0x8(%ebp),%eax
  800e24:	0f b6 00             	movzbl (%eax),%eax
  800e27:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e2a:	75 02                	jne    800e2e <strfind+0x1b>
			break;
  800e2c:	eb 0e                	jmp    800e3c <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e2e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e32:	8b 45 08             	mov    0x8(%ebp),%eax
  800e35:	0f b6 00             	movzbl (%eax),%eax
  800e38:	84 c0                	test   %al,%al
  800e3a:	75 e5                	jne    800e21 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e3c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e3f:	c9                   	leave  
  800e40:	c3                   	ret    

00800e41 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e41:	55                   	push   %ebp
  800e42:	89 e5                	mov    %esp,%ebp
  800e44:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e49:	75 05                	jne    800e50 <memset+0xf>
		return v;
  800e4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4e:	eb 5c                	jmp    800eac <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	83 e0 03             	and    $0x3,%eax
  800e56:	85 c0                	test   %eax,%eax
  800e58:	75 41                	jne    800e9b <memset+0x5a>
  800e5a:	8b 45 10             	mov    0x10(%ebp),%eax
  800e5d:	83 e0 03             	and    $0x3,%eax
  800e60:	85 c0                	test   %eax,%eax
  800e62:	75 37                	jne    800e9b <memset+0x5a>
		c &= 0xFF;
  800e64:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e6b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6e:	c1 e0 18             	shl    $0x18,%eax
  800e71:	89 c2                	mov    %eax,%edx
  800e73:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e76:	c1 e0 10             	shl    $0x10,%eax
  800e79:	09 c2                	or     %eax,%edx
  800e7b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7e:	c1 e0 08             	shl    $0x8,%eax
  800e81:	09 d0                	or     %edx,%eax
  800e83:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e86:	8b 45 10             	mov    0x10(%ebp),%eax
  800e89:	c1 e8 02             	shr    $0x2,%eax
  800e8c:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e94:	89 d7                	mov    %edx,%edi
  800e96:	fc                   	cld    
  800e97:	f3 ab                	rep stos %eax,%es:(%edi)
  800e99:	eb 0e                	jmp    800ea9 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e9b:	8b 55 08             	mov    0x8(%ebp),%edx
  800e9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ea4:	89 d7                	mov    %edx,%edi
  800ea6:	fc                   	cld    
  800ea7:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ea9:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800eac:	5f                   	pop    %edi
  800ead:	5d                   	pop    %ebp
  800eae:	c3                   	ret    

00800eaf <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
  800eb2:	57                   	push   %edi
  800eb3:	56                   	push   %esi
  800eb4:	53                   	push   %ebx
  800eb5:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eb8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ebb:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ebe:	8b 45 08             	mov    0x8(%ebp),%eax
  800ec1:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ec4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eca:	73 6d                	jae    800f39 <memmove+0x8a>
  800ecc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecf:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ed2:	01 d0                	add    %edx,%eax
  800ed4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed7:	76 60                	jbe    800f39 <memmove+0x8a>
		s += n;
  800ed9:	8b 45 10             	mov    0x10(%ebp),%eax
  800edc:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800edf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee2:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ee5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee8:	83 e0 03             	and    $0x3,%eax
  800eeb:	85 c0                	test   %eax,%eax
  800eed:	75 2f                	jne    800f1e <memmove+0x6f>
  800eef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef2:	83 e0 03             	and    $0x3,%eax
  800ef5:	85 c0                	test   %eax,%eax
  800ef7:	75 25                	jne    800f1e <memmove+0x6f>
  800ef9:	8b 45 10             	mov    0x10(%ebp),%eax
  800efc:	83 e0 03             	and    $0x3,%eax
  800eff:	85 c0                	test   %eax,%eax
  800f01:	75 1b                	jne    800f1e <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f03:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f06:	83 e8 04             	sub    $0x4,%eax
  800f09:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f0c:	83 ea 04             	sub    $0x4,%edx
  800f0f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f12:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f15:	89 c7                	mov    %eax,%edi
  800f17:	89 d6                	mov    %edx,%esi
  800f19:	fd                   	std    
  800f1a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f1c:	eb 18                	jmp    800f36 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f21:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f24:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f27:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f2a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2d:	89 d7                	mov    %edx,%edi
  800f2f:	89 de                	mov    %ebx,%esi
  800f31:	89 c1                	mov    %eax,%ecx
  800f33:	fd                   	std    
  800f34:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f36:	fc                   	cld    
  800f37:	eb 45                	jmp    800f7e <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f39:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f3c:	83 e0 03             	and    $0x3,%eax
  800f3f:	85 c0                	test   %eax,%eax
  800f41:	75 2b                	jne    800f6e <memmove+0xbf>
  800f43:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f46:	83 e0 03             	and    $0x3,%eax
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	75 21                	jne    800f6e <memmove+0xbf>
  800f4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f50:	83 e0 03             	and    $0x3,%eax
  800f53:	85 c0                	test   %eax,%eax
  800f55:	75 17                	jne    800f6e <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f57:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5a:	c1 e8 02             	shr    $0x2,%eax
  800f5d:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f5f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f62:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f65:	89 c7                	mov    %eax,%edi
  800f67:	89 d6                	mov    %edx,%esi
  800f69:	fc                   	cld    
  800f6a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f6c:	eb 10                	jmp    800f7e <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f6e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f71:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f74:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f77:	89 c7                	mov    %eax,%edi
  800f79:	89 d6                	mov    %edx,%esi
  800f7b:	fc                   	cld    
  800f7c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f7e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	5b                   	pop    %ebx
  800f85:	5e                   	pop    %esi
  800f86:	5f                   	pop    %edi
  800f87:	5d                   	pop    %ebp
  800f88:	c3                   	ret    

00800f89 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800f92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f96:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa0:	89 04 24             	mov    %eax,(%esp)
  800fa3:	e8 07 ff ff ff       	call   800eaf <memmove>
}
  800fa8:	c9                   	leave  
  800fa9:	c3                   	ret    

00800faa <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fb0:	8b 45 08             	mov    0x8(%ebp),%eax
  800fb3:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fb6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb9:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fbc:	eb 30                	jmp    800fee <memcmp+0x44>
		if (*s1 != *s2)
  800fbe:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc1:	0f b6 10             	movzbl (%eax),%edx
  800fc4:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc7:	0f b6 00             	movzbl (%eax),%eax
  800fca:	38 c2                	cmp    %al,%dl
  800fcc:	74 18                	je     800fe6 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fce:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fd1:	0f b6 00             	movzbl (%eax),%eax
  800fd4:	0f b6 d0             	movzbl %al,%edx
  800fd7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fda:	0f b6 00             	movzbl (%eax),%eax
  800fdd:	0f b6 c0             	movzbl %al,%eax
  800fe0:	29 c2                	sub    %eax,%edx
  800fe2:	89 d0                	mov    %edx,%eax
  800fe4:	eb 1a                	jmp    801000 <memcmp+0x56>
		s1++, s2++;
  800fe6:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fea:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fee:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff1:	8d 50 ff             	lea    -0x1(%eax),%edx
  800ff4:	89 55 10             	mov    %edx,0x10(%ebp)
  800ff7:	85 c0                	test   %eax,%eax
  800ff9:	75 c3                	jne    800fbe <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ffb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801002:	55                   	push   %ebp
  801003:	89 e5                	mov    %esp,%ebp
  801005:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801008:	8b 45 10             	mov    0x10(%ebp),%eax
  80100b:	8b 55 08             	mov    0x8(%ebp),%edx
  80100e:	01 d0                	add    %edx,%eax
  801010:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801013:	eb 13                	jmp    801028 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801015:	8b 45 08             	mov    0x8(%ebp),%eax
  801018:	0f b6 10             	movzbl (%eax),%edx
  80101b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80101e:	38 c2                	cmp    %al,%dl
  801020:	75 02                	jne    801024 <memfind+0x22>
			break;
  801022:	eb 0c                	jmp    801030 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801024:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801028:	8b 45 08             	mov    0x8(%ebp),%eax
  80102b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80102e:	72 e5                	jb     801015 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801030:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801033:	c9                   	leave  
  801034:	c3                   	ret    

00801035 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801035:	55                   	push   %ebp
  801036:	89 e5                	mov    %esp,%ebp
  801038:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80103b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801042:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801049:	eb 04                	jmp    80104f <strtol+0x1a>
		s++;
  80104b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80104f:	8b 45 08             	mov    0x8(%ebp),%eax
  801052:	0f b6 00             	movzbl (%eax),%eax
  801055:	3c 20                	cmp    $0x20,%al
  801057:	74 f2                	je     80104b <strtol+0x16>
  801059:	8b 45 08             	mov    0x8(%ebp),%eax
  80105c:	0f b6 00             	movzbl (%eax),%eax
  80105f:	3c 09                	cmp    $0x9,%al
  801061:	74 e8                	je     80104b <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801063:	8b 45 08             	mov    0x8(%ebp),%eax
  801066:	0f b6 00             	movzbl (%eax),%eax
  801069:	3c 2b                	cmp    $0x2b,%al
  80106b:	75 06                	jne    801073 <strtol+0x3e>
		s++;
  80106d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801071:	eb 15                	jmp    801088 <strtol+0x53>
	else if (*s == '-')
  801073:	8b 45 08             	mov    0x8(%ebp),%eax
  801076:	0f b6 00             	movzbl (%eax),%eax
  801079:	3c 2d                	cmp    $0x2d,%al
  80107b:	75 0b                	jne    801088 <strtol+0x53>
		s++, neg = 1;
  80107d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801081:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801088:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80108c:	74 06                	je     801094 <strtol+0x5f>
  80108e:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801092:	75 24                	jne    8010b8 <strtol+0x83>
  801094:	8b 45 08             	mov    0x8(%ebp),%eax
  801097:	0f b6 00             	movzbl (%eax),%eax
  80109a:	3c 30                	cmp    $0x30,%al
  80109c:	75 1a                	jne    8010b8 <strtol+0x83>
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a1:	83 c0 01             	add    $0x1,%eax
  8010a4:	0f b6 00             	movzbl (%eax),%eax
  8010a7:	3c 78                	cmp    $0x78,%al
  8010a9:	75 0d                	jne    8010b8 <strtol+0x83>
		s += 2, base = 16;
  8010ab:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010af:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010b6:	eb 2a                	jmp    8010e2 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010b8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010bc:	75 17                	jne    8010d5 <strtol+0xa0>
  8010be:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c1:	0f b6 00             	movzbl (%eax),%eax
  8010c4:	3c 30                	cmp    $0x30,%al
  8010c6:	75 0d                	jne    8010d5 <strtol+0xa0>
		s++, base = 8;
  8010c8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010cc:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010d3:	eb 0d                	jmp    8010e2 <strtol+0xad>
	else if (base == 0)
  8010d5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010d9:	75 07                	jne    8010e2 <strtol+0xad>
		base = 10;
  8010db:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e5:	0f b6 00             	movzbl (%eax),%eax
  8010e8:	3c 2f                	cmp    $0x2f,%al
  8010ea:	7e 1b                	jle    801107 <strtol+0xd2>
  8010ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ef:	0f b6 00             	movzbl (%eax),%eax
  8010f2:	3c 39                	cmp    $0x39,%al
  8010f4:	7f 11                	jg     801107 <strtol+0xd2>
			dig = *s - '0';
  8010f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f9:	0f b6 00             	movzbl (%eax),%eax
  8010fc:	0f be c0             	movsbl %al,%eax
  8010ff:	83 e8 30             	sub    $0x30,%eax
  801102:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801105:	eb 48                	jmp    80114f <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801107:	8b 45 08             	mov    0x8(%ebp),%eax
  80110a:	0f b6 00             	movzbl (%eax),%eax
  80110d:	3c 60                	cmp    $0x60,%al
  80110f:	7e 1b                	jle    80112c <strtol+0xf7>
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	0f b6 00             	movzbl (%eax),%eax
  801117:	3c 7a                	cmp    $0x7a,%al
  801119:	7f 11                	jg     80112c <strtol+0xf7>
			dig = *s - 'a' + 10;
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	0f b6 00             	movzbl (%eax),%eax
  801121:	0f be c0             	movsbl %al,%eax
  801124:	83 e8 57             	sub    $0x57,%eax
  801127:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80112a:	eb 23                	jmp    80114f <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	0f b6 00             	movzbl (%eax),%eax
  801132:	3c 40                	cmp    $0x40,%al
  801134:	7e 3d                	jle    801173 <strtol+0x13e>
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	0f b6 00             	movzbl (%eax),%eax
  80113c:	3c 5a                	cmp    $0x5a,%al
  80113e:	7f 33                	jg     801173 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	0f b6 00             	movzbl (%eax),%eax
  801146:	0f be c0             	movsbl %al,%eax
  801149:	83 e8 37             	sub    $0x37,%eax
  80114c:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801152:	3b 45 10             	cmp    0x10(%ebp),%eax
  801155:	7c 02                	jl     801159 <strtol+0x124>
			break;
  801157:	eb 1a                	jmp    801173 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801159:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80115d:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801160:	0f af 45 10          	imul   0x10(%ebp),%eax
  801164:	89 c2                	mov    %eax,%edx
  801166:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801169:	01 d0                	add    %edx,%eax
  80116b:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80116e:	e9 6f ff ff ff       	jmp    8010e2 <strtol+0xad>

	if (endptr)
  801173:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801177:	74 08                	je     801181 <strtol+0x14c>
		*endptr = (char *) s;
  801179:	8b 45 0c             	mov    0xc(%ebp),%eax
  80117c:	8b 55 08             	mov    0x8(%ebp),%edx
  80117f:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801181:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801185:	74 07                	je     80118e <strtol+0x159>
  801187:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80118a:	f7 d8                	neg    %eax
  80118c:	eb 03                	jmp    801191 <strtol+0x15c>
  80118e:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801191:	c9                   	leave  
  801192:	c3                   	ret    
  801193:	66 90                	xchg   %ax,%ax
  801195:	66 90                	xchg   %ax,%ax
  801197:	66 90                	xchg   %ax,%ax
  801199:	66 90                	xchg   %ax,%ax
  80119b:	66 90                	xchg   %ax,%ax
  80119d:	66 90                	xchg   %ax,%ax
  80119f:	90                   	nop

008011a0 <__udivdi3>:
  8011a0:	55                   	push   %ebp
  8011a1:	57                   	push   %edi
  8011a2:	56                   	push   %esi
  8011a3:	83 ec 0c             	sub    $0xc,%esp
  8011a6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8011aa:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  8011ae:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011b2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011b6:	85 c0                	test   %eax,%eax
  8011b8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011bc:	89 ea                	mov    %ebp,%edx
  8011be:	89 0c 24             	mov    %ecx,(%esp)
  8011c1:	75 2d                	jne    8011f0 <__udivdi3+0x50>
  8011c3:	39 e9                	cmp    %ebp,%ecx
  8011c5:	77 61                	ja     801228 <__udivdi3+0x88>
  8011c7:	85 c9                	test   %ecx,%ecx
  8011c9:	89 ce                	mov    %ecx,%esi
  8011cb:	75 0b                	jne    8011d8 <__udivdi3+0x38>
  8011cd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011d2:	31 d2                	xor    %edx,%edx
  8011d4:	f7 f1                	div    %ecx
  8011d6:	89 c6                	mov    %eax,%esi
  8011d8:	31 d2                	xor    %edx,%edx
  8011da:	89 e8                	mov    %ebp,%eax
  8011dc:	f7 f6                	div    %esi
  8011de:	89 c5                	mov    %eax,%ebp
  8011e0:	89 f8                	mov    %edi,%eax
  8011e2:	f7 f6                	div    %esi
  8011e4:	89 ea                	mov    %ebp,%edx
  8011e6:	83 c4 0c             	add    $0xc,%esp
  8011e9:	5e                   	pop    %esi
  8011ea:	5f                   	pop    %edi
  8011eb:	5d                   	pop    %ebp
  8011ec:	c3                   	ret    
  8011ed:	8d 76 00             	lea    0x0(%esi),%esi
  8011f0:	39 e8                	cmp    %ebp,%eax
  8011f2:	77 24                	ja     801218 <__udivdi3+0x78>
  8011f4:	0f bd e8             	bsr    %eax,%ebp
  8011f7:	83 f5 1f             	xor    $0x1f,%ebp
  8011fa:	75 3c                	jne    801238 <__udivdi3+0x98>
  8011fc:	8b 74 24 04          	mov    0x4(%esp),%esi
  801200:	39 34 24             	cmp    %esi,(%esp)
  801203:	0f 86 9f 00 00 00    	jbe    8012a8 <__udivdi3+0x108>
  801209:	39 d0                	cmp    %edx,%eax
  80120b:	0f 82 97 00 00 00    	jb     8012a8 <__udivdi3+0x108>
  801211:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801218:	31 d2                	xor    %edx,%edx
  80121a:	31 c0                	xor    %eax,%eax
  80121c:	83 c4 0c             	add    $0xc,%esp
  80121f:	5e                   	pop    %esi
  801220:	5f                   	pop    %edi
  801221:	5d                   	pop    %ebp
  801222:	c3                   	ret    
  801223:	90                   	nop
  801224:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801228:	89 f8                	mov    %edi,%eax
  80122a:	f7 f1                	div    %ecx
  80122c:	31 d2                	xor    %edx,%edx
  80122e:	83 c4 0c             	add    $0xc,%esp
  801231:	5e                   	pop    %esi
  801232:	5f                   	pop    %edi
  801233:	5d                   	pop    %ebp
  801234:	c3                   	ret    
  801235:	8d 76 00             	lea    0x0(%esi),%esi
  801238:	89 e9                	mov    %ebp,%ecx
  80123a:	8b 3c 24             	mov    (%esp),%edi
  80123d:	d3 e0                	shl    %cl,%eax
  80123f:	89 c6                	mov    %eax,%esi
  801241:	b8 20 00 00 00       	mov    $0x20,%eax
  801246:	29 e8                	sub    %ebp,%eax
  801248:	89 c1                	mov    %eax,%ecx
  80124a:	d3 ef                	shr    %cl,%edi
  80124c:	89 e9                	mov    %ebp,%ecx
  80124e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801252:	8b 3c 24             	mov    (%esp),%edi
  801255:	09 74 24 08          	or     %esi,0x8(%esp)
  801259:	89 d6                	mov    %edx,%esi
  80125b:	d3 e7                	shl    %cl,%edi
  80125d:	89 c1                	mov    %eax,%ecx
  80125f:	89 3c 24             	mov    %edi,(%esp)
  801262:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801266:	d3 ee                	shr    %cl,%esi
  801268:	89 e9                	mov    %ebp,%ecx
  80126a:	d3 e2                	shl    %cl,%edx
  80126c:	89 c1                	mov    %eax,%ecx
  80126e:	d3 ef                	shr    %cl,%edi
  801270:	09 d7                	or     %edx,%edi
  801272:	89 f2                	mov    %esi,%edx
  801274:	89 f8                	mov    %edi,%eax
  801276:	f7 74 24 08          	divl   0x8(%esp)
  80127a:	89 d6                	mov    %edx,%esi
  80127c:	89 c7                	mov    %eax,%edi
  80127e:	f7 24 24             	mull   (%esp)
  801281:	39 d6                	cmp    %edx,%esi
  801283:	89 14 24             	mov    %edx,(%esp)
  801286:	72 30                	jb     8012b8 <__udivdi3+0x118>
  801288:	8b 54 24 04          	mov    0x4(%esp),%edx
  80128c:	89 e9                	mov    %ebp,%ecx
  80128e:	d3 e2                	shl    %cl,%edx
  801290:	39 c2                	cmp    %eax,%edx
  801292:	73 05                	jae    801299 <__udivdi3+0xf9>
  801294:	3b 34 24             	cmp    (%esp),%esi
  801297:	74 1f                	je     8012b8 <__udivdi3+0x118>
  801299:	89 f8                	mov    %edi,%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	e9 7a ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012a2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	b8 01 00 00 00       	mov    $0x1,%eax
  8012af:	e9 68 ff ff ff       	jmp    80121c <__udivdi3+0x7c>
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012bb:	31 d2                	xor    %edx,%edx
  8012bd:	83 c4 0c             	add    $0xc,%esp
  8012c0:	5e                   	pop    %esi
  8012c1:	5f                   	pop    %edi
  8012c2:	5d                   	pop    %ebp
  8012c3:	c3                   	ret    
  8012c4:	66 90                	xchg   %ax,%ax
  8012c6:	66 90                	xchg   %ax,%ax
  8012c8:	66 90                	xchg   %ax,%ax
  8012ca:	66 90                	xchg   %ax,%ax
  8012cc:	66 90                	xchg   %ax,%ax
  8012ce:	66 90                	xchg   %ax,%ax

008012d0 <__umoddi3>:
  8012d0:	55                   	push   %ebp
  8012d1:	57                   	push   %edi
  8012d2:	56                   	push   %esi
  8012d3:	83 ec 14             	sub    $0x14,%esp
  8012d6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012da:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012de:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012e2:	89 c7                	mov    %eax,%edi
  8012e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012e8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012ec:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012f0:	89 34 24             	mov    %esi,(%esp)
  8012f3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	89 c2                	mov    %eax,%edx
  8012fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ff:	75 17                	jne    801318 <__umoddi3+0x48>
  801301:	39 fe                	cmp    %edi,%esi
  801303:	76 4b                	jbe    801350 <__umoddi3+0x80>
  801305:	89 c8                	mov    %ecx,%eax
  801307:	89 fa                	mov    %edi,%edx
  801309:	f7 f6                	div    %esi
  80130b:	89 d0                	mov    %edx,%eax
  80130d:	31 d2                	xor    %edx,%edx
  80130f:	83 c4 14             	add    $0x14,%esp
  801312:	5e                   	pop    %esi
  801313:	5f                   	pop    %edi
  801314:	5d                   	pop    %ebp
  801315:	c3                   	ret    
  801316:	66 90                	xchg   %ax,%ax
  801318:	39 f8                	cmp    %edi,%eax
  80131a:	77 54                	ja     801370 <__umoddi3+0xa0>
  80131c:	0f bd e8             	bsr    %eax,%ebp
  80131f:	83 f5 1f             	xor    $0x1f,%ebp
  801322:	75 5c                	jne    801380 <__umoddi3+0xb0>
  801324:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801328:	39 3c 24             	cmp    %edi,(%esp)
  80132b:	0f 87 e7 00 00 00    	ja     801418 <__umoddi3+0x148>
  801331:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801335:	29 f1                	sub    %esi,%ecx
  801337:	19 c7                	sbb    %eax,%edi
  801339:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80133d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801341:	8b 44 24 08          	mov    0x8(%esp),%eax
  801345:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801349:	83 c4 14             	add    $0x14,%esp
  80134c:	5e                   	pop    %esi
  80134d:	5f                   	pop    %edi
  80134e:	5d                   	pop    %ebp
  80134f:	c3                   	ret    
  801350:	85 f6                	test   %esi,%esi
  801352:	89 f5                	mov    %esi,%ebp
  801354:	75 0b                	jne    801361 <__umoddi3+0x91>
  801356:	b8 01 00 00 00       	mov    $0x1,%eax
  80135b:	31 d2                	xor    %edx,%edx
  80135d:	f7 f6                	div    %esi
  80135f:	89 c5                	mov    %eax,%ebp
  801361:	8b 44 24 04          	mov    0x4(%esp),%eax
  801365:	31 d2                	xor    %edx,%edx
  801367:	f7 f5                	div    %ebp
  801369:	89 c8                	mov    %ecx,%eax
  80136b:	f7 f5                	div    %ebp
  80136d:	eb 9c                	jmp    80130b <__umoddi3+0x3b>
  80136f:	90                   	nop
  801370:	89 c8                	mov    %ecx,%eax
  801372:	89 fa                	mov    %edi,%edx
  801374:	83 c4 14             	add    $0x14,%esp
  801377:	5e                   	pop    %esi
  801378:	5f                   	pop    %edi
  801379:	5d                   	pop    %ebp
  80137a:	c3                   	ret    
  80137b:	90                   	nop
  80137c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801380:	8b 04 24             	mov    (%esp),%eax
  801383:	be 20 00 00 00       	mov    $0x20,%esi
  801388:	89 e9                	mov    %ebp,%ecx
  80138a:	29 ee                	sub    %ebp,%esi
  80138c:	d3 e2                	shl    %cl,%edx
  80138e:	89 f1                	mov    %esi,%ecx
  801390:	d3 e8                	shr    %cl,%eax
  801392:	89 e9                	mov    %ebp,%ecx
  801394:	89 44 24 04          	mov    %eax,0x4(%esp)
  801398:	8b 04 24             	mov    (%esp),%eax
  80139b:	09 54 24 04          	or     %edx,0x4(%esp)
  80139f:	89 fa                	mov    %edi,%edx
  8013a1:	d3 e0                	shl    %cl,%eax
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8013a9:	8b 44 24 10          	mov    0x10(%esp),%eax
  8013ad:	d3 ea                	shr    %cl,%edx
  8013af:	89 e9                	mov    %ebp,%ecx
  8013b1:	d3 e7                	shl    %cl,%edi
  8013b3:	89 f1                	mov    %esi,%ecx
  8013b5:	d3 e8                	shr    %cl,%eax
  8013b7:	89 e9                	mov    %ebp,%ecx
  8013b9:	09 f8                	or     %edi,%eax
  8013bb:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013bf:	f7 74 24 04          	divl   0x4(%esp)
  8013c3:	d3 e7                	shl    %cl,%edi
  8013c5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013c9:	89 d7                	mov    %edx,%edi
  8013cb:	f7 64 24 08          	mull   0x8(%esp)
  8013cf:	39 d7                	cmp    %edx,%edi
  8013d1:	89 c1                	mov    %eax,%ecx
  8013d3:	89 14 24             	mov    %edx,(%esp)
  8013d6:	72 2c                	jb     801404 <__umoddi3+0x134>
  8013d8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013dc:	72 22                	jb     801400 <__umoddi3+0x130>
  8013de:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013e2:	29 c8                	sub    %ecx,%eax
  8013e4:	19 d7                	sbb    %edx,%edi
  8013e6:	89 e9                	mov    %ebp,%ecx
  8013e8:	89 fa                	mov    %edi,%edx
  8013ea:	d3 e8                	shr    %cl,%eax
  8013ec:	89 f1                	mov    %esi,%ecx
  8013ee:	d3 e2                	shl    %cl,%edx
  8013f0:	89 e9                	mov    %ebp,%ecx
  8013f2:	d3 ef                	shr    %cl,%edi
  8013f4:	09 d0                	or     %edx,%eax
  8013f6:	89 fa                	mov    %edi,%edx
  8013f8:	83 c4 14             	add    $0x14,%esp
  8013fb:	5e                   	pop    %esi
  8013fc:	5f                   	pop    %edi
  8013fd:	5d                   	pop    %ebp
  8013fe:	c3                   	ret    
  8013ff:	90                   	nop
  801400:	39 d7                	cmp    %edx,%edi
  801402:	75 da                	jne    8013de <__umoddi3+0x10e>
  801404:	8b 14 24             	mov    (%esp),%edx
  801407:	89 c1                	mov    %eax,%ecx
  801409:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80140d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801411:	eb cb                	jmp    8013de <__umoddi3+0x10e>
  801413:	90                   	nop
  801414:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801418:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80141c:	0f 82 0f ff ff ff    	jb     801331 <__umoddi3+0x61>
  801422:	e9 1a ff ff ff       	jmp    801341 <__umoddi3+0x71>
