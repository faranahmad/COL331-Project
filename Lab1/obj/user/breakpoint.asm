
obj/user/breakpoint:     file format elf32-i386


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
  80002c:	e8 08 00 00 00       	call   800039 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	asm volatile("int $3");
  800036:	cc                   	int3   
}
  800037:	5d                   	pop    %ebp
  800038:	c3                   	ret    

00800039 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  80003f:	e8 81 01 00 00       	call   8001c5 <sys_getenvid>
  800044:	25 ff 03 00 00       	and    $0x3ff,%eax
  800049:	c1 e0 02             	shl    $0x2,%eax
  80004c:	89 c2                	mov    %eax,%edx
  80004e:	c1 e2 05             	shl    $0x5,%edx
  800051:	29 c2                	sub    %eax,%edx
  800053:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800059:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80005e:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800062:	7e 0a                	jle    80006e <libmain+0x35>
		binaryname = argv[0];
  800064:	8b 45 0c             	mov    0xc(%ebp),%eax
  800067:	8b 00                	mov    (%eax),%eax
  800069:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80006e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800071:	89 44 24 04          	mov    %eax,0x4(%esp)
  800075:	8b 45 08             	mov    0x8(%ebp),%eax
  800078:	89 04 24             	mov    %eax,(%esp)
  80007b:	e8 b3 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800080:	e8 02 00 00 00       	call   800087 <exit>
}
  800085:	c9                   	leave  
  800086:	c3                   	ret    

00800087 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800087:	55                   	push   %ebp
  800088:	89 e5                	mov    %esp,%ebp
  80008a:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80008d:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800094:	e8 e9 00 00 00       	call   800182 <sys_env_destroy>
}
  800099:	c9                   	leave  
  80009a:	c3                   	ret    

0080009b <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80009b:	55                   	push   %ebp
  80009c:	89 e5                	mov    %esp,%ebp
  80009e:	57                   	push   %edi
  80009f:	56                   	push   %esi
  8000a0:	53                   	push   %ebx
  8000a1:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8000a7:	8b 55 10             	mov    0x10(%ebp),%edx
  8000aa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000ad:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b0:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000b3:	8b 75 20             	mov    0x20(%ebp),%esi
  8000b6:	cd 30                	int    $0x30
  8000b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000bb:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000bf:	74 30                	je     8000f1 <syscall+0x56>
  8000c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c5:	7e 2a                	jle    8000f1 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000c7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000ca:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000d5:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8000dc:	00 
  8000dd:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e4:	00 
  8000e5:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000ec:	e8 2c 03 00 00       	call   80041d <_panic>

	return ret;
  8000f1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000f4:	83 c4 3c             	add    $0x3c,%esp
  8000f7:	5b                   	pop    %ebx
  8000f8:	5e                   	pop    %esi
  8000f9:	5f                   	pop    %edi
  8000fa:	5d                   	pop    %ebp
  8000fb:	c3                   	ret    

008000fc <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000fc:	55                   	push   %ebp
  8000fd:	89 e5                	mov    %esp,%ebp
  8000ff:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800102:	8b 45 08             	mov    0x8(%ebp),%eax
  800105:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80010c:	00 
  80010d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800114:	00 
  800115:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80011c:	00 
  80011d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800120:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800124:	89 44 24 08          	mov    %eax,0x8(%esp)
  800128:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80012f:	00 
  800130:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800137:	e8 5f ff ff ff       	call   80009b <syscall>
}
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <sys_cgetc>:

int
sys_cgetc(void)
{
  80013e:	55                   	push   %ebp
  80013f:	89 e5                	mov    %esp,%ebp
  800141:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800144:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80014b:	00 
  80014c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800153:	00 
  800154:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80015b:	00 
  80015c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800163:	00 
  800164:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80016b:	00 
  80016c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800173:	00 
  800174:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80017b:	e8 1b ff ff ff       	call   80009b <syscall>
}
  800180:	c9                   	leave  
  800181:	c3                   	ret    

00800182 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800182:	55                   	push   %ebp
  800183:	89 e5                	mov    %esp,%ebp
  800185:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800188:	8b 45 08             	mov    0x8(%ebp),%eax
  80018b:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800192:	00 
  800193:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80019a:	00 
  80019b:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001a2:	00 
  8001a3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001aa:	00 
  8001ab:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001af:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001b6:	00 
  8001b7:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001be:	e8 d8 fe ff ff       	call   80009b <syscall>
}
  8001c3:	c9                   	leave  
  8001c4:	c3                   	ret    

008001c5 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001c5:	55                   	push   %ebp
  8001c6:	89 e5                	mov    %esp,%ebp
  8001c8:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001cb:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d2:	00 
  8001d3:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001da:	00 
  8001db:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e2:	00 
  8001e3:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ea:	00 
  8001eb:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f2:	00 
  8001f3:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001fa:	00 
  8001fb:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800202:	e8 94 fe ff ff       	call   80009b <syscall>
}
  800207:	c9                   	leave  
  800208:	c3                   	ret    

00800209 <sys_yield>:

void
sys_yield(void)
{
  800209:	55                   	push   %ebp
  80020a:	89 e5                	mov    %esp,%ebp
  80020c:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80020f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800216:	00 
  800217:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80021e:	00 
  80021f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800226:	00 
  800227:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80022e:	00 
  80022f:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800236:	00 
  800237:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80023e:	00 
  80023f:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800246:	e8 50 fe ff ff       	call   80009b <syscall>
}
  80024b:	c9                   	leave  
  80024c:	c3                   	ret    

0080024d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80024d:	55                   	push   %ebp
  80024e:	89 e5                	mov    %esp,%ebp
  800250:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800253:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800256:	8b 55 0c             	mov    0xc(%ebp),%edx
  800259:	8b 45 08             	mov    0x8(%ebp),%eax
  80025c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800263:	00 
  800264:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80026b:	00 
  80026c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800270:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800274:	89 44 24 08          	mov    %eax,0x8(%esp)
  800278:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80027f:	00 
  800280:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800287:	e8 0f fe ff ff       	call   80009b <syscall>
}
  80028c:	c9                   	leave  
  80028d:	c3                   	ret    

0080028e <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80028e:	55                   	push   %ebp
  80028f:	89 e5                	mov    %esp,%ebp
  800291:	56                   	push   %esi
  800292:	53                   	push   %ebx
  800293:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800296:	8b 75 18             	mov    0x18(%ebp),%esi
  800299:	8b 5d 14             	mov    0x14(%ebp),%ebx
  80029c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80029f:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002a5:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002a9:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ad:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c0:	00 
  8002c1:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002c8:	e8 ce fd ff ff       	call   80009b <syscall>
}
  8002cd:	83 c4 20             	add    $0x20,%esp
  8002d0:	5b                   	pop    %ebx
  8002d1:	5e                   	pop    %esi
  8002d2:	5d                   	pop    %ebp
  8002d3:	c3                   	ret    

008002d4 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002e7:	00 
  8002e8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002ef:	00 
  8002f0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002f7:	00 
  8002f8:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002fc:	89 44 24 08          	mov    %eax,0x8(%esp)
  800300:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800307:	00 
  800308:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  80030f:	e8 87 fd ff ff       	call   80009b <syscall>
}
  800314:	c9                   	leave  
  800315:	c3                   	ret    

00800316 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800316:	55                   	push   %ebp
  800317:	89 e5                	mov    %esp,%ebp
  800319:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80031c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80031f:	8b 45 08             	mov    0x8(%ebp),%eax
  800322:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800329:	00 
  80032a:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800331:	00 
  800332:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800339:	00 
  80033a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80033e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800342:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800349:	00 
  80034a:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800351:	e8 45 fd ff ff       	call   80009b <syscall>
}
  800356:	c9                   	leave  
  800357:	c3                   	ret    

00800358 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800358:	55                   	push   %ebp
  800359:	89 e5                	mov    %esp,%ebp
  80035b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80035e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800361:	8b 45 08             	mov    0x8(%ebp),%eax
  800364:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80036b:	00 
  80036c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800373:	00 
  800374:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80037b:	00 
  80037c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800380:	89 44 24 08          	mov    %eax,0x8(%esp)
  800384:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80038b:	00 
  80038c:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800393:	e8 03 fd ff ff       	call   80009b <syscall>
}
  800398:	c9                   	leave  
  800399:	c3                   	ret    

0080039a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039a:	55                   	push   %ebp
  80039b:	89 e5                	mov    %esp,%ebp
  80039d:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a0:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003a3:	8b 55 10             	mov    0x10(%ebp),%edx
  8003a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003a9:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b0:	00 
  8003b1:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003b5:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003bc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c4:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003cb:	00 
  8003cc:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003d3:	e8 c3 fc ff ff       	call   80009b <syscall>
}
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ea:	00 
  8003eb:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003f2:	00 
  8003f3:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003fa:	00 
  8003fb:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800402:	00 
  800403:	89 44 24 08          	mov    %eax,0x8(%esp)
  800407:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80040e:	00 
  80040f:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800416:	e8 80 fc ff ff       	call   80009b <syscall>
}
  80041b:	c9                   	leave  
  80041c:	c3                   	ret    

0080041d <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80041d:	55                   	push   %ebp
  80041e:	89 e5                	mov    %esp,%ebp
  800420:	53                   	push   %ebx
  800421:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800424:	8d 45 14             	lea    0x14(%ebp),%eax
  800427:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042a:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800430:	e8 90 fd ff ff       	call   8001c5 <sys_getenvid>
  800435:	8b 55 0c             	mov    0xc(%ebp),%edx
  800438:	89 54 24 10          	mov    %edx,0x10(%esp)
  80043c:	8b 55 08             	mov    0x8(%ebp),%edx
  80043f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800443:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800447:	89 44 24 04          	mov    %eax,0x4(%esp)
  80044b:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  800452:	e8 e1 00 00 00       	call   800538 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800457:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80045a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045e:	8b 45 10             	mov    0x10(%ebp),%eax
  800461:	89 04 24             	mov    %eax,(%esp)
  800464:	e8 6b 00 00 00       	call   8004d4 <vcprintf>
	cprintf("\n");
  800469:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  800470:	e8 c3 00 00 00       	call   800538 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800475:	cc                   	int3   
  800476:	eb fd                	jmp    800475 <_panic+0x58>

00800478 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800478:	55                   	push   %ebp
  800479:	89 e5                	mov    %esp,%ebp
  80047b:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	8b 00                	mov    (%eax),%eax
  800483:	8d 48 01             	lea    0x1(%eax),%ecx
  800486:	8b 55 0c             	mov    0xc(%ebp),%edx
  800489:	89 0a                	mov    %ecx,(%edx)
  80048b:	8b 55 08             	mov    0x8(%ebp),%edx
  80048e:	89 d1                	mov    %edx,%ecx
  800490:	8b 55 0c             	mov    0xc(%ebp),%edx
  800493:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  800497:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049a:	8b 00                	mov    (%eax),%eax
  80049c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a1:	75 20                	jne    8004c3 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a6:	8b 00                	mov    (%eax),%eax
  8004a8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004ab:	83 c2 08             	add    $0x8,%edx
  8004ae:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b2:	89 14 24             	mov    %edx,(%esp)
  8004b5:	e8 42 fc ff ff       	call   8000fc <sys_cputs>
		b->idx = 0;
  8004ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004bd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004c3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c6:	8b 40 04             	mov    0x4(%eax),%eax
  8004c9:	8d 50 01             	lea    0x1(%eax),%edx
  8004cc:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cf:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004d2:	c9                   	leave  
  8004d3:	c3                   	ret    

008004d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d4:	55                   	push   %ebp
  8004d5:	89 e5                	mov    %esp,%ebp
  8004d7:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e4:	00 00 00 
	b.cnt = 0;
  8004e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8004fb:	89 44 24 08          	mov    %eax,0x8(%esp)
  8004ff:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800505:	89 44 24 04          	mov    %eax,0x4(%esp)
  800509:	c7 04 24 78 04 80 00 	movl   $0x800478,(%esp)
  800510:	e8 bd 01 00 00       	call   8006d2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800515:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80051b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800525:	83 c0 08             	add    $0x8,%eax
  800528:	89 04 24             	mov    %eax,(%esp)
  80052b:	e8 cc fb ff ff       	call   8000fc <sys_cputs>

	return b.cnt;
  800530:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800536:	c9                   	leave  
  800537:	c3                   	ret    

00800538 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80053e:	8d 45 0c             	lea    0xc(%ebp),%eax
  800541:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800544:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800547:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054b:	8b 45 08             	mov    0x8(%ebp),%eax
  80054e:	89 04 24             	mov    %eax,(%esp)
  800551:	e8 7e ff ff ff       	call   8004d4 <vcprintf>
  800556:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800559:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80055c:	c9                   	leave  
  80055d:	c3                   	ret    

0080055e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80055e:	55                   	push   %ebp
  80055f:	89 e5                	mov    %esp,%ebp
  800561:	53                   	push   %ebx
  800562:	83 ec 34             	sub    $0x34,%esp
  800565:	8b 45 10             	mov    0x10(%ebp),%eax
  800568:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80056b:	8b 45 14             	mov    0x14(%ebp),%eax
  80056e:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800571:	8b 45 18             	mov    0x18(%ebp),%eax
  800574:	ba 00 00 00 00       	mov    $0x0,%edx
  800579:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80057c:	77 72                	ja     8005f0 <printnum+0x92>
  80057e:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800581:	72 05                	jb     800588 <printnum+0x2a>
  800583:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800586:	77 68                	ja     8005f0 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800588:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80058b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80058e:	8b 45 18             	mov    0x18(%ebp),%eax
  800591:	ba 00 00 00 00       	mov    $0x0,%edx
  800596:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80059e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a1:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a4:	89 04 24             	mov    %eax,(%esp)
  8005a7:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005ab:	e8 d0 0b 00 00       	call   801180 <__udivdi3>
  8005b0:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005b3:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005b7:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005bb:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005be:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005c2:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005ca:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005cd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d4:	89 04 24             	mov    %eax,(%esp)
  8005d7:	e8 82 ff ff ff       	call   80055e <printnum>
  8005dc:	eb 1c                	jmp    8005fa <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005de:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e5:	8b 45 20             	mov    0x20(%ebp),%eax
  8005e8:	89 04 24             	mov    %eax,(%esp)
  8005eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ee:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f0:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005f4:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8005f8:	7f e4                	jg     8005de <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005fa:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005fd:	bb 00 00 00 00       	mov    $0x0,%ebx
  800602:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800605:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800608:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80060c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800610:	89 04 24             	mov    %eax,(%esp)
  800613:	89 54 24 04          	mov    %edx,0x4(%esp)
  800617:	e8 94 0c 00 00       	call   8012b0 <__umoddi3>
  80061c:	05 48 15 80 00       	add    $0x801548,%eax
  800621:	0f b6 00             	movzbl (%eax),%eax
  800624:	0f be c0             	movsbl %al,%eax
  800627:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062a:	89 54 24 04          	mov    %edx,0x4(%esp)
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  800634:	ff d0                	call   *%eax
}
  800636:	83 c4 34             	add    $0x34,%esp
  800639:	5b                   	pop    %ebx
  80063a:	5d                   	pop    %ebp
  80063b:	c3                   	ret    

0080063c <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80063c:	55                   	push   %ebp
  80063d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80063f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800643:	7e 14                	jle    800659 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800645:	8b 45 08             	mov    0x8(%ebp),%eax
  800648:	8b 00                	mov    (%eax),%eax
  80064a:	8d 48 08             	lea    0x8(%eax),%ecx
  80064d:	8b 55 08             	mov    0x8(%ebp),%edx
  800650:	89 0a                	mov    %ecx,(%edx)
  800652:	8b 50 04             	mov    0x4(%eax),%edx
  800655:	8b 00                	mov    (%eax),%eax
  800657:	eb 30                	jmp    800689 <getuint+0x4d>
	else if (lflag)
  800659:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80065d:	74 16                	je     800675 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  80065f:	8b 45 08             	mov    0x8(%ebp),%eax
  800662:	8b 00                	mov    (%eax),%eax
  800664:	8d 48 04             	lea    0x4(%eax),%ecx
  800667:	8b 55 08             	mov    0x8(%ebp),%edx
  80066a:	89 0a                	mov    %ecx,(%edx)
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	ba 00 00 00 00       	mov    $0x0,%edx
  800673:	eb 14                	jmp    800689 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800675:	8b 45 08             	mov    0x8(%ebp),%eax
  800678:	8b 00                	mov    (%eax),%eax
  80067a:	8d 48 04             	lea    0x4(%eax),%ecx
  80067d:	8b 55 08             	mov    0x8(%ebp),%edx
  800680:	89 0a                	mov    %ecx,(%edx)
  800682:	8b 00                	mov    (%eax),%eax
  800684:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800689:	5d                   	pop    %ebp
  80068a:	c3                   	ret    

0080068b <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80068b:	55                   	push   %ebp
  80068c:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80068e:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800692:	7e 14                	jle    8006a8 <getint+0x1d>
		return va_arg(*ap, long long);
  800694:	8b 45 08             	mov    0x8(%ebp),%eax
  800697:	8b 00                	mov    (%eax),%eax
  800699:	8d 48 08             	lea    0x8(%eax),%ecx
  80069c:	8b 55 08             	mov    0x8(%ebp),%edx
  80069f:	89 0a                	mov    %ecx,(%edx)
  8006a1:	8b 50 04             	mov    0x4(%eax),%edx
  8006a4:	8b 00                	mov    (%eax),%eax
  8006a6:	eb 28                	jmp    8006d0 <getint+0x45>
	else if (lflag)
  8006a8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006ac:	74 12                	je     8006c0 <getint+0x35>
		return va_arg(*ap, long);
  8006ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b1:	8b 00                	mov    (%eax),%eax
  8006b3:	8d 48 04             	lea    0x4(%eax),%ecx
  8006b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b9:	89 0a                	mov    %ecx,(%edx)
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	99                   	cltd   
  8006be:	eb 10                	jmp    8006d0 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c3:	8b 00                	mov    (%eax),%eax
  8006c5:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c8:	8b 55 08             	mov    0x8(%ebp),%edx
  8006cb:	89 0a                	mov    %ecx,(%edx)
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	99                   	cltd   
}
  8006d0:	5d                   	pop    %ebp
  8006d1:	c3                   	ret    

008006d2 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d2:	55                   	push   %ebp
  8006d3:	89 e5                	mov    %esp,%ebp
  8006d5:	56                   	push   %esi
  8006d6:	53                   	push   %ebx
  8006d7:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006da:	eb 18                	jmp    8006f4 <vprintfmt+0x22>
			if (ch == '\0')
  8006dc:	85 db                	test   %ebx,%ebx
  8006de:	75 05                	jne    8006e5 <vprintfmt+0x13>
				return;
  8006e0:	e9 05 04 00 00       	jmp    800aea <vprintfmt+0x418>
			putch(ch, putdat);
  8006e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006ec:	89 1c 24             	mov    %ebx,(%esp)
  8006ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f2:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f4:	8b 45 10             	mov    0x10(%ebp),%eax
  8006f7:	8d 50 01             	lea    0x1(%eax),%edx
  8006fa:	89 55 10             	mov    %edx,0x10(%ebp)
  8006fd:	0f b6 00             	movzbl (%eax),%eax
  800700:	0f b6 d8             	movzbl %al,%ebx
  800703:	83 fb 25             	cmp    $0x25,%ebx
  800706:	75 d4                	jne    8006dc <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800708:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80070c:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800713:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80071a:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800721:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800728:	8b 45 10             	mov    0x10(%ebp),%eax
  80072b:	8d 50 01             	lea    0x1(%eax),%edx
  80072e:	89 55 10             	mov    %edx,0x10(%ebp)
  800731:	0f b6 00             	movzbl (%eax),%eax
  800734:	0f b6 d8             	movzbl %al,%ebx
  800737:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80073a:	83 f8 55             	cmp    $0x55,%eax
  80073d:	0f 87 76 03 00 00    	ja     800ab9 <vprintfmt+0x3e7>
  800743:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  80074a:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80074c:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800750:	eb d6                	jmp    800728 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800752:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800756:	eb d0                	jmp    800728 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800758:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  80075f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800762:	89 d0                	mov    %edx,%eax
  800764:	c1 e0 02             	shl    $0x2,%eax
  800767:	01 d0                	add    %edx,%eax
  800769:	01 c0                	add    %eax,%eax
  80076b:	01 d8                	add    %ebx,%eax
  80076d:	83 e8 30             	sub    $0x30,%eax
  800770:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800773:	8b 45 10             	mov    0x10(%ebp),%eax
  800776:	0f b6 00             	movzbl (%eax),%eax
  800779:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80077c:	83 fb 2f             	cmp    $0x2f,%ebx
  80077f:	7e 0b                	jle    80078c <vprintfmt+0xba>
  800781:	83 fb 39             	cmp    $0x39,%ebx
  800784:	7f 06                	jg     80078c <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800786:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078a:	eb d3                	jmp    80075f <vprintfmt+0x8d>
			goto process_precision;
  80078c:	eb 33                	jmp    8007c1 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80078e:	8b 45 14             	mov    0x14(%ebp),%eax
  800791:	8d 50 04             	lea    0x4(%eax),%edx
  800794:	89 55 14             	mov    %edx,0x14(%ebp)
  800797:	8b 00                	mov    (%eax),%eax
  800799:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  80079c:	eb 23                	jmp    8007c1 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  80079e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a2:	79 0c                	jns    8007b0 <vprintfmt+0xde>
				width = 0;
  8007a4:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007ab:	e9 78 ff ff ff       	jmp    800728 <vprintfmt+0x56>
  8007b0:	e9 73 ff ff ff       	jmp    800728 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007b5:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007bc:	e9 67 ff ff ff       	jmp    800728 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007c1:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007c5:	79 12                	jns    8007d9 <vprintfmt+0x107>
				width = precision, precision = -1;
  8007c7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007ca:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007cd:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007d4:	e9 4f ff ff ff       	jmp    800728 <vprintfmt+0x56>
  8007d9:	e9 4a ff ff ff       	jmp    800728 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007de:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007e2:	e9 41 ff ff ff       	jmp    800728 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ea:	8d 50 04             	lea    0x4(%eax),%edx
  8007ed:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f0:	8b 00                	mov    (%eax),%eax
  8007f2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007f5:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007f9:	89 04 24             	mov    %eax,(%esp)
  8007fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ff:	ff d0                	call   *%eax
			break;
  800801:	e9 de 02 00 00       	jmp    800ae4 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800806:	8b 45 14             	mov    0x14(%ebp),%eax
  800809:	8d 50 04             	lea    0x4(%eax),%edx
  80080c:	89 55 14             	mov    %edx,0x14(%ebp)
  80080f:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800811:	85 db                	test   %ebx,%ebx
  800813:	79 02                	jns    800817 <vprintfmt+0x145>
				err = -err;
  800815:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800817:	83 fb 09             	cmp    $0x9,%ebx
  80081a:	7f 0b                	jg     800827 <vprintfmt+0x155>
  80081c:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800823:	85 f6                	test   %esi,%esi
  800825:	75 23                	jne    80084a <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800827:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80082b:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  800832:	00 
  800833:	8b 45 0c             	mov    0xc(%ebp),%eax
  800836:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083a:	8b 45 08             	mov    0x8(%ebp),%eax
  80083d:	89 04 24             	mov    %eax,(%esp)
  800840:	e8 ac 02 00 00       	call   800af1 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800845:	e9 9a 02 00 00       	jmp    800ae4 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80084a:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80084e:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  800855:	00 
  800856:	8b 45 0c             	mov    0xc(%ebp),%eax
  800859:	89 44 24 04          	mov    %eax,0x4(%esp)
  80085d:	8b 45 08             	mov    0x8(%ebp),%eax
  800860:	89 04 24             	mov    %eax,(%esp)
  800863:	e8 89 02 00 00       	call   800af1 <printfmt>
			break;
  800868:	e9 77 02 00 00       	jmp    800ae4 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80086d:	8b 45 14             	mov    0x14(%ebp),%eax
  800870:	8d 50 04             	lea    0x4(%eax),%edx
  800873:	89 55 14             	mov    %edx,0x14(%ebp)
  800876:	8b 30                	mov    (%eax),%esi
  800878:	85 f6                	test   %esi,%esi
  80087a:	75 05                	jne    800881 <vprintfmt+0x1af>
				p = "(null)";
  80087c:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  800881:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800885:	7e 37                	jle    8008be <vprintfmt+0x1ec>
  800887:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80088b:	74 31                	je     8008be <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80088d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800890:	89 44 24 04          	mov    %eax,0x4(%esp)
  800894:	89 34 24             	mov    %esi,(%esp)
  800897:	e8 72 03 00 00       	call   800c0e <strnlen>
  80089c:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  80089f:	eb 17                	jmp    8008b8 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008a1:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008a5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008a8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008ac:	89 04 24             	mov    %eax,(%esp)
  8008af:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b2:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008b8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008bc:	7f e3                	jg     8008a1 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008be:	eb 38                	jmp    8008f8 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008c0:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c4:	74 1f                	je     8008e5 <vprintfmt+0x213>
  8008c6:	83 fb 1f             	cmp    $0x1f,%ebx
  8008c9:	7e 05                	jle    8008d0 <vprintfmt+0x1fe>
  8008cb:	83 fb 7e             	cmp    $0x7e,%ebx
  8008ce:	7e 15                	jle    8008e5 <vprintfmt+0x213>
					putch('?', putdat);
  8008d0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008d7:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008de:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e1:	ff d0                	call   *%eax
  8008e3:	eb 0f                	jmp    8008f4 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008e5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008ec:	89 1c 24             	mov    %ebx,(%esp)
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f4:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008f8:	89 f0                	mov    %esi,%eax
  8008fa:	8d 70 01             	lea    0x1(%eax),%esi
  8008fd:	0f b6 00             	movzbl (%eax),%eax
  800900:	0f be d8             	movsbl %al,%ebx
  800903:	85 db                	test   %ebx,%ebx
  800905:	74 10                	je     800917 <vprintfmt+0x245>
  800907:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80090b:	78 b3                	js     8008c0 <vprintfmt+0x1ee>
  80090d:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800911:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800915:	79 a9                	jns    8008c0 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800917:	eb 17                	jmp    800930 <vprintfmt+0x25e>
				putch(' ', putdat);
  800919:	8b 45 0c             	mov    0xc(%ebp),%eax
  80091c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800920:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800927:	8b 45 08             	mov    0x8(%ebp),%eax
  80092a:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80092c:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800930:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800934:	7f e3                	jg     800919 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800936:	e9 a9 01 00 00       	jmp    800ae4 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80093b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80093e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800942:	8d 45 14             	lea    0x14(%ebp),%eax
  800945:	89 04 24             	mov    %eax,(%esp)
  800948:	e8 3e fd ff ff       	call   80068b <getint>
  80094d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800950:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800953:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800956:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800959:	85 d2                	test   %edx,%edx
  80095b:	79 26                	jns    800983 <vprintfmt+0x2b1>
				putch('-', putdat);
  80095d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800960:	89 44 24 04          	mov    %eax,0x4(%esp)
  800964:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80096b:	8b 45 08             	mov    0x8(%ebp),%eax
  80096e:	ff d0                	call   *%eax
				num = -(long long) num;
  800970:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800973:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800976:	f7 d8                	neg    %eax
  800978:	83 d2 00             	adc    $0x0,%edx
  80097b:	f7 da                	neg    %edx
  80097d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800980:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800983:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80098a:	e9 e1 00 00 00       	jmp    800a70 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80098f:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800992:	89 44 24 04          	mov    %eax,0x4(%esp)
  800996:	8d 45 14             	lea    0x14(%ebp),%eax
  800999:	89 04 24             	mov    %eax,(%esp)
  80099c:	e8 9b fc ff ff       	call   80063c <getuint>
  8009a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009a4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009a7:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009ae:	e9 bd 00 00 00       	jmp    800a70 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009b3:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009ba:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009bd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c4:	89 04 24             	mov    %eax,(%esp)
  8009c7:	e8 70 fc ff ff       	call   80063c <getuint>
  8009cc:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8009d2:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8009d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009d9:	89 54 24 18          	mov    %edx,0x18(%esp)
  8009dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e0:	89 54 24 14          	mov    %edx,0x14(%esp)
  8009e4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009eb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ee:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800a00:	89 04 24             	mov    %eax,(%esp)
  800a03:	e8 56 fb ff ff       	call   80055e <printnum>
			break;
  800a08:	e9 d7 00 00 00       	jmp    800ae4 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a0d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a10:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a14:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a1e:	ff d0                	call   *%eax
			putch('x', putdat);
  800a20:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a23:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a27:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a2e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a31:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a33:	8b 45 14             	mov    0x14(%ebp),%eax
  800a36:	8d 50 04             	lea    0x4(%eax),%edx
  800a39:	89 55 14             	mov    %edx,0x14(%ebp)
  800a3c:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a41:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a48:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a4f:	eb 1f                	jmp    800a70 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a51:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a58:	8d 45 14             	lea    0x14(%ebp),%eax
  800a5b:	89 04 24             	mov    %eax,(%esp)
  800a5e:	e8 d9 fb ff ff       	call   80063c <getuint>
  800a63:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a66:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a69:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a70:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a74:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a77:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a7b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a7e:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a82:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a86:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a89:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a90:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a9e:	89 04 24             	mov    %eax,(%esp)
  800aa1:	e8 b8 fa ff ff       	call   80055e <printnum>
			break;
  800aa6:	eb 3c                	jmp    800ae4 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aab:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aaf:	89 1c 24             	mov    %ebx,(%esp)
  800ab2:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab5:	ff d0                	call   *%eax
			break;
  800ab7:	eb 2b                	jmp    800ae4 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ac7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aca:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800acc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ad0:	eb 04                	jmp    800ad6 <vprintfmt+0x404>
  800ad2:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ad6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ad9:	83 e8 01             	sub    $0x1,%eax
  800adc:	0f b6 00             	movzbl (%eax),%eax
  800adf:	3c 25                	cmp    $0x25,%al
  800ae1:	75 ef                	jne    800ad2 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800ae3:	90                   	nop
		}
	}
  800ae4:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800ae5:	e9 0a fc ff ff       	jmp    8006f4 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aea:	83 c4 40             	add    $0x40,%esp
  800aed:	5b                   	pop    %ebx
  800aee:	5e                   	pop    %esi
  800aef:	5d                   	pop    %ebp
  800af0:	c3                   	ret    

00800af1 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800af1:	55                   	push   %ebp
  800af2:	89 e5                	mov    %esp,%ebp
  800af4:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800af7:	8d 45 14             	lea    0x14(%ebp),%eax
  800afa:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b00:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b04:	8b 45 10             	mov    0x10(%ebp),%eax
  800b07:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b0b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b12:	8b 45 08             	mov    0x8(%ebp),%eax
  800b15:	89 04 24             	mov    %eax,(%esp)
  800b18:	e8 b5 fb ff ff       	call   8006d2 <vprintfmt>
	va_end(ap);
}
  800b1d:	c9                   	leave  
  800b1e:	c3                   	ret    

00800b1f <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b1f:	55                   	push   %ebp
  800b20:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b25:	8b 40 08             	mov    0x8(%eax),%eax
  800b28:	8d 50 01             	lea    0x1(%eax),%edx
  800b2b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2e:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b34:	8b 10                	mov    (%eax),%edx
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	8b 40 04             	mov    0x4(%eax),%eax
  800b3c:	39 c2                	cmp    %eax,%edx
  800b3e:	73 12                	jae    800b52 <sprintputch+0x33>
		*b->buf++ = ch;
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	8b 00                	mov    (%eax),%eax
  800b45:	8d 48 01             	lea    0x1(%eax),%ecx
  800b48:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b4b:	89 0a                	mov    %ecx,(%edx)
  800b4d:	8b 55 08             	mov    0x8(%ebp),%edx
  800b50:	88 10                	mov    %dl,(%eax)
}
  800b52:	5d                   	pop    %ebp
  800b53:	c3                   	ret    

00800b54 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b54:	55                   	push   %ebp
  800b55:	89 e5                	mov    %esp,%ebp
  800b57:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5a:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b60:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b63:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b66:	8b 45 08             	mov    0x8(%ebp),%eax
  800b69:	01 d0                	add    %edx,%eax
  800b6b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b6e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b75:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b79:	74 06                	je     800b81 <vsnprintf+0x2d>
  800b7b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b7f:	7f 07                	jg     800b88 <vsnprintf+0x34>
		return -E_INVAL;
  800b81:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b86:	eb 2a                	jmp    800bb2 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b88:	8b 45 14             	mov    0x14(%ebp),%eax
  800b8b:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b8f:	8b 45 10             	mov    0x10(%ebp),%eax
  800b92:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b96:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b99:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b9d:	c7 04 24 1f 0b 80 00 	movl   $0x800b1f,(%esp)
  800ba4:	e8 29 fb ff ff       	call   8006d2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800ba9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bac:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800baf:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bb2:	c9                   	leave  
  800bb3:	c3                   	ret    

00800bb4 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bb4:	55                   	push   %ebp
  800bb5:	89 e5                	mov    %esp,%ebp
  800bb7:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bba:	8d 45 14             	lea    0x14(%ebp),%eax
  800bbd:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bc0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc3:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bc7:	8b 45 10             	mov    0x10(%ebp),%eax
  800bca:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bd5:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd8:	89 04 24             	mov    %eax,(%esp)
  800bdb:	e8 74 ff ff ff       	call   800b54 <vsnprintf>
  800be0:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800be3:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800be6:	c9                   	leave  
  800be7:	c3                   	ret    

00800be8 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bee:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bf5:	eb 08                	jmp    800bff <strlen+0x17>
		n++;
  800bf7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800bfb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800bff:	8b 45 08             	mov    0x8(%ebp),%eax
  800c02:	0f b6 00             	movzbl (%eax),%eax
  800c05:	84 c0                	test   %al,%al
  800c07:	75 ee                	jne    800bf7 <strlen+0xf>
		n++;
	return n;
  800c09:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c0e:	55                   	push   %ebp
  800c0f:	89 e5                	mov    %esp,%ebp
  800c11:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c14:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c1b:	eb 0c                	jmp    800c29 <strnlen+0x1b>
		n++;
  800c1d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c21:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c25:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c29:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c2d:	74 0a                	je     800c39 <strnlen+0x2b>
  800c2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c32:	0f b6 00             	movzbl (%eax),%eax
  800c35:	84 c0                	test   %al,%al
  800c37:	75 e4                	jne    800c1d <strnlen+0xf>
		n++;
	return n;
  800c39:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c3c:	c9                   	leave  
  800c3d:	c3                   	ret    

00800c3e <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c3e:	55                   	push   %ebp
  800c3f:	89 e5                	mov    %esp,%ebp
  800c41:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c44:	8b 45 08             	mov    0x8(%ebp),%eax
  800c47:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c4a:	90                   	nop
  800c4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4e:	8d 50 01             	lea    0x1(%eax),%edx
  800c51:	89 55 08             	mov    %edx,0x8(%ebp)
  800c54:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c57:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c5a:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c5d:	0f b6 12             	movzbl (%edx),%edx
  800c60:	88 10                	mov    %dl,(%eax)
  800c62:	0f b6 00             	movzbl (%eax),%eax
  800c65:	84 c0                	test   %al,%al
  800c67:	75 e2                	jne    800c4b <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c69:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c6e:	55                   	push   %ebp
  800c6f:	89 e5                	mov    %esp,%ebp
  800c71:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c74:	8b 45 08             	mov    0x8(%ebp),%eax
  800c77:	89 04 24             	mov    %eax,(%esp)
  800c7a:	e8 69 ff ff ff       	call   800be8 <strlen>
  800c7f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c82:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	01 c2                	add    %eax,%edx
  800c8a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c8d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c91:	89 14 24             	mov    %edx,(%esp)
  800c94:	e8 a5 ff ff ff       	call   800c3e <strcpy>
	return dst;
  800c99:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800c9c:	c9                   	leave  
  800c9d:	c3                   	ret    

00800c9e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800c9e:	55                   	push   %ebp
  800c9f:	89 e5                	mov    %esp,%ebp
  800ca1:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ca4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca7:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800caa:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cb1:	eb 23                	jmp    800cd6 <strncpy+0x38>
		*dst++ = *src;
  800cb3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb6:	8d 50 01             	lea    0x1(%eax),%edx
  800cb9:	89 55 08             	mov    %edx,0x8(%ebp)
  800cbc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cbf:	0f b6 12             	movzbl (%edx),%edx
  800cc2:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cc7:	0f b6 00             	movzbl (%eax),%eax
  800cca:	84 c0                	test   %al,%al
  800ccc:	74 04                	je     800cd2 <strncpy+0x34>
			src++;
  800cce:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd2:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cd6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cd9:	3b 45 10             	cmp    0x10(%ebp),%eax
  800cdc:	72 d5                	jb     800cb3 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cde:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ce1:	c9                   	leave  
  800ce2:	c3                   	ret    

00800ce3 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800ce9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cec:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cef:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf3:	74 33                	je     800d28 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cf5:	eb 17                	jmp    800d0e <strlcpy+0x2b>
			*dst++ = *src++;
  800cf7:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfa:	8d 50 01             	lea    0x1(%eax),%edx
  800cfd:	89 55 08             	mov    %edx,0x8(%ebp)
  800d00:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d03:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d06:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d09:	0f b6 12             	movzbl (%edx),%edx
  800d0c:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d0e:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d12:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d16:	74 0a                	je     800d22 <strlcpy+0x3f>
  800d18:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1b:	0f b6 00             	movzbl (%eax),%eax
  800d1e:	84 c0                	test   %al,%al
  800d20:	75 d5                	jne    800cf7 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d22:	8b 45 08             	mov    0x8(%ebp),%eax
  800d25:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d28:	8b 55 08             	mov    0x8(%ebp),%edx
  800d2b:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d2e:	29 c2                	sub    %eax,%edx
  800d30:	89 d0                	mov    %edx,%eax
}
  800d32:	c9                   	leave  
  800d33:	c3                   	ret    

00800d34 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d34:	55                   	push   %ebp
  800d35:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d37:	eb 08                	jmp    800d41 <strcmp+0xd>
		p++, q++;
  800d39:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d3d:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d41:	8b 45 08             	mov    0x8(%ebp),%eax
  800d44:	0f b6 00             	movzbl (%eax),%eax
  800d47:	84 c0                	test   %al,%al
  800d49:	74 10                	je     800d5b <strcmp+0x27>
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	0f b6 10             	movzbl (%eax),%edx
  800d51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d54:	0f b6 00             	movzbl (%eax),%eax
  800d57:	38 c2                	cmp    %al,%dl
  800d59:	74 de                	je     800d39 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5e:	0f b6 00             	movzbl (%eax),%eax
  800d61:	0f b6 d0             	movzbl %al,%edx
  800d64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d67:	0f b6 00             	movzbl (%eax),%eax
  800d6a:	0f b6 c0             	movzbl %al,%eax
  800d6d:	29 c2                	sub    %eax,%edx
  800d6f:	89 d0                	mov    %edx,%eax
}
  800d71:	5d                   	pop    %ebp
  800d72:	c3                   	ret    

00800d73 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d73:	55                   	push   %ebp
  800d74:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d76:	eb 0c                	jmp    800d84 <strncmp+0x11>
		n--, p++, q++;
  800d78:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d7c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d80:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d84:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d88:	74 1a                	je     800da4 <strncmp+0x31>
  800d8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8d:	0f b6 00             	movzbl (%eax),%eax
  800d90:	84 c0                	test   %al,%al
  800d92:	74 10                	je     800da4 <strncmp+0x31>
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 10             	movzbl (%eax),%edx
  800d9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9d:	0f b6 00             	movzbl (%eax),%eax
  800da0:	38 c2                	cmp    %al,%dl
  800da2:	74 d4                	je     800d78 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800da4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800da8:	75 07                	jne    800db1 <strncmp+0x3e>
		return 0;
  800daa:	b8 00 00 00 00       	mov    $0x0,%eax
  800daf:	eb 16                	jmp    800dc7 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800db1:	8b 45 08             	mov    0x8(%ebp),%eax
  800db4:	0f b6 00             	movzbl (%eax),%eax
  800db7:	0f b6 d0             	movzbl %al,%edx
  800dba:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dbd:	0f b6 00             	movzbl (%eax),%eax
  800dc0:	0f b6 c0             	movzbl %al,%eax
  800dc3:	29 c2                	sub    %eax,%edx
  800dc5:	89 d0                	mov    %edx,%eax
}
  800dc7:	5d                   	pop    %ebp
  800dc8:	c3                   	ret    

00800dc9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dc9:	55                   	push   %ebp
  800dca:	89 e5                	mov    %esp,%ebp
  800dcc:	83 ec 04             	sub    $0x4,%esp
  800dcf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd2:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dd5:	eb 14                	jmp    800deb <strchr+0x22>
		if (*s == c)
  800dd7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dda:	0f b6 00             	movzbl (%eax),%eax
  800ddd:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800de0:	75 05                	jne    800de7 <strchr+0x1e>
			return (char *) s;
  800de2:	8b 45 08             	mov    0x8(%ebp),%eax
  800de5:	eb 13                	jmp    800dfa <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800de7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800deb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dee:	0f b6 00             	movzbl (%eax),%eax
  800df1:	84 c0                	test   %al,%al
  800df3:	75 e2                	jne    800dd7 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800df5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dfa:	c9                   	leave  
  800dfb:	c3                   	ret    

00800dfc <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800dfc:	55                   	push   %ebp
  800dfd:	89 e5                	mov    %esp,%ebp
  800dff:	83 ec 04             	sub    $0x4,%esp
  800e02:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e05:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e08:	eb 11                	jmp    800e1b <strfind+0x1f>
		if (*s == c)
  800e0a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e0d:	0f b6 00             	movzbl (%eax),%eax
  800e10:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e13:	75 02                	jne    800e17 <strfind+0x1b>
			break;
  800e15:	eb 0e                	jmp    800e25 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e17:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	0f b6 00             	movzbl (%eax),%eax
  800e21:	84 c0                	test   %al,%al
  800e23:	75 e5                	jne    800e0a <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e28:	c9                   	leave  
  800e29:	c3                   	ret    

00800e2a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2a:	55                   	push   %ebp
  800e2b:	89 e5                	mov    %esp,%ebp
  800e2d:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e2e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e32:	75 05                	jne    800e39 <memset+0xf>
		return v;
  800e34:	8b 45 08             	mov    0x8(%ebp),%eax
  800e37:	eb 5c                	jmp    800e95 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	83 e0 03             	and    $0x3,%eax
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	75 41                	jne    800e84 <memset+0x5a>
  800e43:	8b 45 10             	mov    0x10(%ebp),%eax
  800e46:	83 e0 03             	and    $0x3,%eax
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	75 37                	jne    800e84 <memset+0x5a>
		c &= 0xFF;
  800e4d:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e54:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e57:	c1 e0 18             	shl    $0x18,%eax
  800e5a:	89 c2                	mov    %eax,%edx
  800e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5f:	c1 e0 10             	shl    $0x10,%eax
  800e62:	09 c2                	or     %eax,%edx
  800e64:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e67:	c1 e0 08             	shl    $0x8,%eax
  800e6a:	09 d0                	or     %edx,%eax
  800e6c:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e6f:	8b 45 10             	mov    0x10(%ebp),%eax
  800e72:	c1 e8 02             	shr    $0x2,%eax
  800e75:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e77:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e7d:	89 d7                	mov    %edx,%edi
  800e7f:	fc                   	cld    
  800e80:	f3 ab                	rep stos %eax,%es:(%edi)
  800e82:	eb 0e                	jmp    800e92 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e84:	8b 55 08             	mov    0x8(%ebp),%edx
  800e87:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8a:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e8d:	89 d7                	mov    %edx,%edi
  800e8f:	fc                   	cld    
  800e90:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e92:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e95:	5f                   	pop    %edi
  800e96:	5d                   	pop    %ebp
  800e97:	c3                   	ret    

00800e98 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	57                   	push   %edi
  800e9c:	56                   	push   %esi
  800e9d:	53                   	push   %ebx
  800e9e:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ea1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea4:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800ea7:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaa:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ead:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb0:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eb3:	73 6d                	jae    800f22 <memmove+0x8a>
  800eb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ebb:	01 d0                	add    %edx,%eax
  800ebd:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec0:	76 60                	jbe    800f22 <memmove+0x8a>
		s += n;
  800ec2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec5:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ec8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecb:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ece:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed1:	83 e0 03             	and    $0x3,%eax
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	75 2f                	jne    800f07 <memmove+0x6f>
  800ed8:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800edb:	83 e0 03             	and    $0x3,%eax
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	75 25                	jne    800f07 <memmove+0x6f>
  800ee2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ee5:	83 e0 03             	and    $0x3,%eax
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	75 1b                	jne    800f07 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800eec:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eef:	83 e8 04             	sub    $0x4,%eax
  800ef2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ef5:	83 ea 04             	sub    $0x4,%edx
  800ef8:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800efb:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800efe:	89 c7                	mov    %eax,%edi
  800f00:	89 d6                	mov    %edx,%esi
  800f02:	fd                   	std    
  800f03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f05:	eb 18                	jmp    800f1f <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f0a:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f0d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f10:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f13:	8b 45 10             	mov    0x10(%ebp),%eax
  800f16:	89 d7                	mov    %edx,%edi
  800f18:	89 de                	mov    %ebx,%esi
  800f1a:	89 c1                	mov    %eax,%ecx
  800f1c:	fd                   	std    
  800f1d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f1f:	fc                   	cld    
  800f20:	eb 45                	jmp    800f67 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f22:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f25:	83 e0 03             	and    $0x3,%eax
  800f28:	85 c0                	test   %eax,%eax
  800f2a:	75 2b                	jne    800f57 <memmove+0xbf>
  800f2c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f2f:	83 e0 03             	and    $0x3,%eax
  800f32:	85 c0                	test   %eax,%eax
  800f34:	75 21                	jne    800f57 <memmove+0xbf>
  800f36:	8b 45 10             	mov    0x10(%ebp),%eax
  800f39:	83 e0 03             	and    $0x3,%eax
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	75 17                	jne    800f57 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f40:	8b 45 10             	mov    0x10(%ebp),%eax
  800f43:	c1 e8 02             	shr    $0x2,%eax
  800f46:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f48:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f4e:	89 c7                	mov    %eax,%edi
  800f50:	89 d6                	mov    %edx,%esi
  800f52:	fc                   	cld    
  800f53:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f55:	eb 10                	jmp    800f67 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f57:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f5d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f60:	89 c7                	mov    %eax,%edi
  800f62:	89 d6                	mov    %edx,%esi
  800f64:	fc                   	cld    
  800f65:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f6a:	83 c4 10             	add    $0x10,%esp
  800f6d:	5b                   	pop    %ebx
  800f6e:	5e                   	pop    %esi
  800f6f:	5f                   	pop    %edi
  800f70:	5d                   	pop    %ebp
  800f71:	c3                   	ret    

00800f72 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f72:	55                   	push   %ebp
  800f73:	89 e5                	mov    %esp,%ebp
  800f75:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f78:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7b:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f82:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f86:	8b 45 08             	mov    0x8(%ebp),%eax
  800f89:	89 04 24             	mov    %eax,(%esp)
  800f8c:	e8 07 ff ff ff       	call   800e98 <memmove>
}
  800f91:	c9                   	leave  
  800f92:	c3                   	ret    

00800f93 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f93:	55                   	push   %ebp
  800f94:	89 e5                	mov    %esp,%ebp
  800f96:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f99:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800f9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa2:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fa5:	eb 30                	jmp    800fd7 <memcmp+0x44>
		if (*s1 != *s2)
  800fa7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800faa:	0f b6 10             	movzbl (%eax),%edx
  800fad:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fb0:	0f b6 00             	movzbl (%eax),%eax
  800fb3:	38 c2                	cmp    %al,%dl
  800fb5:	74 18                	je     800fcf <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fb7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fba:	0f b6 00             	movzbl (%eax),%eax
  800fbd:	0f b6 d0             	movzbl %al,%edx
  800fc0:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc3:	0f b6 00             	movzbl (%eax),%eax
  800fc6:	0f b6 c0             	movzbl %al,%eax
  800fc9:	29 c2                	sub    %eax,%edx
  800fcb:	89 d0                	mov    %edx,%eax
  800fcd:	eb 1a                	jmp    800fe9 <memcmp+0x56>
		s1++, s2++;
  800fcf:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fd3:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fd7:	8b 45 10             	mov    0x10(%ebp),%eax
  800fda:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fdd:	89 55 10             	mov    %edx,0x10(%ebp)
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	75 c3                	jne    800fa7 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fe4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fe9:	c9                   	leave  
  800fea:	c3                   	ret    

00800feb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800feb:	55                   	push   %ebp
  800fec:	89 e5                	mov    %esp,%ebp
  800fee:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ff1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff4:	8b 55 08             	mov    0x8(%ebp),%edx
  800ff7:	01 d0                	add    %edx,%eax
  800ff9:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  800ffc:	eb 13                	jmp    801011 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ffe:	8b 45 08             	mov    0x8(%ebp),%eax
  801001:	0f b6 10             	movzbl (%eax),%edx
  801004:	8b 45 0c             	mov    0xc(%ebp),%eax
  801007:	38 c2                	cmp    %al,%dl
  801009:	75 02                	jne    80100d <memfind+0x22>
			break;
  80100b:	eb 0c                	jmp    801019 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80100d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801011:	8b 45 08             	mov    0x8(%ebp),%eax
  801014:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801017:	72 e5                	jb     800ffe <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801019:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80101c:	c9                   	leave  
  80101d:	c3                   	ret    

0080101e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80101e:	55                   	push   %ebp
  80101f:	89 e5                	mov    %esp,%ebp
  801021:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801024:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80102b:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801032:	eb 04                	jmp    801038 <strtol+0x1a>
		s++;
  801034:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801038:	8b 45 08             	mov    0x8(%ebp),%eax
  80103b:	0f b6 00             	movzbl (%eax),%eax
  80103e:	3c 20                	cmp    $0x20,%al
  801040:	74 f2                	je     801034 <strtol+0x16>
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	0f b6 00             	movzbl (%eax),%eax
  801048:	3c 09                	cmp    $0x9,%al
  80104a:	74 e8                	je     801034 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80104c:	8b 45 08             	mov    0x8(%ebp),%eax
  80104f:	0f b6 00             	movzbl (%eax),%eax
  801052:	3c 2b                	cmp    $0x2b,%al
  801054:	75 06                	jne    80105c <strtol+0x3e>
		s++;
  801056:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80105a:	eb 15                	jmp    801071 <strtol+0x53>
	else if (*s == '-')
  80105c:	8b 45 08             	mov    0x8(%ebp),%eax
  80105f:	0f b6 00             	movzbl (%eax),%eax
  801062:	3c 2d                	cmp    $0x2d,%al
  801064:	75 0b                	jne    801071 <strtol+0x53>
		s++, neg = 1;
  801066:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80106a:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801071:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801075:	74 06                	je     80107d <strtol+0x5f>
  801077:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80107b:	75 24                	jne    8010a1 <strtol+0x83>
  80107d:	8b 45 08             	mov    0x8(%ebp),%eax
  801080:	0f b6 00             	movzbl (%eax),%eax
  801083:	3c 30                	cmp    $0x30,%al
  801085:	75 1a                	jne    8010a1 <strtol+0x83>
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	83 c0 01             	add    $0x1,%eax
  80108d:	0f b6 00             	movzbl (%eax),%eax
  801090:	3c 78                	cmp    $0x78,%al
  801092:	75 0d                	jne    8010a1 <strtol+0x83>
		s += 2, base = 16;
  801094:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  801098:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  80109f:	eb 2a                	jmp    8010cb <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010a1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010a5:	75 17                	jne    8010be <strtol+0xa0>
  8010a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8010aa:	0f b6 00             	movzbl (%eax),%eax
  8010ad:	3c 30                	cmp    $0x30,%al
  8010af:	75 0d                	jne    8010be <strtol+0xa0>
		s++, base = 8;
  8010b1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010b5:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010bc:	eb 0d                	jmp    8010cb <strtol+0xad>
	else if (base == 0)
  8010be:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c2:	75 07                	jne    8010cb <strtol+0xad>
		base = 10;
  8010c4:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ce:	0f b6 00             	movzbl (%eax),%eax
  8010d1:	3c 2f                	cmp    $0x2f,%al
  8010d3:	7e 1b                	jle    8010f0 <strtol+0xd2>
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	0f b6 00             	movzbl (%eax),%eax
  8010db:	3c 39                	cmp    $0x39,%al
  8010dd:	7f 11                	jg     8010f0 <strtol+0xd2>
			dig = *s - '0';
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	0f b6 00             	movzbl (%eax),%eax
  8010e5:	0f be c0             	movsbl %al,%eax
  8010e8:	83 e8 30             	sub    $0x30,%eax
  8010eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010ee:	eb 48                	jmp    801138 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	0f b6 00             	movzbl (%eax),%eax
  8010f6:	3c 60                	cmp    $0x60,%al
  8010f8:	7e 1b                	jle    801115 <strtol+0xf7>
  8010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fd:	0f b6 00             	movzbl (%eax),%eax
  801100:	3c 7a                	cmp    $0x7a,%al
  801102:	7f 11                	jg     801115 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	0f b6 00             	movzbl (%eax),%eax
  80110a:	0f be c0             	movsbl %al,%eax
  80110d:	83 e8 57             	sub    $0x57,%eax
  801110:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801113:	eb 23                	jmp    801138 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	0f b6 00             	movzbl (%eax),%eax
  80111b:	3c 40                	cmp    $0x40,%al
  80111d:	7e 3d                	jle    80115c <strtol+0x13e>
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	0f b6 00             	movzbl (%eax),%eax
  801125:	3c 5a                	cmp    $0x5a,%al
  801127:	7f 33                	jg     80115c <strtol+0x13e>
			dig = *s - 'A' + 10;
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	0f b6 00             	movzbl (%eax),%eax
  80112f:	0f be c0             	movsbl %al,%eax
  801132:	83 e8 37             	sub    $0x37,%eax
  801135:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801138:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80113b:	3b 45 10             	cmp    0x10(%ebp),%eax
  80113e:	7c 02                	jl     801142 <strtol+0x124>
			break;
  801140:	eb 1a                	jmp    80115c <strtol+0x13e>
		s++, val = (val * base) + dig;
  801142:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801146:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801149:	0f af 45 10          	imul   0x10(%ebp),%eax
  80114d:	89 c2                	mov    %eax,%edx
  80114f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801152:	01 d0                	add    %edx,%eax
  801154:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801157:	e9 6f ff ff ff       	jmp    8010cb <strtol+0xad>

	if (endptr)
  80115c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801160:	74 08                	je     80116a <strtol+0x14c>
		*endptr = (char *) s;
  801162:	8b 45 0c             	mov    0xc(%ebp),%eax
  801165:	8b 55 08             	mov    0x8(%ebp),%edx
  801168:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80116a:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80116e:	74 07                	je     801177 <strtol+0x159>
  801170:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801173:	f7 d8                	neg    %eax
  801175:	eb 03                	jmp    80117a <strtol+0x15c>
  801177:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80117a:	c9                   	leave  
  80117b:	c3                   	ret    
  80117c:	66 90                	xchg   %ax,%ax
  80117e:	66 90                	xchg   %ax,%ax

00801180 <__udivdi3>:
  801180:	55                   	push   %ebp
  801181:	57                   	push   %edi
  801182:	56                   	push   %esi
  801183:	83 ec 0c             	sub    $0xc,%esp
  801186:	8b 44 24 28          	mov    0x28(%esp),%eax
  80118a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80118e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801192:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801196:	85 c0                	test   %eax,%eax
  801198:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80119c:	89 ea                	mov    %ebp,%edx
  80119e:	89 0c 24             	mov    %ecx,(%esp)
  8011a1:	75 2d                	jne    8011d0 <__udivdi3+0x50>
  8011a3:	39 e9                	cmp    %ebp,%ecx
  8011a5:	77 61                	ja     801208 <__udivdi3+0x88>
  8011a7:	85 c9                	test   %ecx,%ecx
  8011a9:	89 ce                	mov    %ecx,%esi
  8011ab:	75 0b                	jne    8011b8 <__udivdi3+0x38>
  8011ad:	b8 01 00 00 00       	mov    $0x1,%eax
  8011b2:	31 d2                	xor    %edx,%edx
  8011b4:	f7 f1                	div    %ecx
  8011b6:	89 c6                	mov    %eax,%esi
  8011b8:	31 d2                	xor    %edx,%edx
  8011ba:	89 e8                	mov    %ebp,%eax
  8011bc:	f7 f6                	div    %esi
  8011be:	89 c5                	mov    %eax,%ebp
  8011c0:	89 f8                	mov    %edi,%eax
  8011c2:	f7 f6                	div    %esi
  8011c4:	89 ea                	mov    %ebp,%edx
  8011c6:	83 c4 0c             	add    $0xc,%esp
  8011c9:	5e                   	pop    %esi
  8011ca:	5f                   	pop    %edi
  8011cb:	5d                   	pop    %ebp
  8011cc:	c3                   	ret    
  8011cd:	8d 76 00             	lea    0x0(%esi),%esi
  8011d0:	39 e8                	cmp    %ebp,%eax
  8011d2:	77 24                	ja     8011f8 <__udivdi3+0x78>
  8011d4:	0f bd e8             	bsr    %eax,%ebp
  8011d7:	83 f5 1f             	xor    $0x1f,%ebp
  8011da:	75 3c                	jne    801218 <__udivdi3+0x98>
  8011dc:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011e0:	39 34 24             	cmp    %esi,(%esp)
  8011e3:	0f 86 9f 00 00 00    	jbe    801288 <__udivdi3+0x108>
  8011e9:	39 d0                	cmp    %edx,%eax
  8011eb:	0f 82 97 00 00 00    	jb     801288 <__udivdi3+0x108>
  8011f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8011f8:	31 d2                	xor    %edx,%edx
  8011fa:	31 c0                	xor    %eax,%eax
  8011fc:	83 c4 0c             	add    $0xc,%esp
  8011ff:	5e                   	pop    %esi
  801200:	5f                   	pop    %edi
  801201:	5d                   	pop    %ebp
  801202:	c3                   	ret    
  801203:	90                   	nop
  801204:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801208:	89 f8                	mov    %edi,%eax
  80120a:	f7 f1                	div    %ecx
  80120c:	31 d2                	xor    %edx,%edx
  80120e:	83 c4 0c             	add    $0xc,%esp
  801211:	5e                   	pop    %esi
  801212:	5f                   	pop    %edi
  801213:	5d                   	pop    %ebp
  801214:	c3                   	ret    
  801215:	8d 76 00             	lea    0x0(%esi),%esi
  801218:	89 e9                	mov    %ebp,%ecx
  80121a:	8b 3c 24             	mov    (%esp),%edi
  80121d:	d3 e0                	shl    %cl,%eax
  80121f:	89 c6                	mov    %eax,%esi
  801221:	b8 20 00 00 00       	mov    $0x20,%eax
  801226:	29 e8                	sub    %ebp,%eax
  801228:	89 c1                	mov    %eax,%ecx
  80122a:	d3 ef                	shr    %cl,%edi
  80122c:	89 e9                	mov    %ebp,%ecx
  80122e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801232:	8b 3c 24             	mov    (%esp),%edi
  801235:	09 74 24 08          	or     %esi,0x8(%esp)
  801239:	89 d6                	mov    %edx,%esi
  80123b:	d3 e7                	shl    %cl,%edi
  80123d:	89 c1                	mov    %eax,%ecx
  80123f:	89 3c 24             	mov    %edi,(%esp)
  801242:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801246:	d3 ee                	shr    %cl,%esi
  801248:	89 e9                	mov    %ebp,%ecx
  80124a:	d3 e2                	shl    %cl,%edx
  80124c:	89 c1                	mov    %eax,%ecx
  80124e:	d3 ef                	shr    %cl,%edi
  801250:	09 d7                	or     %edx,%edi
  801252:	89 f2                	mov    %esi,%edx
  801254:	89 f8                	mov    %edi,%eax
  801256:	f7 74 24 08          	divl   0x8(%esp)
  80125a:	89 d6                	mov    %edx,%esi
  80125c:	89 c7                	mov    %eax,%edi
  80125e:	f7 24 24             	mull   (%esp)
  801261:	39 d6                	cmp    %edx,%esi
  801263:	89 14 24             	mov    %edx,(%esp)
  801266:	72 30                	jb     801298 <__udivdi3+0x118>
  801268:	8b 54 24 04          	mov    0x4(%esp),%edx
  80126c:	89 e9                	mov    %ebp,%ecx
  80126e:	d3 e2                	shl    %cl,%edx
  801270:	39 c2                	cmp    %eax,%edx
  801272:	73 05                	jae    801279 <__udivdi3+0xf9>
  801274:	3b 34 24             	cmp    (%esp),%esi
  801277:	74 1f                	je     801298 <__udivdi3+0x118>
  801279:	89 f8                	mov    %edi,%eax
  80127b:	31 d2                	xor    %edx,%edx
  80127d:	e9 7a ff ff ff       	jmp    8011fc <__udivdi3+0x7c>
  801282:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801288:	31 d2                	xor    %edx,%edx
  80128a:	b8 01 00 00 00       	mov    $0x1,%eax
  80128f:	e9 68 ff ff ff       	jmp    8011fc <__udivdi3+0x7c>
  801294:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801298:	8d 47 ff             	lea    -0x1(%edi),%eax
  80129b:	31 d2                	xor    %edx,%edx
  80129d:	83 c4 0c             	add    $0xc,%esp
  8012a0:	5e                   	pop    %esi
  8012a1:	5f                   	pop    %edi
  8012a2:	5d                   	pop    %ebp
  8012a3:	c3                   	ret    
  8012a4:	66 90                	xchg   %ax,%ax
  8012a6:	66 90                	xchg   %ax,%ax
  8012a8:	66 90                	xchg   %ax,%ax
  8012aa:	66 90                	xchg   %ax,%ax
  8012ac:	66 90                	xchg   %ax,%ax
  8012ae:	66 90                	xchg   %ax,%ax

008012b0 <__umoddi3>:
  8012b0:	55                   	push   %ebp
  8012b1:	57                   	push   %edi
  8012b2:	56                   	push   %esi
  8012b3:	83 ec 14             	sub    $0x14,%esp
  8012b6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ba:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012be:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012c2:	89 c7                	mov    %eax,%edi
  8012c4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012c8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012cc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012d0:	89 34 24             	mov    %esi,(%esp)
  8012d3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	89 c2                	mov    %eax,%edx
  8012db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012df:	75 17                	jne    8012f8 <__umoddi3+0x48>
  8012e1:	39 fe                	cmp    %edi,%esi
  8012e3:	76 4b                	jbe    801330 <__umoddi3+0x80>
  8012e5:	89 c8                	mov    %ecx,%eax
  8012e7:	89 fa                	mov    %edi,%edx
  8012e9:	f7 f6                	div    %esi
  8012eb:	89 d0                	mov    %edx,%eax
  8012ed:	31 d2                	xor    %edx,%edx
  8012ef:	83 c4 14             	add    $0x14,%esp
  8012f2:	5e                   	pop    %esi
  8012f3:	5f                   	pop    %edi
  8012f4:	5d                   	pop    %ebp
  8012f5:	c3                   	ret    
  8012f6:	66 90                	xchg   %ax,%ax
  8012f8:	39 f8                	cmp    %edi,%eax
  8012fa:	77 54                	ja     801350 <__umoddi3+0xa0>
  8012fc:	0f bd e8             	bsr    %eax,%ebp
  8012ff:	83 f5 1f             	xor    $0x1f,%ebp
  801302:	75 5c                	jne    801360 <__umoddi3+0xb0>
  801304:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801308:	39 3c 24             	cmp    %edi,(%esp)
  80130b:	0f 87 e7 00 00 00    	ja     8013f8 <__umoddi3+0x148>
  801311:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801315:	29 f1                	sub    %esi,%ecx
  801317:	19 c7                	sbb    %eax,%edi
  801319:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80131d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801321:	8b 44 24 08          	mov    0x8(%esp),%eax
  801325:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801329:	83 c4 14             	add    $0x14,%esp
  80132c:	5e                   	pop    %esi
  80132d:	5f                   	pop    %edi
  80132e:	5d                   	pop    %ebp
  80132f:	c3                   	ret    
  801330:	85 f6                	test   %esi,%esi
  801332:	89 f5                	mov    %esi,%ebp
  801334:	75 0b                	jne    801341 <__umoddi3+0x91>
  801336:	b8 01 00 00 00       	mov    $0x1,%eax
  80133b:	31 d2                	xor    %edx,%edx
  80133d:	f7 f6                	div    %esi
  80133f:	89 c5                	mov    %eax,%ebp
  801341:	8b 44 24 04          	mov    0x4(%esp),%eax
  801345:	31 d2                	xor    %edx,%edx
  801347:	f7 f5                	div    %ebp
  801349:	89 c8                	mov    %ecx,%eax
  80134b:	f7 f5                	div    %ebp
  80134d:	eb 9c                	jmp    8012eb <__umoddi3+0x3b>
  80134f:	90                   	nop
  801350:	89 c8                	mov    %ecx,%eax
  801352:	89 fa                	mov    %edi,%edx
  801354:	83 c4 14             	add    $0x14,%esp
  801357:	5e                   	pop    %esi
  801358:	5f                   	pop    %edi
  801359:	5d                   	pop    %ebp
  80135a:	c3                   	ret    
  80135b:	90                   	nop
  80135c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801360:	8b 04 24             	mov    (%esp),%eax
  801363:	be 20 00 00 00       	mov    $0x20,%esi
  801368:	89 e9                	mov    %ebp,%ecx
  80136a:	29 ee                	sub    %ebp,%esi
  80136c:	d3 e2                	shl    %cl,%edx
  80136e:	89 f1                	mov    %esi,%ecx
  801370:	d3 e8                	shr    %cl,%eax
  801372:	89 e9                	mov    %ebp,%ecx
  801374:	89 44 24 04          	mov    %eax,0x4(%esp)
  801378:	8b 04 24             	mov    (%esp),%eax
  80137b:	09 54 24 04          	or     %edx,0x4(%esp)
  80137f:	89 fa                	mov    %edi,%edx
  801381:	d3 e0                	shl    %cl,%eax
  801383:	89 f1                	mov    %esi,%ecx
  801385:	89 44 24 08          	mov    %eax,0x8(%esp)
  801389:	8b 44 24 10          	mov    0x10(%esp),%eax
  80138d:	d3 ea                	shr    %cl,%edx
  80138f:	89 e9                	mov    %ebp,%ecx
  801391:	d3 e7                	shl    %cl,%edi
  801393:	89 f1                	mov    %esi,%ecx
  801395:	d3 e8                	shr    %cl,%eax
  801397:	89 e9                	mov    %ebp,%ecx
  801399:	09 f8                	or     %edi,%eax
  80139b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80139f:	f7 74 24 04          	divl   0x4(%esp)
  8013a3:	d3 e7                	shl    %cl,%edi
  8013a5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013a9:	89 d7                	mov    %edx,%edi
  8013ab:	f7 64 24 08          	mull   0x8(%esp)
  8013af:	39 d7                	cmp    %edx,%edi
  8013b1:	89 c1                	mov    %eax,%ecx
  8013b3:	89 14 24             	mov    %edx,(%esp)
  8013b6:	72 2c                	jb     8013e4 <__umoddi3+0x134>
  8013b8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013bc:	72 22                	jb     8013e0 <__umoddi3+0x130>
  8013be:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013c2:	29 c8                	sub    %ecx,%eax
  8013c4:	19 d7                	sbb    %edx,%edi
  8013c6:	89 e9                	mov    %ebp,%ecx
  8013c8:	89 fa                	mov    %edi,%edx
  8013ca:	d3 e8                	shr    %cl,%eax
  8013cc:	89 f1                	mov    %esi,%ecx
  8013ce:	d3 e2                	shl    %cl,%edx
  8013d0:	89 e9                	mov    %ebp,%ecx
  8013d2:	d3 ef                	shr    %cl,%edi
  8013d4:	09 d0                	or     %edx,%eax
  8013d6:	89 fa                	mov    %edi,%edx
  8013d8:	83 c4 14             	add    $0x14,%esp
  8013db:	5e                   	pop    %esi
  8013dc:	5f                   	pop    %edi
  8013dd:	5d                   	pop    %ebp
  8013de:	c3                   	ret    
  8013df:	90                   	nop
  8013e0:	39 d7                	cmp    %edx,%edi
  8013e2:	75 da                	jne    8013be <__umoddi3+0x10e>
  8013e4:	8b 14 24             	mov    (%esp),%edx
  8013e7:	89 c1                	mov    %eax,%ecx
  8013e9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8013ed:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8013f1:	eb cb                	jmp    8013be <__umoddi3+0x10e>
  8013f3:	90                   	nop
  8013f4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8013f8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8013fc:	0f 82 0f ff ff ff    	jb     801311 <__umoddi3+0x61>
  801402:	e9 1a ff ff ff       	jmp    801321 <__umoddi3+0x71>
