
obj/user/faultnostack:     file format elf32-i386


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
  80002c:	e8 29 00 00 00       	call   80005a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

void _pgfault_upcall();

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 18             	sub    $0x18,%esp
	sys_env_set_pgfault_upcall(0, (void*) _pgfault_upcall);
  800039:	c7 44 24 04 3e 04 80 	movl   $0x80043e,0x4(%esp)
  800040:	00 
  800041:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800048:	e8 2c 03 00 00       	call   800379 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80004d:	b8 00 00 00 00       	mov    $0x0,%eax
  800052:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800058:	c9                   	leave  
  800059:	c3                   	ret    

0080005a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80005a:	55                   	push   %ebp
  80005b:	89 e5                	mov    %esp,%ebp
  80005d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800060:	e8 81 01 00 00       	call   8001e6 <sys_getenvid>
  800065:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006a:	c1 e0 02             	shl    $0x2,%eax
  80006d:	89 c2                	mov    %eax,%edx
  80006f:	c1 e2 05             	shl    $0x5,%edx
  800072:	29 c2                	sub    %eax,%edx
  800074:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80007a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800083:	7e 0a                	jle    80008f <libmain+0x35>
		binaryname = argv[0];
  800085:	8b 45 0c             	mov    0xc(%ebp),%eax
  800088:	8b 00                	mov    (%eax),%eax
  80008a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80008f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800092:	89 44 24 04          	mov    %eax,0x4(%esp)
  800096:	8b 45 08             	mov    0x8(%ebp),%eax
  800099:	89 04 24             	mov    %eax,(%esp)
  80009c:	e8 92 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a1:	e8 02 00 00 00       	call   8000a8 <exit>
}
  8000a6:	c9                   	leave  
  8000a7:	c3                   	ret    

008000a8 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a8:	55                   	push   %ebp
  8000a9:	89 e5                	mov    %esp,%ebp
  8000ab:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  8000ae:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000b5:	e8 e9 00 00 00       	call   8001a3 <sys_env_destroy>
}
  8000ba:	c9                   	leave  
  8000bb:	c3                   	ret    

008000bc <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
  8000c2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000c8:	8b 55 10             	mov    0x10(%ebp),%edx
  8000cb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000ce:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000d1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000d4:	8b 75 20             	mov    0x20(%ebp),%esi
  8000d7:	cd 30                	int    $0x30
  8000d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000dc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000e0:	74 30                	je     800112 <syscall+0x56>
  8000e2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e6:	7e 2a                	jle    800112 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000eb:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8000f2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000f6:	c7 44 24 08 ca 14 80 	movl   $0x8014ca,0x8(%esp)
  8000fd:	00 
  8000fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  800105:	00 
  800106:	c7 04 24 e7 14 80 00 	movl   $0x8014e7,(%esp)
  80010d:	e8 51 03 00 00       	call   800463 <_panic>

	return ret;
  800112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800115:	83 c4 3c             	add    $0x3c,%esp
  800118:	5b                   	pop    %ebx
  800119:	5e                   	pop    %esi
  80011a:	5f                   	pop    %edi
  80011b:	5d                   	pop    %ebp
  80011c:	c3                   	ret    

0080011d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800123:	8b 45 08             	mov    0x8(%ebp),%eax
  800126:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80012d:	00 
  80012e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800135:	00 
  800136:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80013d:	00 
  80013e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800141:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800145:	89 44 24 08          	mov    %eax,0x8(%esp)
  800149:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800150:	00 
  800151:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800158:	e8 5f ff ff ff       	call   8000bc <syscall>
}
  80015d:	c9                   	leave  
  80015e:	c3                   	ret    

0080015f <sys_cgetc>:

int
sys_cgetc(void)
{
  80015f:	55                   	push   %ebp
  800160:	89 e5                	mov    %esp,%ebp
  800162:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800165:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80016c:	00 
  80016d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800174:	00 
  800175:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80017c:	00 
  80017d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800184:	00 
  800185:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80018c:	00 
  80018d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800194:	00 
  800195:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80019c:	e8 1b ff ff ff       	call   8000bc <syscall>
}
  8001a1:	c9                   	leave  
  8001a2:	c3                   	ret    

008001a3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8001a3:	55                   	push   %ebp
  8001a4:	89 e5                	mov    %esp,%ebp
  8001a6:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8001a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8001ac:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001b3:	00 
  8001b4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001bb:	00 
  8001bc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001c3:	00 
  8001c4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001cb:	00 
  8001cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001d0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001d7:	00 
  8001d8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001df:	e8 d8 fe ff ff       	call   8000bc <syscall>
}
  8001e4:	c9                   	leave  
  8001e5:	c3                   	ret    

008001e6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001ec:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001f3:	00 
  8001f4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800203:	00 
  800204:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80020b:	00 
  80020c:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800213:	00 
  800214:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80021b:	00 
  80021c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800223:	e8 94 fe ff ff       	call   8000bc <syscall>
}
  800228:	c9                   	leave  
  800229:	c3                   	ret    

0080022a <sys_yield>:

void
sys_yield(void)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800230:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800237:	00 
  800238:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80023f:	00 
  800240:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800247:	00 
  800248:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80024f:	00 
  800250:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800257:	00 
  800258:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80025f:	00 
  800260:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800267:	e8 50 fe ff ff       	call   8000bc <syscall>
}
  80026c:	c9                   	leave  
  80026d:	c3                   	ret    

0080026e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80026e:	55                   	push   %ebp
  80026f:	89 e5                	mov    %esp,%ebp
  800271:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800274:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800277:	8b 55 0c             	mov    0xc(%ebp),%edx
  80027a:	8b 45 08             	mov    0x8(%ebp),%eax
  80027d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800284:	00 
  800285:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80028c:	00 
  80028d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800291:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800295:	89 44 24 08          	mov    %eax,0x8(%esp)
  800299:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002a0:	00 
  8002a1:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  8002a8:	e8 0f fe ff ff       	call   8000bc <syscall>
}
  8002ad:	c9                   	leave  
  8002ae:	c3                   	ret    

008002af <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8002af:	55                   	push   %ebp
  8002b0:	89 e5                	mov    %esp,%ebp
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8002ba:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002bd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002c0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002c6:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002ca:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002ce:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002d2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002d6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002da:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002e1:	00 
  8002e2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002e9:	e8 ce fd ff ff       	call   8000bc <syscall>
}
  8002ee:	83 c4 20             	add    $0x20,%esp
  8002f1:	5b                   	pop    %ebx
  8002f2:	5e                   	pop    %esi
  8002f3:	5d                   	pop    %ebp
  8002f4:	c3                   	ret    

008002f5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800308:	00 
  800309:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800310:	00 
  800311:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800318:	00 
  800319:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80031d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800321:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800328:	00 
  800329:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800330:	e8 87 fd ff ff       	call   8000bc <syscall>
}
  800335:	c9                   	leave  
  800336:	c3                   	ret    

00800337 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800337:	55                   	push   %ebp
  800338:	89 e5                	mov    %esp,%ebp
  80033a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80033d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800340:	8b 45 08             	mov    0x8(%ebp),%eax
  800343:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80034a:	00 
  80034b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800352:	00 
  800353:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80035a:	00 
  80035b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80035f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800363:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80036a:	00 
  80036b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800372:	e8 45 fd ff ff       	call   8000bc <syscall>
}
  800377:	c9                   	leave  
  800378:	c3                   	ret    

00800379 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800379:	55                   	push   %ebp
  80037a:	89 e5                	mov    %esp,%ebp
  80037c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80037f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800382:	8b 45 08             	mov    0x8(%ebp),%eax
  800385:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80038c:	00 
  80038d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800394:	00 
  800395:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80039c:	00 
  80039d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003a1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003a5:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8003ac:	00 
  8003ad:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003b4:	e8 03 fd ff ff       	call   8000bc <syscall>
}
  8003b9:	c9                   	leave  
  8003ba:	c3                   	ret    

008003bb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003bb:	55                   	push   %ebp
  8003bc:	89 e5                	mov    %esp,%ebp
  8003be:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003c1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003c4:	8b 55 10             	mov    0x10(%ebp),%edx
  8003c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ca:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003d1:	00 
  8003d2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003d6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003dd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003e1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003e5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003ec:	00 
  8003ed:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003f4:	e8 c3 fc ff ff       	call   8000bc <syscall>
}
  8003f9:	c9                   	leave  
  8003fa:	c3                   	ret    

008003fb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003fb:	55                   	push   %ebp
  8003fc:	89 e5                	mov    %esp,%ebp
  8003fe:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800401:	8b 45 08             	mov    0x8(%ebp),%eax
  800404:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80040b:	00 
  80040c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800413:	00 
  800414:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80041b:	00 
  80041c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800423:	00 
  800424:	89 44 24 08          	mov    %eax,0x8(%esp)
  800428:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80042f:	00 
  800430:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800437:	e8 80 fc ff ff       	call   8000bc <syscall>
}
  80043c:	c9                   	leave  
  80043d:	c3                   	ret    

0080043e <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80043e:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80043f:	a1 08 20 80 00       	mov    0x802008,%eax
	call *%eax
  800444:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800446:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 0x30(%esp), %eax
  800449:	8b 44 24 30          	mov    0x30(%esp),%eax
	subl $4, %eax
  80044d:	83 e8 04             	sub    $0x4,%eax
	movl %eax, 0x30(%esp)
  800450:	89 44 24 30          	mov    %eax,0x30(%esp)
	movl 0x28(%esp), %ecx
  800454:	8b 4c 24 28          	mov    0x28(%esp),%ecx
	movl %ecx, (%eax)
  800458:	89 08                	mov    %ecx,(%eax)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	//add $8, %esp
	popl %edx 
  80045a:	5a                   	pop    %edx
	popl %edx
  80045b:	5a                   	pop    %edx
	popal
  80045c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	add $4, %esp
  80045d:	83 c4 04             	add    $0x4,%esp
	popf
  800460:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	popl %esp
  800461:	5c                   	pop    %esp
	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800462:	c3                   	ret    

00800463 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800463:	55                   	push   %ebp
  800464:	89 e5                	mov    %esp,%ebp
  800466:	53                   	push   %ebx
  800467:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80046a:	8d 45 14             	lea    0x14(%ebp),%eax
  80046d:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800470:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800476:	e8 6b fd ff ff       	call   8001e6 <sys_getenvid>
  80047b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80047e:	89 54 24 10          	mov    %edx,0x10(%esp)
  800482:	8b 55 08             	mov    0x8(%ebp),%edx
  800485:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800489:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80048d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800491:	c7 04 24 f8 14 80 00 	movl   $0x8014f8,(%esp)
  800498:	e8 e1 00 00 00       	call   80057e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80049d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8004a0:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004a4:	8b 45 10             	mov    0x10(%ebp),%eax
  8004a7:	89 04 24             	mov    %eax,(%esp)
  8004aa:	e8 6b 00 00 00       	call   80051a <vcprintf>
	cprintf("\n");
  8004af:	c7 04 24 1b 15 80 00 	movl   $0x80151b,(%esp)
  8004b6:	e8 c3 00 00 00       	call   80057e <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8004bb:	cc                   	int3   
  8004bc:	eb fd                	jmp    8004bb <_panic+0x58>

008004be <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8004be:	55                   	push   %ebp
  8004bf:	89 e5                	mov    %esp,%ebp
  8004c1:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	8b 00                	mov    (%eax),%eax
  8004c9:	8d 48 01             	lea    0x1(%eax),%ecx
  8004cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004cf:	89 0a                	mov    %ecx,(%edx)
  8004d1:	8b 55 08             	mov    0x8(%ebp),%edx
  8004d4:	89 d1                	mov    %edx,%ecx
  8004d6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004d9:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e0:	8b 00                	mov    (%eax),%eax
  8004e2:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004e7:	75 20                	jne    800509 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004e9:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ec:	8b 00                	mov    (%eax),%eax
  8004ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004f1:	83 c2 08             	add    $0x8,%edx
  8004f4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004f8:	89 14 24             	mov    %edx,(%esp)
  8004fb:	e8 1d fc ff ff       	call   80011d <sys_cputs>
		b->idx = 0;
  800500:	8b 45 0c             	mov    0xc(%ebp),%eax
  800503:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  800509:	8b 45 0c             	mov    0xc(%ebp),%eax
  80050c:	8b 40 04             	mov    0x4(%eax),%eax
  80050f:	8d 50 01             	lea    0x1(%eax),%edx
  800512:	8b 45 0c             	mov    0xc(%ebp),%eax
  800515:	89 50 04             	mov    %edx,0x4(%eax)
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  800523:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80052a:	00 00 00 
	b.cnt = 0;
  80052d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800534:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800537:	8b 45 0c             	mov    0xc(%ebp),%eax
  80053a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  80053e:	8b 45 08             	mov    0x8(%ebp),%eax
  800541:	89 44 24 08          	mov    %eax,0x8(%esp)
  800545:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80054b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80054f:	c7 04 24 be 04 80 00 	movl   $0x8004be,(%esp)
  800556:	e8 bd 01 00 00       	call   800718 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80055b:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800561:	89 44 24 04          	mov    %eax,0x4(%esp)
  800565:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80056b:	83 c0 08             	add    $0x8,%eax
  80056e:	89 04 24             	mov    %eax,(%esp)
  800571:	e8 a7 fb ff ff       	call   80011d <sys_cputs>

	return b.cnt;
  800576:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80057c:	c9                   	leave  
  80057d:	c3                   	ret    

0080057e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80057e:	55                   	push   %ebp
  80057f:	89 e5                	mov    %esp,%ebp
  800581:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800584:	8d 45 0c             	lea    0xc(%ebp),%eax
  800587:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80058a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80058d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800591:	8b 45 08             	mov    0x8(%ebp),%eax
  800594:	89 04 24             	mov    %eax,(%esp)
  800597:	e8 7e ff ff ff       	call   80051a <vcprintf>
  80059c:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80059f:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  8005a2:	c9                   	leave  
  8005a3:	c3                   	ret    

008005a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8005a4:	55                   	push   %ebp
  8005a5:	89 e5                	mov    %esp,%ebp
  8005a7:	53                   	push   %ebx
  8005a8:	83 ec 34             	sub    $0x34,%esp
  8005ab:	8b 45 10             	mov    0x10(%ebp),%eax
  8005ae:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8005b1:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8005b7:	8b 45 18             	mov    0x18(%ebp),%eax
  8005ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8005bf:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c2:	77 72                	ja     800636 <printnum+0x92>
  8005c4:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  8005c7:	72 05                	jb     8005ce <printnum+0x2a>
  8005c9:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  8005cc:	77 68                	ja     800636 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8005ce:	8b 45 1c             	mov    0x1c(%ebp),%eax
  8005d1:	8d 58 ff             	lea    -0x1(%eax),%ebx
  8005d4:	8b 45 18             	mov    0x18(%ebp),%eax
  8005d7:	ba 00 00 00 00       	mov    $0x0,%edx
  8005dc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005e0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005e7:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ea:	89 04 24             	mov    %eax,(%esp)
  8005ed:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005f1:	e8 3a 0c 00 00       	call   801230 <__udivdi3>
  8005f6:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005f9:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005fd:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  800601:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800604:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800608:	89 44 24 08          	mov    %eax,0x8(%esp)
  80060c:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800610:	8b 45 0c             	mov    0xc(%ebp),%eax
  800613:	89 44 24 04          	mov    %eax,0x4(%esp)
  800617:	8b 45 08             	mov    0x8(%ebp),%eax
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	e8 82 ff ff ff       	call   8005a4 <printnum>
  800622:	eb 1c                	jmp    800640 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800624:	8b 45 0c             	mov    0xc(%ebp),%eax
  800627:	89 44 24 04          	mov    %eax,0x4(%esp)
  80062b:	8b 45 20             	mov    0x20(%ebp),%eax
  80062e:	89 04 24             	mov    %eax,(%esp)
  800631:	8b 45 08             	mov    0x8(%ebp),%eax
  800634:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800636:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  80063a:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  80063e:	7f e4                	jg     800624 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800640:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800643:	bb 00 00 00 00       	mov    $0x0,%ebx
  800648:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80064e:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800652:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800656:	89 04 24             	mov    %eax,(%esp)
  800659:	89 54 24 04          	mov    %edx,0x4(%esp)
  80065d:	e8 fe 0c 00 00       	call   801360 <__umoddi3>
  800662:	05 e8 15 80 00       	add    $0x8015e8,%eax
  800667:	0f b6 00             	movzbl (%eax),%eax
  80066a:	0f be c0             	movsbl %al,%eax
  80066d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800670:	89 54 24 04          	mov    %edx,0x4(%esp)
  800674:	89 04 24             	mov    %eax,(%esp)
  800677:	8b 45 08             	mov    0x8(%ebp),%eax
  80067a:	ff d0                	call   *%eax
}
  80067c:	83 c4 34             	add    $0x34,%esp
  80067f:	5b                   	pop    %ebx
  800680:	5d                   	pop    %ebp
  800681:	c3                   	ret    

00800682 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800682:	55                   	push   %ebp
  800683:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800685:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800689:	7e 14                	jle    80069f <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80068b:	8b 45 08             	mov    0x8(%ebp),%eax
  80068e:	8b 00                	mov    (%eax),%eax
  800690:	8d 48 08             	lea    0x8(%eax),%ecx
  800693:	8b 55 08             	mov    0x8(%ebp),%edx
  800696:	89 0a                	mov    %ecx,(%edx)
  800698:	8b 50 04             	mov    0x4(%eax),%edx
  80069b:	8b 00                	mov    (%eax),%eax
  80069d:	eb 30                	jmp    8006cf <getuint+0x4d>
	else if (lflag)
  80069f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006a3:	74 16                	je     8006bb <getuint+0x39>
		return va_arg(*ap, unsigned long);
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	8d 48 04             	lea    0x4(%eax),%ecx
  8006ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b0:	89 0a                	mov    %ecx,(%edx)
  8006b2:	8b 00                	mov    (%eax),%eax
  8006b4:	ba 00 00 00 00       	mov    $0x0,%edx
  8006b9:	eb 14                	jmp    8006cf <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  8006bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006be:	8b 00                	mov    (%eax),%eax
  8006c0:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c3:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c6:	89 0a                	mov    %ecx,(%edx)
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  8006d1:	55                   	push   %ebp
  8006d2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8006d4:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006d8:	7e 14                	jle    8006ee <getint+0x1d>
		return va_arg(*ap, long long);
  8006da:	8b 45 08             	mov    0x8(%ebp),%eax
  8006dd:	8b 00                	mov    (%eax),%eax
  8006df:	8d 48 08             	lea    0x8(%eax),%ecx
  8006e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006e5:	89 0a                	mov    %ecx,(%edx)
  8006e7:	8b 50 04             	mov    0x4(%eax),%edx
  8006ea:	8b 00                	mov    (%eax),%eax
  8006ec:	eb 28                	jmp    800716 <getint+0x45>
	else if (lflag)
  8006ee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006f2:	74 12                	je     800706 <getint+0x35>
		return va_arg(*ap, long);
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	8b 00                	mov    (%eax),%eax
  8006f9:	8d 48 04             	lea    0x4(%eax),%ecx
  8006fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ff:	89 0a                	mov    %ecx,(%edx)
  800701:	8b 00                	mov    (%eax),%eax
  800703:	99                   	cltd   
  800704:	eb 10                	jmp    800716 <getint+0x45>
	else
		return va_arg(*ap, int);
  800706:	8b 45 08             	mov    0x8(%ebp),%eax
  800709:	8b 00                	mov    (%eax),%eax
  80070b:	8d 48 04             	lea    0x4(%eax),%ecx
  80070e:	8b 55 08             	mov    0x8(%ebp),%edx
  800711:	89 0a                	mov    %ecx,(%edx)
  800713:	8b 00                	mov    (%eax),%eax
  800715:	99                   	cltd   
}
  800716:	5d                   	pop    %ebp
  800717:	c3                   	ret    

00800718 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800718:	55                   	push   %ebp
  800719:	89 e5                	mov    %esp,%ebp
  80071b:	56                   	push   %esi
  80071c:	53                   	push   %ebx
  80071d:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800720:	eb 18                	jmp    80073a <vprintfmt+0x22>
			if (ch == '\0')
  800722:	85 db                	test   %ebx,%ebx
  800724:	75 05                	jne    80072b <vprintfmt+0x13>
				return;
  800726:	e9 05 04 00 00       	jmp    800b30 <vprintfmt+0x418>
			putch(ch, putdat);
  80072b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800732:	89 1c 24             	mov    %ebx,(%esp)
  800735:	8b 45 08             	mov    0x8(%ebp),%eax
  800738:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80073a:	8b 45 10             	mov    0x10(%ebp),%eax
  80073d:	8d 50 01             	lea    0x1(%eax),%edx
  800740:	89 55 10             	mov    %edx,0x10(%ebp)
  800743:	0f b6 00             	movzbl (%eax),%eax
  800746:	0f b6 d8             	movzbl %al,%ebx
  800749:	83 fb 25             	cmp    $0x25,%ebx
  80074c:	75 d4                	jne    800722 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80074e:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800752:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800759:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800760:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800767:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80076e:	8b 45 10             	mov    0x10(%ebp),%eax
  800771:	8d 50 01             	lea    0x1(%eax),%edx
  800774:	89 55 10             	mov    %edx,0x10(%ebp)
  800777:	0f b6 00             	movzbl (%eax),%eax
  80077a:	0f b6 d8             	movzbl %al,%ebx
  80077d:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800780:	83 f8 55             	cmp    $0x55,%eax
  800783:	0f 87 76 03 00 00    	ja     800aff <vprintfmt+0x3e7>
  800789:	8b 04 85 0c 16 80 00 	mov    0x80160c(,%eax,4),%eax
  800790:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800792:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800796:	eb d6                	jmp    80076e <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800798:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80079c:	eb d0                	jmp    80076e <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80079e:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  8007a5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8007a8:	89 d0                	mov    %edx,%eax
  8007aa:	c1 e0 02             	shl    $0x2,%eax
  8007ad:	01 d0                	add    %edx,%eax
  8007af:	01 c0                	add    %eax,%eax
  8007b1:	01 d8                	add    %ebx,%eax
  8007b3:	83 e8 30             	sub    $0x30,%eax
  8007b6:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  8007b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8007bc:	0f b6 00             	movzbl (%eax),%eax
  8007bf:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  8007c2:	83 fb 2f             	cmp    $0x2f,%ebx
  8007c5:	7e 0b                	jle    8007d2 <vprintfmt+0xba>
  8007c7:	83 fb 39             	cmp    $0x39,%ebx
  8007ca:	7f 06                	jg     8007d2 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8007cc:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8007d0:	eb d3                	jmp    8007a5 <vprintfmt+0x8d>
			goto process_precision;
  8007d2:	eb 33                	jmp    800807 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  8007d4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007d7:	8d 50 04             	lea    0x4(%eax),%edx
  8007da:	89 55 14             	mov    %edx,0x14(%ebp)
  8007dd:	8b 00                	mov    (%eax),%eax
  8007df:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007e2:	eb 23                	jmp    800807 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007e4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007e8:	79 0c                	jns    8007f6 <vprintfmt+0xde>
				width = 0;
  8007ea:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007f1:	e9 78 ff ff ff       	jmp    80076e <vprintfmt+0x56>
  8007f6:	e9 73 ff ff ff       	jmp    80076e <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007fb:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  800802:	e9 67 ff ff ff       	jmp    80076e <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  800807:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80080b:	79 12                	jns    80081f <vprintfmt+0x107>
				width = precision, precision = -1;
  80080d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800810:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800813:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  80081a:	e9 4f ff ff ff       	jmp    80076e <vprintfmt+0x56>
  80081f:	e9 4a ff ff ff       	jmp    80076e <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  800824:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  800828:	e9 41 ff ff ff       	jmp    80076e <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80082d:	8b 45 14             	mov    0x14(%ebp),%eax
  800830:	8d 50 04             	lea    0x4(%eax),%edx
  800833:	89 55 14             	mov    %edx,0x14(%ebp)
  800836:	8b 00                	mov    (%eax),%eax
  800838:	8b 55 0c             	mov    0xc(%ebp),%edx
  80083b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80083f:	89 04 24             	mov    %eax,(%esp)
  800842:	8b 45 08             	mov    0x8(%ebp),%eax
  800845:	ff d0                	call   *%eax
			break;
  800847:	e9 de 02 00 00       	jmp    800b2a <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80084c:	8b 45 14             	mov    0x14(%ebp),%eax
  80084f:	8d 50 04             	lea    0x4(%eax),%edx
  800852:	89 55 14             	mov    %edx,0x14(%ebp)
  800855:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800857:	85 db                	test   %ebx,%ebx
  800859:	79 02                	jns    80085d <vprintfmt+0x145>
				err = -err;
  80085b:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80085d:	83 fb 09             	cmp    $0x9,%ebx
  800860:	7f 0b                	jg     80086d <vprintfmt+0x155>
  800862:	8b 34 9d c0 15 80 00 	mov    0x8015c0(,%ebx,4),%esi
  800869:	85 f6                	test   %esi,%esi
  80086b:	75 23                	jne    800890 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80086d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800871:	c7 44 24 08 f9 15 80 	movl   $0x8015f9,0x8(%esp)
  800878:	00 
  800879:	8b 45 0c             	mov    0xc(%ebp),%eax
  80087c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	89 04 24             	mov    %eax,(%esp)
  800886:	e8 ac 02 00 00       	call   800b37 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80088b:	e9 9a 02 00 00       	jmp    800b2a <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800890:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800894:	c7 44 24 08 02 16 80 	movl   $0x801602,0x8(%esp)
  80089b:	00 
  80089c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80089f:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a6:	89 04 24             	mov    %eax,(%esp)
  8008a9:	e8 89 02 00 00       	call   800b37 <printfmt>
			break;
  8008ae:	e9 77 02 00 00       	jmp    800b2a <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8008b3:	8b 45 14             	mov    0x14(%ebp),%eax
  8008b6:	8d 50 04             	lea    0x4(%eax),%edx
  8008b9:	89 55 14             	mov    %edx,0x14(%ebp)
  8008bc:	8b 30                	mov    (%eax),%esi
  8008be:	85 f6                	test   %esi,%esi
  8008c0:	75 05                	jne    8008c7 <vprintfmt+0x1af>
				p = "(null)";
  8008c2:	be 05 16 80 00       	mov    $0x801605,%esi
			if (width > 0 && padc != '-')
  8008c7:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008cb:	7e 37                	jle    800904 <vprintfmt+0x1ec>
  8008cd:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  8008d1:	74 31                	je     800904 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008d6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008da:	89 34 24             	mov    %esi,(%esp)
  8008dd:	e8 72 03 00 00       	call   800c54 <strnlen>
  8008e2:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008e5:	eb 17                	jmp    8008fe <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008e7:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ee:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008f2:	89 04 24             	mov    %eax,(%esp)
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008fa:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fe:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800902:	7f e3                	jg     8008e7 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800904:	eb 38                	jmp    80093e <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  800906:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  80090a:	74 1f                	je     80092b <vprintfmt+0x213>
  80090c:	83 fb 1f             	cmp    $0x1f,%ebx
  80090f:	7e 05                	jle    800916 <vprintfmt+0x1fe>
  800911:	83 fb 7e             	cmp    $0x7e,%ebx
  800914:	7e 15                	jle    80092b <vprintfmt+0x213>
					putch('?', putdat);
  800916:	8b 45 0c             	mov    0xc(%ebp),%eax
  800919:	89 44 24 04          	mov    %eax,0x4(%esp)
  80091d:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  800924:	8b 45 08             	mov    0x8(%ebp),%eax
  800927:	ff d0                	call   *%eax
  800929:	eb 0f                	jmp    80093a <vprintfmt+0x222>
				else
					putch(ch, putdat);
  80092b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800932:	89 1c 24             	mov    %ebx,(%esp)
  800935:	8b 45 08             	mov    0x8(%ebp),%eax
  800938:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80093a:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093e:	89 f0                	mov    %esi,%eax
  800940:	8d 70 01             	lea    0x1(%eax),%esi
  800943:	0f b6 00             	movzbl (%eax),%eax
  800946:	0f be d8             	movsbl %al,%ebx
  800949:	85 db                	test   %ebx,%ebx
  80094b:	74 10                	je     80095d <vprintfmt+0x245>
  80094d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800951:	78 b3                	js     800906 <vprintfmt+0x1ee>
  800953:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800957:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80095b:	79 a9                	jns    800906 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80095d:	eb 17                	jmp    800976 <vprintfmt+0x25e>
				putch(' ', putdat);
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	89 44 24 04          	mov    %eax,0x4(%esp)
  800966:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80096d:	8b 45 08             	mov    0x8(%ebp),%eax
  800970:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800972:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800976:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80097a:	7f e3                	jg     80095f <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80097c:	e9 a9 01 00 00       	jmp    800b2a <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800981:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800984:	89 44 24 04          	mov    %eax,0x4(%esp)
  800988:	8d 45 14             	lea    0x14(%ebp),%eax
  80098b:	89 04 24             	mov    %eax,(%esp)
  80098e:	e8 3e fd ff ff       	call   8006d1 <getint>
  800993:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800996:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800999:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80099c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80099f:	85 d2                	test   %edx,%edx
  8009a1:	79 26                	jns    8009c9 <vprintfmt+0x2b1>
				putch('-', putdat);
  8009a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009aa:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  8009b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b4:	ff d0                	call   *%eax
				num = -(long long) num;
  8009b6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009b9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009bc:	f7 d8                	neg    %eax
  8009be:	83 d2 00             	adc    $0x0,%edx
  8009c1:	f7 da                	neg    %edx
  8009c3:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009c6:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  8009c9:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009d0:	e9 e1 00 00 00       	jmp    800ab6 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009dc:	8d 45 14             	lea    0x14(%ebp),%eax
  8009df:	89 04 24             	mov    %eax,(%esp)
  8009e2:	e8 9b fc ff ff       	call   800682 <getuint>
  8009e7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ea:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009ed:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009f4:	e9 bd 00 00 00       	jmp    800ab6 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009f9:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  800a00:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a07:	8d 45 14             	lea    0x14(%ebp),%eax
  800a0a:	89 04 24             	mov    %eax,(%esp)
  800a0d:	e8 70 fc ff ff       	call   800682 <getuint>
  800a12:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a15:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  800a18:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a1c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a1f:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a23:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a26:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a2a:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a2e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a31:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a34:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a38:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a3f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a43:	8b 45 08             	mov    0x8(%ebp),%eax
  800a46:	89 04 24             	mov    %eax,(%esp)
  800a49:	e8 56 fb ff ff       	call   8005a4 <printnum>
			break;
  800a4e:	e9 d7 00 00 00       	jmp    800b2a <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a53:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a56:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5a:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a61:	8b 45 08             	mov    0x8(%ebp),%eax
  800a64:	ff d0                	call   *%eax
			putch('x', putdat);
  800a66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a69:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a6d:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a74:	8b 45 08             	mov    0x8(%ebp),%eax
  800a77:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a79:	8b 45 14             	mov    0x14(%ebp),%eax
  800a7c:	8d 50 04             	lea    0x4(%eax),%edx
  800a7f:	89 55 14             	mov    %edx,0x14(%ebp)
  800a82:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a84:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a87:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a8e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a95:	eb 1f                	jmp    800ab6 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a97:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a9a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a9e:	8d 45 14             	lea    0x14(%ebp),%eax
  800aa1:	89 04 24             	mov    %eax,(%esp)
  800aa4:	e8 d9 fb ff ff       	call   800682 <getuint>
  800aa9:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800aac:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800aaf:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800ab6:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800aba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800abd:	89 54 24 18          	mov    %edx,0x18(%esp)
  800ac1:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800ac4:	89 54 24 14          	mov    %edx,0x14(%esp)
  800ac8:	89 44 24 10          	mov    %eax,0x10(%esp)
  800acc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800acf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ad2:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ad6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ae1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae4:	89 04 24             	mov    %eax,(%esp)
  800ae7:	e8 b8 fa ff ff       	call   8005a4 <printnum>
			break;
  800aec:	eb 3c                	jmp    800b2a <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aee:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800af5:	89 1c 24             	mov    %ebx,(%esp)
  800af8:	8b 45 08             	mov    0x8(%ebp),%eax
  800afb:	ff d0                	call   *%eax
			break;
  800afd:	eb 2b                	jmp    800b2a <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aff:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b02:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b06:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800b0d:	8b 45 08             	mov    0x8(%ebp),%eax
  800b10:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800b12:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b16:	eb 04                	jmp    800b1c <vprintfmt+0x404>
  800b18:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800b1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800b1f:	83 e8 01             	sub    $0x1,%eax
  800b22:	0f b6 00             	movzbl (%eax),%eax
  800b25:	3c 25                	cmp    $0x25,%al
  800b27:	75 ef                	jne    800b18 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800b29:	90                   	nop
		}
	}
  800b2a:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800b2b:	e9 0a fc ff ff       	jmp    80073a <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800b30:	83 c4 40             	add    $0x40,%esp
  800b33:	5b                   	pop    %ebx
  800b34:	5e                   	pop    %esi
  800b35:	5d                   	pop    %ebp
  800b36:	c3                   	ret    

00800b37 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b37:	55                   	push   %ebp
  800b38:	89 e5                	mov    %esp,%ebp
  800b3a:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b3d:	8d 45 14             	lea    0x14(%ebp),%eax
  800b40:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b43:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b46:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800b4d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b58:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5b:	89 04 24             	mov    %eax,(%esp)
  800b5e:	e8 b5 fb ff ff       	call   800718 <vprintfmt>
	va_end(ap);
}
  800b63:	c9                   	leave  
  800b64:	c3                   	ret    

00800b65 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b68:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6b:	8b 40 08             	mov    0x8(%eax),%eax
  800b6e:	8d 50 01             	lea    0x1(%eax),%edx
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b77:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7a:	8b 10                	mov    (%eax),%edx
  800b7c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b7f:	8b 40 04             	mov    0x4(%eax),%eax
  800b82:	39 c2                	cmp    %eax,%edx
  800b84:	73 12                	jae    800b98 <sprintputch+0x33>
		*b->buf++ = ch;
  800b86:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b89:	8b 00                	mov    (%eax),%eax
  800b8b:	8d 48 01             	lea    0x1(%eax),%ecx
  800b8e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b91:	89 0a                	mov    %ecx,(%edx)
  800b93:	8b 55 08             	mov    0x8(%ebp),%edx
  800b96:	88 10                	mov    %dl,(%eax)
}
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    

00800b9a <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b9a:	55                   	push   %ebp
  800b9b:	89 e5                	mov    %esp,%ebp
  800b9d:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ba0:	8b 45 08             	mov    0x8(%ebp),%eax
  800ba3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ba6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ba9:	8d 50 ff             	lea    -0x1(%eax),%edx
  800bac:	8b 45 08             	mov    0x8(%ebp),%eax
  800baf:	01 d0                	add    %edx,%eax
  800bb1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800bb4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800bbb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800bbf:	74 06                	je     800bc7 <vsnprintf+0x2d>
  800bc1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800bc5:	7f 07                	jg     800bce <vsnprintf+0x34>
		return -E_INVAL;
  800bc7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800bcc:	eb 2a                	jmp    800bf8 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800bce:	8b 45 14             	mov    0x14(%ebp),%eax
  800bd1:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd8:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdc:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800bdf:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be3:	c7 04 24 65 0b 80 00 	movl   $0x800b65,(%esp)
  800bea:	e8 29 fb ff ff       	call   800718 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bef:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bf2:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf8:	c9                   	leave  
  800bf9:	c3                   	ret    

00800bfa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bfa:	55                   	push   %ebp
  800bfb:	89 e5                	mov    %esp,%ebp
  800bfd:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800c00:	8d 45 14             	lea    0x14(%ebp),%eax
  800c03:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800c06:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800c09:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800c0d:	8b 45 10             	mov    0x10(%ebp),%eax
  800c10:	89 44 24 08          	mov    %eax,0x8(%esp)
  800c14:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c17:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800c1e:	89 04 24             	mov    %eax,(%esp)
  800c21:	e8 74 ff ff ff       	call   800b9a <vsnprintf>
  800c26:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800c2c:	c9                   	leave  
  800c2d:	c3                   	ret    

00800c2e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800c34:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c3b:	eb 08                	jmp    800c45 <strlen+0x17>
		n++;
  800c3d:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c41:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c45:	8b 45 08             	mov    0x8(%ebp),%eax
  800c48:	0f b6 00             	movzbl (%eax),%eax
  800c4b:	84 c0                	test   %al,%al
  800c4d:	75 ee                	jne    800c3d <strlen+0xf>
		n++;
	return n;
  800c4f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c54:	55                   	push   %ebp
  800c55:	89 e5                	mov    %esp,%ebp
  800c57:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c5a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c61:	eb 0c                	jmp    800c6f <strnlen+0x1b>
		n++;
  800c63:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c67:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c6b:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c6f:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c73:	74 0a                	je     800c7f <strnlen+0x2b>
  800c75:	8b 45 08             	mov    0x8(%ebp),%eax
  800c78:	0f b6 00             	movzbl (%eax),%eax
  800c7b:	84 c0                	test   %al,%al
  800c7d:	75 e4                	jne    800c63 <strnlen+0xf>
		n++;
	return n;
  800c7f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c84:	55                   	push   %ebp
  800c85:	89 e5                	mov    %esp,%ebp
  800c87:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c90:	90                   	nop
  800c91:	8b 45 08             	mov    0x8(%ebp),%eax
  800c94:	8d 50 01             	lea    0x1(%eax),%edx
  800c97:	89 55 08             	mov    %edx,0x8(%ebp)
  800c9a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c9d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ca0:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800ca3:	0f b6 12             	movzbl (%edx),%edx
  800ca6:	88 10                	mov    %dl,(%eax)
  800ca8:	0f b6 00             	movzbl (%eax),%eax
  800cab:	84 c0                	test   %al,%al
  800cad:	75 e2                	jne    800c91 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800caf:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800cb2:	c9                   	leave  
  800cb3:	c3                   	ret    

00800cb4 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800cba:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbd:	89 04 24             	mov    %eax,(%esp)
  800cc0:	e8 69 ff ff ff       	call   800c2e <strlen>
  800cc5:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800cc8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800ccb:	8b 45 08             	mov    0x8(%ebp),%eax
  800cce:	01 c2                	add    %eax,%edx
  800cd0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800cd7:	89 14 24             	mov    %edx,(%esp)
  800cda:	e8 a5 ff ff ff       	call   800c84 <strcpy>
	return dst;
  800cdf:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ce2:	c9                   	leave  
  800ce3:	c3                   	ret    

00800ce4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ce4:	55                   	push   %ebp
  800ce5:	89 e5                	mov    %esp,%ebp
  800ce7:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cea:	8b 45 08             	mov    0x8(%ebp),%eax
  800ced:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cf0:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cf7:	eb 23                	jmp    800d1c <strncpy+0x38>
		*dst++ = *src;
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8d 50 01             	lea    0x1(%eax),%edx
  800cff:	89 55 08             	mov    %edx,0x8(%ebp)
  800d02:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d05:	0f b6 12             	movzbl (%edx),%edx
  800d08:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800d0a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d0d:	0f b6 00             	movzbl (%eax),%eax
  800d10:	84 c0                	test   %al,%al
  800d12:	74 04                	je     800d18 <strncpy+0x34>
			src++;
  800d14:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800d18:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800d1c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d1f:	3b 45 10             	cmp    0x10(%ebp),%eax
  800d22:	72 d5                	jb     800cf9 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800d24:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800d27:	c9                   	leave  
  800d28:	c3                   	ret    

00800d29 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800d2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d32:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d35:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d39:	74 33                	je     800d6e <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d3b:	eb 17                	jmp    800d54 <strlcpy+0x2b>
			*dst++ = *src++;
  800d3d:	8b 45 08             	mov    0x8(%ebp),%eax
  800d40:	8d 50 01             	lea    0x1(%eax),%edx
  800d43:	89 55 08             	mov    %edx,0x8(%ebp)
  800d46:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d49:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d4c:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d4f:	0f b6 12             	movzbl (%edx),%edx
  800d52:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d54:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d58:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d5c:	74 0a                	je     800d68 <strlcpy+0x3f>
  800d5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d61:	0f b6 00             	movzbl (%eax),%eax
  800d64:	84 c0                	test   %al,%al
  800d66:	75 d5                	jne    800d3d <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d68:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d6e:	8b 55 08             	mov    0x8(%ebp),%edx
  800d71:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d74:	29 c2                	sub    %eax,%edx
  800d76:	89 d0                	mov    %edx,%eax
}
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d7d:	eb 08                	jmp    800d87 <strcmp+0xd>
		p++, q++;
  800d7f:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d83:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d87:	8b 45 08             	mov    0x8(%ebp),%eax
  800d8a:	0f b6 00             	movzbl (%eax),%eax
  800d8d:	84 c0                	test   %al,%al
  800d8f:	74 10                	je     800da1 <strcmp+0x27>
  800d91:	8b 45 08             	mov    0x8(%ebp),%eax
  800d94:	0f b6 10             	movzbl (%eax),%edx
  800d97:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d9a:	0f b6 00             	movzbl (%eax),%eax
  800d9d:	38 c2                	cmp    %al,%dl
  800d9f:	74 de                	je     800d7f <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800da1:	8b 45 08             	mov    0x8(%ebp),%eax
  800da4:	0f b6 00             	movzbl (%eax),%eax
  800da7:	0f b6 d0             	movzbl %al,%edx
  800daa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dad:	0f b6 00             	movzbl (%eax),%eax
  800db0:	0f b6 c0             	movzbl %al,%eax
  800db3:	29 c2                	sub    %eax,%edx
  800db5:	89 d0                	mov    %edx,%eax
}
  800db7:	5d                   	pop    %ebp
  800db8:	c3                   	ret    

00800db9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800db9:	55                   	push   %ebp
  800dba:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800dbc:	eb 0c                	jmp    800dca <strncmp+0x11>
		n--, p++, q++;
  800dbe:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800dc2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dc6:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800dca:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dce:	74 1a                	je     800dea <strncmp+0x31>
  800dd0:	8b 45 08             	mov    0x8(%ebp),%eax
  800dd3:	0f b6 00             	movzbl (%eax),%eax
  800dd6:	84 c0                	test   %al,%al
  800dd8:	74 10                	je     800dea <strncmp+0x31>
  800dda:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddd:	0f b6 10             	movzbl (%eax),%edx
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	0f b6 00             	movzbl (%eax),%eax
  800de6:	38 c2                	cmp    %al,%dl
  800de8:	74 d4                	je     800dbe <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dea:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dee:	75 07                	jne    800df7 <strncmp+0x3e>
		return 0;
  800df0:	b8 00 00 00 00       	mov    $0x0,%eax
  800df5:	eb 16                	jmp    800e0d <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800df7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dfa:	0f b6 00             	movzbl (%eax),%eax
  800dfd:	0f b6 d0             	movzbl %al,%edx
  800e00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e03:	0f b6 00             	movzbl (%eax),%eax
  800e06:	0f b6 c0             	movzbl %al,%eax
  800e09:	29 c2                	sub    %eax,%edx
  800e0b:	89 d0                	mov    %edx,%eax
}
  800e0d:	5d                   	pop    %ebp
  800e0e:	c3                   	ret    

00800e0f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e0f:	55                   	push   %ebp
  800e10:	89 e5                	mov    %esp,%ebp
  800e12:	83 ec 04             	sub    $0x4,%esp
  800e15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e18:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e1b:	eb 14                	jmp    800e31 <strchr+0x22>
		if (*s == c)
  800e1d:	8b 45 08             	mov    0x8(%ebp),%eax
  800e20:	0f b6 00             	movzbl (%eax),%eax
  800e23:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e26:	75 05                	jne    800e2d <strchr+0x1e>
			return (char *) s;
  800e28:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2b:	eb 13                	jmp    800e40 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800e2d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e31:	8b 45 08             	mov    0x8(%ebp),%eax
  800e34:	0f b6 00             	movzbl (%eax),%eax
  800e37:	84 c0                	test   %al,%al
  800e39:	75 e2                	jne    800e1d <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e40:	c9                   	leave  
  800e41:	c3                   	ret    

00800e42 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 04             	sub    $0x4,%esp
  800e48:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e4b:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e4e:	eb 11                	jmp    800e61 <strfind+0x1f>
		if (*s == c)
  800e50:	8b 45 08             	mov    0x8(%ebp),%eax
  800e53:	0f b6 00             	movzbl (%eax),%eax
  800e56:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e59:	75 02                	jne    800e5d <strfind+0x1b>
			break;
  800e5b:	eb 0e                	jmp    800e6b <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e5d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e61:	8b 45 08             	mov    0x8(%ebp),%eax
  800e64:	0f b6 00             	movzbl (%eax),%eax
  800e67:	84 c0                	test   %al,%al
  800e69:	75 e5                	jne    800e50 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e6b:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e6e:	c9                   	leave  
  800e6f:	c3                   	ret    

00800e70 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e74:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e78:	75 05                	jne    800e7f <memset+0xf>
		return v;
  800e7a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e7d:	eb 5c                	jmp    800edb <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e82:	83 e0 03             	and    $0x3,%eax
  800e85:	85 c0                	test   %eax,%eax
  800e87:	75 41                	jne    800eca <memset+0x5a>
  800e89:	8b 45 10             	mov    0x10(%ebp),%eax
  800e8c:	83 e0 03             	and    $0x3,%eax
  800e8f:	85 c0                	test   %eax,%eax
  800e91:	75 37                	jne    800eca <memset+0x5a>
		c &= 0xFF;
  800e93:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9d:	c1 e0 18             	shl    $0x18,%eax
  800ea0:	89 c2                	mov    %eax,%edx
  800ea2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea5:	c1 e0 10             	shl    $0x10,%eax
  800ea8:	09 c2                	or     %eax,%edx
  800eaa:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ead:	c1 e0 08             	shl    $0x8,%eax
  800eb0:	09 d0                	or     %edx,%eax
  800eb2:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800eb5:	8b 45 10             	mov    0x10(%ebp),%eax
  800eb8:	c1 e8 02             	shr    $0x2,%eax
  800ebb:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800ebd:	8b 55 08             	mov    0x8(%ebp),%edx
  800ec0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ec3:	89 d7                	mov    %edx,%edi
  800ec5:	fc                   	cld    
  800ec6:	f3 ab                	rep stos %eax,%es:(%edi)
  800ec8:	eb 0e                	jmp    800ed8 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eca:	8b 55 08             	mov    0x8(%ebp),%edx
  800ecd:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed0:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800ed3:	89 d7                	mov    %edx,%edi
  800ed5:	fc                   	cld    
  800ed6:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ed8:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800edb:	5f                   	pop    %edi
  800edc:	5d                   	pop    %ebp
  800edd:	c3                   	ret    

00800ede <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	57                   	push   %edi
  800ee2:	56                   	push   %esi
  800ee3:	53                   	push   %ebx
  800ee4:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ee7:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eea:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eed:	8b 45 08             	mov    0x8(%ebp),%eax
  800ef0:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ef3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ef6:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ef9:	73 6d                	jae    800f68 <memmove+0x8a>
  800efb:	8b 45 10             	mov    0x10(%ebp),%eax
  800efe:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f01:	01 d0                	add    %edx,%eax
  800f03:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800f06:	76 60                	jbe    800f68 <memmove+0x8a>
		s += n;
  800f08:	8b 45 10             	mov    0x10(%ebp),%eax
  800f0b:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800f0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800f11:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f14:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f17:	83 e0 03             	and    $0x3,%eax
  800f1a:	85 c0                	test   %eax,%eax
  800f1c:	75 2f                	jne    800f4d <memmove+0x6f>
  800f1e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f21:	83 e0 03             	and    $0x3,%eax
  800f24:	85 c0                	test   %eax,%eax
  800f26:	75 25                	jne    800f4d <memmove+0x6f>
  800f28:	8b 45 10             	mov    0x10(%ebp),%eax
  800f2b:	83 e0 03             	and    $0x3,%eax
  800f2e:	85 c0                	test   %eax,%eax
  800f30:	75 1b                	jne    800f4d <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f32:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f35:	83 e8 04             	sub    $0x4,%eax
  800f38:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f3b:	83 ea 04             	sub    $0x4,%edx
  800f3e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f41:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f44:	89 c7                	mov    %eax,%edi
  800f46:	89 d6                	mov    %edx,%esi
  800f48:	fd                   	std    
  800f49:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f4b:	eb 18                	jmp    800f65 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f50:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f53:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f56:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f59:	8b 45 10             	mov    0x10(%ebp),%eax
  800f5c:	89 d7                	mov    %edx,%edi
  800f5e:	89 de                	mov    %ebx,%esi
  800f60:	89 c1                	mov    %eax,%ecx
  800f62:	fd                   	std    
  800f63:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f65:	fc                   	cld    
  800f66:	eb 45                	jmp    800fad <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f68:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f6b:	83 e0 03             	and    $0x3,%eax
  800f6e:	85 c0                	test   %eax,%eax
  800f70:	75 2b                	jne    800f9d <memmove+0xbf>
  800f72:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f75:	83 e0 03             	and    $0x3,%eax
  800f78:	85 c0                	test   %eax,%eax
  800f7a:	75 21                	jne    800f9d <memmove+0xbf>
  800f7c:	8b 45 10             	mov    0x10(%ebp),%eax
  800f7f:	83 e0 03             	and    $0x3,%eax
  800f82:	85 c0                	test   %eax,%eax
  800f84:	75 17                	jne    800f9d <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f86:	8b 45 10             	mov    0x10(%ebp),%eax
  800f89:	c1 e8 02             	shr    $0x2,%eax
  800f8c:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f8e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f91:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f94:	89 c7                	mov    %eax,%edi
  800f96:	89 d6                	mov    %edx,%esi
  800f98:	fc                   	cld    
  800f99:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f9b:	eb 10                	jmp    800fad <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f9d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800fa0:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800fa3:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800fa6:	89 c7                	mov    %eax,%edi
  800fa8:	89 d6                	mov    %edx,%esi
  800faa:	fc                   	cld    
  800fab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800fad:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	5b                   	pop    %ebx
  800fb4:	5e                   	pop    %esi
  800fb5:	5f                   	pop    %edi
  800fb6:	5d                   	pop    %ebp
  800fb7:	c3                   	ret    

00800fb8 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800fbe:	8b 45 10             	mov    0x10(%ebp),%eax
  800fc1:	89 44 24 08          	mov    %eax,0x8(%esp)
  800fc5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fc8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800fcc:	8b 45 08             	mov    0x8(%ebp),%eax
  800fcf:	89 04 24             	mov    %eax,(%esp)
  800fd2:	e8 07 ff ff ff       	call   800ede <memmove>
}
  800fd7:	c9                   	leave  
  800fd8:	c3                   	ret    

00800fd9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fd9:	55                   	push   %ebp
  800fda:	89 e5                	mov    %esp,%ebp
  800fdc:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800fe2:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fe5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fe8:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800feb:	eb 30                	jmp    80101d <memcmp+0x44>
		if (*s1 != *s2)
  800fed:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ff0:	0f b6 10             	movzbl (%eax),%edx
  800ff3:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800ff6:	0f b6 00             	movzbl (%eax),%eax
  800ff9:	38 c2                	cmp    %al,%dl
  800ffb:	74 18                	je     801015 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800ffd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  801000:	0f b6 00             	movzbl (%eax),%eax
  801003:	0f b6 d0             	movzbl %al,%edx
  801006:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801009:	0f b6 00             	movzbl (%eax),%eax
  80100c:	0f b6 c0             	movzbl %al,%eax
  80100f:	29 c2                	sub    %eax,%edx
  801011:	89 d0                	mov    %edx,%eax
  801013:	eb 1a                	jmp    80102f <memcmp+0x56>
		s1++, s2++;
  801015:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  801019:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80101d:	8b 45 10             	mov    0x10(%ebp),%eax
  801020:	8d 50 ff             	lea    -0x1(%eax),%edx
  801023:	89 55 10             	mov    %edx,0x10(%ebp)
  801026:	85 c0                	test   %eax,%eax
  801028:	75 c3                	jne    800fed <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80102a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80102f:	c9                   	leave  
  801030:	c3                   	ret    

00801031 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801031:	55                   	push   %ebp
  801032:	89 e5                	mov    %esp,%ebp
  801034:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801037:	8b 45 10             	mov    0x10(%ebp),%eax
  80103a:	8b 55 08             	mov    0x8(%ebp),%edx
  80103d:	01 d0                	add    %edx,%eax
  80103f:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801042:	eb 13                	jmp    801057 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801044:	8b 45 08             	mov    0x8(%ebp),%eax
  801047:	0f b6 10             	movzbl (%eax),%edx
  80104a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80104d:	38 c2                	cmp    %al,%dl
  80104f:	75 02                	jne    801053 <memfind+0x22>
			break;
  801051:	eb 0c                	jmp    80105f <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801053:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801057:	8b 45 08             	mov    0x8(%ebp),%eax
  80105a:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80105d:	72 e5                	jb     801044 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80105f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801062:	c9                   	leave  
  801063:	c3                   	ret    

00801064 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801064:	55                   	push   %ebp
  801065:	89 e5                	mov    %esp,%ebp
  801067:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80106a:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801071:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801078:	eb 04                	jmp    80107e <strtol+0x1a>
		s++;
  80107a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80107e:	8b 45 08             	mov    0x8(%ebp),%eax
  801081:	0f b6 00             	movzbl (%eax),%eax
  801084:	3c 20                	cmp    $0x20,%al
  801086:	74 f2                	je     80107a <strtol+0x16>
  801088:	8b 45 08             	mov    0x8(%ebp),%eax
  80108b:	0f b6 00             	movzbl (%eax),%eax
  80108e:	3c 09                	cmp    $0x9,%al
  801090:	74 e8                	je     80107a <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801092:	8b 45 08             	mov    0x8(%ebp),%eax
  801095:	0f b6 00             	movzbl (%eax),%eax
  801098:	3c 2b                	cmp    $0x2b,%al
  80109a:	75 06                	jne    8010a2 <strtol+0x3e>
		s++;
  80109c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010a0:	eb 15                	jmp    8010b7 <strtol+0x53>
	else if (*s == '-')
  8010a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8010a5:	0f b6 00             	movzbl (%eax),%eax
  8010a8:	3c 2d                	cmp    $0x2d,%al
  8010aa:	75 0b                	jne    8010b7 <strtol+0x53>
		s++, neg = 1;
  8010ac:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010b0:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8010b7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010bb:	74 06                	je     8010c3 <strtol+0x5f>
  8010bd:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  8010c1:	75 24                	jne    8010e7 <strtol+0x83>
  8010c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8010c6:	0f b6 00             	movzbl (%eax),%eax
  8010c9:	3c 30                	cmp    $0x30,%al
  8010cb:	75 1a                	jne    8010e7 <strtol+0x83>
  8010cd:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d0:	83 c0 01             	add    $0x1,%eax
  8010d3:	0f b6 00             	movzbl (%eax),%eax
  8010d6:	3c 78                	cmp    $0x78,%al
  8010d8:	75 0d                	jne    8010e7 <strtol+0x83>
		s += 2, base = 16;
  8010da:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010de:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010e5:	eb 2a                	jmp    801111 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010e7:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010eb:	75 17                	jne    801104 <strtol+0xa0>
  8010ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f0:	0f b6 00             	movzbl (%eax),%eax
  8010f3:	3c 30                	cmp    $0x30,%al
  8010f5:	75 0d                	jne    801104 <strtol+0xa0>
		s++, base = 8;
  8010f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010fb:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  801102:	eb 0d                	jmp    801111 <strtol+0xad>
	else if (base == 0)
  801104:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801108:	75 07                	jne    801111 <strtol+0xad>
		base = 10;
  80110a:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  801111:	8b 45 08             	mov    0x8(%ebp),%eax
  801114:	0f b6 00             	movzbl (%eax),%eax
  801117:	3c 2f                	cmp    $0x2f,%al
  801119:	7e 1b                	jle    801136 <strtol+0xd2>
  80111b:	8b 45 08             	mov    0x8(%ebp),%eax
  80111e:	0f b6 00             	movzbl (%eax),%eax
  801121:	3c 39                	cmp    $0x39,%al
  801123:	7f 11                	jg     801136 <strtol+0xd2>
			dig = *s - '0';
  801125:	8b 45 08             	mov    0x8(%ebp),%eax
  801128:	0f b6 00             	movzbl (%eax),%eax
  80112b:	0f be c0             	movsbl %al,%eax
  80112e:	83 e8 30             	sub    $0x30,%eax
  801131:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801134:	eb 48                	jmp    80117e <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801136:	8b 45 08             	mov    0x8(%ebp),%eax
  801139:	0f b6 00             	movzbl (%eax),%eax
  80113c:	3c 60                	cmp    $0x60,%al
  80113e:	7e 1b                	jle    80115b <strtol+0xf7>
  801140:	8b 45 08             	mov    0x8(%ebp),%eax
  801143:	0f b6 00             	movzbl (%eax),%eax
  801146:	3c 7a                	cmp    $0x7a,%al
  801148:	7f 11                	jg     80115b <strtol+0xf7>
			dig = *s - 'a' + 10;
  80114a:	8b 45 08             	mov    0x8(%ebp),%eax
  80114d:	0f b6 00             	movzbl (%eax),%eax
  801150:	0f be c0             	movsbl %al,%eax
  801153:	83 e8 57             	sub    $0x57,%eax
  801156:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801159:	eb 23                	jmp    80117e <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80115b:	8b 45 08             	mov    0x8(%ebp),%eax
  80115e:	0f b6 00             	movzbl (%eax),%eax
  801161:	3c 40                	cmp    $0x40,%al
  801163:	7e 3d                	jle    8011a2 <strtol+0x13e>
  801165:	8b 45 08             	mov    0x8(%ebp),%eax
  801168:	0f b6 00             	movzbl (%eax),%eax
  80116b:	3c 5a                	cmp    $0x5a,%al
  80116d:	7f 33                	jg     8011a2 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80116f:	8b 45 08             	mov    0x8(%ebp),%eax
  801172:	0f b6 00             	movzbl (%eax),%eax
  801175:	0f be c0             	movsbl %al,%eax
  801178:	83 e8 37             	sub    $0x37,%eax
  80117b:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80117e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801181:	3b 45 10             	cmp    0x10(%ebp),%eax
  801184:	7c 02                	jl     801188 <strtol+0x124>
			break;
  801186:	eb 1a                	jmp    8011a2 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801188:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80118c:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80118f:	0f af 45 10          	imul   0x10(%ebp),%eax
  801193:	89 c2                	mov    %eax,%edx
  801195:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801198:	01 d0                	add    %edx,%eax
  80119a:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80119d:	e9 6f ff ff ff       	jmp    801111 <strtol+0xad>

	if (endptr)
  8011a2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8011a6:	74 08                	je     8011b0 <strtol+0x14c>
		*endptr = (char *) s;
  8011a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8011ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8011ae:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  8011b0:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  8011b4:	74 07                	je     8011bd <strtol+0x159>
  8011b6:	8b 45 f8             	mov    -0x8(%ebp),%eax
  8011b9:	f7 d8                	neg    %eax
  8011bb:	eb 03                	jmp    8011c0 <strtol+0x15c>
  8011bd:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  8011c0:	c9                   	leave  
  8011c1:	c3                   	ret    

008011c2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8011c2:	55                   	push   %ebp
  8011c3:	89 e5                	mov    %esp,%ebp
  8011c5:	83 ec 28             	sub    $0x28,%esp
	int r;

	if (_pgfault_handler == 0) {
  8011c8:	a1 08 20 80 00       	mov    0x802008,%eax
  8011cd:	85 c0                	test   %eax,%eax
  8011cf:	75 55                	jne    801226 <set_pgfault_handler+0x64>
		// First time through!
		// LAB 4: Your code here.
		r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE),PTE_U|PTE_P|PTE_W);
  8011d1:	c7 44 24 08 07 00 00 	movl   $0x7,0x8(%esp)
  8011d8:	00 
  8011d9:	c7 44 24 04 00 f0 bf 	movl   $0xeebff000,0x4(%esp)
  8011e0:	ee 
  8011e1:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8011e8:	e8 81 f0 ff ff       	call   80026e <sys_page_alloc>
  8011ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
		if(r < 0)
  8011f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
  8011f4:	79 1c                	jns    801212 <set_pgfault_handler+0x50>
		{
			panic("sys_page_alloc_failed");
  8011f6:	c7 44 24 08 64 17 80 	movl   $0x801764,0x8(%esp)
  8011fd:	00 
  8011fe:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  801205:	00 
  801206:	c7 04 24 7a 17 80 00 	movl   $0x80177a,(%esp)
  80120d:	e8 51 f2 ff ff       	call   800463 <_panic>
		}
		sys_env_set_pgfault_upcall(0, _pgfault_upcall);
  801212:	c7 44 24 04 3e 04 80 	movl   $0x80043e,0x4(%esp)
  801219:	00 
  80121a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  801221:	e8 53 f1 ff ff       	call   800379 <sys_env_set_pgfault_upcall>
		// panic("set_pgfault_handler not implemented");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  801226:	8b 45 08             	mov    0x8(%ebp),%eax
  801229:	a3 08 20 80 00       	mov    %eax,0x802008
}
  80122e:	c9                   	leave  
  80122f:	c3                   	ret    

00801230 <__udivdi3>:
  801230:	55                   	push   %ebp
  801231:	57                   	push   %edi
  801232:	56                   	push   %esi
  801233:	83 ec 0c             	sub    $0xc,%esp
  801236:	8b 44 24 28          	mov    0x28(%esp),%eax
  80123a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80123e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  801242:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  801246:	85 c0                	test   %eax,%eax
  801248:	89 7c 24 04          	mov    %edi,0x4(%esp)
  80124c:	89 ea                	mov    %ebp,%edx
  80124e:	89 0c 24             	mov    %ecx,(%esp)
  801251:	75 2d                	jne    801280 <__udivdi3+0x50>
  801253:	39 e9                	cmp    %ebp,%ecx
  801255:	77 61                	ja     8012b8 <__udivdi3+0x88>
  801257:	85 c9                	test   %ecx,%ecx
  801259:	89 ce                	mov    %ecx,%esi
  80125b:	75 0b                	jne    801268 <__udivdi3+0x38>
  80125d:	b8 01 00 00 00       	mov    $0x1,%eax
  801262:	31 d2                	xor    %edx,%edx
  801264:	f7 f1                	div    %ecx
  801266:	89 c6                	mov    %eax,%esi
  801268:	31 d2                	xor    %edx,%edx
  80126a:	89 e8                	mov    %ebp,%eax
  80126c:	f7 f6                	div    %esi
  80126e:	89 c5                	mov    %eax,%ebp
  801270:	89 f8                	mov    %edi,%eax
  801272:	f7 f6                	div    %esi
  801274:	89 ea                	mov    %ebp,%edx
  801276:	83 c4 0c             	add    $0xc,%esp
  801279:	5e                   	pop    %esi
  80127a:	5f                   	pop    %edi
  80127b:	5d                   	pop    %ebp
  80127c:	c3                   	ret    
  80127d:	8d 76 00             	lea    0x0(%esi),%esi
  801280:	39 e8                	cmp    %ebp,%eax
  801282:	77 24                	ja     8012a8 <__udivdi3+0x78>
  801284:	0f bd e8             	bsr    %eax,%ebp
  801287:	83 f5 1f             	xor    $0x1f,%ebp
  80128a:	75 3c                	jne    8012c8 <__udivdi3+0x98>
  80128c:	8b 74 24 04          	mov    0x4(%esp),%esi
  801290:	39 34 24             	cmp    %esi,(%esp)
  801293:	0f 86 9f 00 00 00    	jbe    801338 <__udivdi3+0x108>
  801299:	39 d0                	cmp    %edx,%eax
  80129b:	0f 82 97 00 00 00    	jb     801338 <__udivdi3+0x108>
  8012a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	31 d2                	xor    %edx,%edx
  8012aa:	31 c0                	xor    %eax,%eax
  8012ac:	83 c4 0c             	add    $0xc,%esp
  8012af:	5e                   	pop    %esi
  8012b0:	5f                   	pop    %edi
  8012b1:	5d                   	pop    %ebp
  8012b2:	c3                   	ret    
  8012b3:	90                   	nop
  8012b4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012b8:	89 f8                	mov    %edi,%eax
  8012ba:	f7 f1                	div    %ecx
  8012bc:	31 d2                	xor    %edx,%edx
  8012be:	83 c4 0c             	add    $0xc,%esp
  8012c1:	5e                   	pop    %esi
  8012c2:	5f                   	pop    %edi
  8012c3:	5d                   	pop    %ebp
  8012c4:	c3                   	ret    
  8012c5:	8d 76 00             	lea    0x0(%esi),%esi
  8012c8:	89 e9                	mov    %ebp,%ecx
  8012ca:	8b 3c 24             	mov    (%esp),%edi
  8012cd:	d3 e0                	shl    %cl,%eax
  8012cf:	89 c6                	mov    %eax,%esi
  8012d1:	b8 20 00 00 00       	mov    $0x20,%eax
  8012d6:	29 e8                	sub    %ebp,%eax
  8012d8:	89 c1                	mov    %eax,%ecx
  8012da:	d3 ef                	shr    %cl,%edi
  8012dc:	89 e9                	mov    %ebp,%ecx
  8012de:	89 7c 24 08          	mov    %edi,0x8(%esp)
  8012e2:	8b 3c 24             	mov    (%esp),%edi
  8012e5:	09 74 24 08          	or     %esi,0x8(%esp)
  8012e9:	89 d6                	mov    %edx,%esi
  8012eb:	d3 e7                	shl    %cl,%edi
  8012ed:	89 c1                	mov    %eax,%ecx
  8012ef:	89 3c 24             	mov    %edi,(%esp)
  8012f2:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8012f6:	d3 ee                	shr    %cl,%esi
  8012f8:	89 e9                	mov    %ebp,%ecx
  8012fa:	d3 e2                	shl    %cl,%edx
  8012fc:	89 c1                	mov    %eax,%ecx
  8012fe:	d3 ef                	shr    %cl,%edi
  801300:	09 d7                	or     %edx,%edi
  801302:	89 f2                	mov    %esi,%edx
  801304:	89 f8                	mov    %edi,%eax
  801306:	f7 74 24 08          	divl   0x8(%esp)
  80130a:	89 d6                	mov    %edx,%esi
  80130c:	89 c7                	mov    %eax,%edi
  80130e:	f7 24 24             	mull   (%esp)
  801311:	39 d6                	cmp    %edx,%esi
  801313:	89 14 24             	mov    %edx,(%esp)
  801316:	72 30                	jb     801348 <__udivdi3+0x118>
  801318:	8b 54 24 04          	mov    0x4(%esp),%edx
  80131c:	89 e9                	mov    %ebp,%ecx
  80131e:	d3 e2                	shl    %cl,%edx
  801320:	39 c2                	cmp    %eax,%edx
  801322:	73 05                	jae    801329 <__udivdi3+0xf9>
  801324:	3b 34 24             	cmp    (%esp),%esi
  801327:	74 1f                	je     801348 <__udivdi3+0x118>
  801329:	89 f8                	mov    %edi,%eax
  80132b:	31 d2                	xor    %edx,%edx
  80132d:	e9 7a ff ff ff       	jmp    8012ac <__udivdi3+0x7c>
  801332:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801338:	31 d2                	xor    %edx,%edx
  80133a:	b8 01 00 00 00       	mov    $0x1,%eax
  80133f:	e9 68 ff ff ff       	jmp    8012ac <__udivdi3+0x7c>
  801344:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801348:	8d 47 ff             	lea    -0x1(%edi),%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	83 c4 0c             	add    $0xc,%esp
  801350:	5e                   	pop    %esi
  801351:	5f                   	pop    %edi
  801352:	5d                   	pop    %ebp
  801353:	c3                   	ret    
  801354:	66 90                	xchg   %ax,%ax
  801356:	66 90                	xchg   %ax,%ax
  801358:	66 90                	xchg   %ax,%ax
  80135a:	66 90                	xchg   %ax,%ax
  80135c:	66 90                	xchg   %ax,%ax
  80135e:	66 90                	xchg   %ax,%ax

00801360 <__umoddi3>:
  801360:	55                   	push   %ebp
  801361:	57                   	push   %edi
  801362:	56                   	push   %esi
  801363:	83 ec 14             	sub    $0x14,%esp
  801366:	8b 44 24 28          	mov    0x28(%esp),%eax
  80136a:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  80136e:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  801372:	89 c7                	mov    %eax,%edi
  801374:	89 44 24 04          	mov    %eax,0x4(%esp)
  801378:	8b 44 24 30          	mov    0x30(%esp),%eax
  80137c:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  801380:	89 34 24             	mov    %esi,(%esp)
  801383:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801387:	85 c0                	test   %eax,%eax
  801389:	89 c2                	mov    %eax,%edx
  80138b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80138f:	75 17                	jne    8013a8 <__umoddi3+0x48>
  801391:	39 fe                	cmp    %edi,%esi
  801393:	76 4b                	jbe    8013e0 <__umoddi3+0x80>
  801395:	89 c8                	mov    %ecx,%eax
  801397:	89 fa                	mov    %edi,%edx
  801399:	f7 f6                	div    %esi
  80139b:	89 d0                	mov    %edx,%eax
  80139d:	31 d2                	xor    %edx,%edx
  80139f:	83 c4 14             	add    $0x14,%esp
  8013a2:	5e                   	pop    %esi
  8013a3:	5f                   	pop    %edi
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    
  8013a6:	66 90                	xchg   %ax,%ax
  8013a8:	39 f8                	cmp    %edi,%eax
  8013aa:	77 54                	ja     801400 <__umoddi3+0xa0>
  8013ac:	0f bd e8             	bsr    %eax,%ebp
  8013af:	83 f5 1f             	xor    $0x1f,%ebp
  8013b2:	75 5c                	jne    801410 <__umoddi3+0xb0>
  8013b4:	8b 7c 24 08          	mov    0x8(%esp),%edi
  8013b8:	39 3c 24             	cmp    %edi,(%esp)
  8013bb:	0f 87 e7 00 00 00    	ja     8014a8 <__umoddi3+0x148>
  8013c1:	8b 7c 24 04          	mov    0x4(%esp),%edi
  8013c5:	29 f1                	sub    %esi,%ecx
  8013c7:	19 c7                	sbb    %eax,%edi
  8013c9:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8013cd:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013d1:	8b 44 24 08          	mov    0x8(%esp),%eax
  8013d5:	8b 54 24 0c          	mov    0xc(%esp),%edx
  8013d9:	83 c4 14             	add    $0x14,%esp
  8013dc:	5e                   	pop    %esi
  8013dd:	5f                   	pop    %edi
  8013de:	5d                   	pop    %ebp
  8013df:	c3                   	ret    
  8013e0:	85 f6                	test   %esi,%esi
  8013e2:	89 f5                	mov    %esi,%ebp
  8013e4:	75 0b                	jne    8013f1 <__umoddi3+0x91>
  8013e6:	b8 01 00 00 00       	mov    $0x1,%eax
  8013eb:	31 d2                	xor    %edx,%edx
  8013ed:	f7 f6                	div    %esi
  8013ef:	89 c5                	mov    %eax,%ebp
  8013f1:	8b 44 24 04          	mov    0x4(%esp),%eax
  8013f5:	31 d2                	xor    %edx,%edx
  8013f7:	f7 f5                	div    %ebp
  8013f9:	89 c8                	mov    %ecx,%eax
  8013fb:	f7 f5                	div    %ebp
  8013fd:	eb 9c                	jmp    80139b <__umoddi3+0x3b>
  8013ff:	90                   	nop
  801400:	89 c8                	mov    %ecx,%eax
  801402:	89 fa                	mov    %edi,%edx
  801404:	83 c4 14             	add    $0x14,%esp
  801407:	5e                   	pop    %esi
  801408:	5f                   	pop    %edi
  801409:	5d                   	pop    %ebp
  80140a:	c3                   	ret    
  80140b:	90                   	nop
  80140c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801410:	8b 04 24             	mov    (%esp),%eax
  801413:	be 20 00 00 00       	mov    $0x20,%esi
  801418:	89 e9                	mov    %ebp,%ecx
  80141a:	29 ee                	sub    %ebp,%esi
  80141c:	d3 e2                	shl    %cl,%edx
  80141e:	89 f1                	mov    %esi,%ecx
  801420:	d3 e8                	shr    %cl,%eax
  801422:	89 e9                	mov    %ebp,%ecx
  801424:	89 44 24 04          	mov    %eax,0x4(%esp)
  801428:	8b 04 24             	mov    (%esp),%eax
  80142b:	09 54 24 04          	or     %edx,0x4(%esp)
  80142f:	89 fa                	mov    %edi,%edx
  801431:	d3 e0                	shl    %cl,%eax
  801433:	89 f1                	mov    %esi,%ecx
  801435:	89 44 24 08          	mov    %eax,0x8(%esp)
  801439:	8b 44 24 10          	mov    0x10(%esp),%eax
  80143d:	d3 ea                	shr    %cl,%edx
  80143f:	89 e9                	mov    %ebp,%ecx
  801441:	d3 e7                	shl    %cl,%edi
  801443:	89 f1                	mov    %esi,%ecx
  801445:	d3 e8                	shr    %cl,%eax
  801447:	89 e9                	mov    %ebp,%ecx
  801449:	09 f8                	or     %edi,%eax
  80144b:	8b 7c 24 10          	mov    0x10(%esp),%edi
  80144f:	f7 74 24 04          	divl   0x4(%esp)
  801453:	d3 e7                	shl    %cl,%edi
  801455:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801459:	89 d7                	mov    %edx,%edi
  80145b:	f7 64 24 08          	mull   0x8(%esp)
  80145f:	39 d7                	cmp    %edx,%edi
  801461:	89 c1                	mov    %eax,%ecx
  801463:	89 14 24             	mov    %edx,(%esp)
  801466:	72 2c                	jb     801494 <__umoddi3+0x134>
  801468:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  80146c:	72 22                	jb     801490 <__umoddi3+0x130>
  80146e:	8b 44 24 0c          	mov    0xc(%esp),%eax
  801472:	29 c8                	sub    %ecx,%eax
  801474:	19 d7                	sbb    %edx,%edi
  801476:	89 e9                	mov    %ebp,%ecx
  801478:	89 fa                	mov    %edi,%edx
  80147a:	d3 e8                	shr    %cl,%eax
  80147c:	89 f1                	mov    %esi,%ecx
  80147e:	d3 e2                	shl    %cl,%edx
  801480:	89 e9                	mov    %ebp,%ecx
  801482:	d3 ef                	shr    %cl,%edi
  801484:	09 d0                	or     %edx,%eax
  801486:	89 fa                	mov    %edi,%edx
  801488:	83 c4 14             	add    $0x14,%esp
  80148b:	5e                   	pop    %esi
  80148c:	5f                   	pop    %edi
  80148d:	5d                   	pop    %ebp
  80148e:	c3                   	ret    
  80148f:	90                   	nop
  801490:	39 d7                	cmp    %edx,%edi
  801492:	75 da                	jne    80146e <__umoddi3+0x10e>
  801494:	8b 14 24             	mov    (%esp),%edx
  801497:	89 c1                	mov    %eax,%ecx
  801499:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  80149d:	1b 54 24 04          	sbb    0x4(%esp),%edx
  8014a1:	eb cb                	jmp    80146e <__umoddi3+0x10e>
  8014a3:	90                   	nop
  8014a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8014a8:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  8014ac:	0f 82 0f ff ff ff    	jb     8013c1 <__umoddi3+0x61>
  8014b2:	e9 1a ff ff ff       	jmp    8013d1 <__umoddi3+0x71>
