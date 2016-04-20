
obj/user/idle:     file format elf32-i386


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
  80002c:	e8 19 00 00 00       	call   80004a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#include <inc/x86.h>
#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 08             	sub    $0x8,%esp
	binaryname = "idle";
  800039:	c7 05 00 20 80 00 20 	movl   $0x801420,0x802000
  800040:	14 80 00 
	// Instead of busy-waiting like this,
	// a better way would be to use the processor's HLT instruction
	// to cause the processor to stop executing until the next interrupt -
	// doing so allows the processor to conserve power more effectively.
	while (1) {
		sys_yield();
  800043:	e8 d2 01 00 00       	call   80021a <sys_yield>
	}
  800048:	eb f9                	jmp    800043 <umain+0x10>

0080004a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004a:	55                   	push   %ebp
  80004b:	89 e5                	mov    %esp,%ebp
  80004d:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800050:	e8 81 01 00 00       	call   8001d6 <sys_getenvid>
  800055:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005a:	c1 e0 02             	shl    $0x2,%eax
  80005d:	89 c2                	mov    %eax,%edx
  80005f:	c1 e2 05             	shl    $0x5,%edx
  800062:	29 c2                	sub    %eax,%edx
  800064:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80006a:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800073:	7e 0a                	jle    80007f <libmain+0x35>
		binaryname = argv[0];
  800075:	8b 45 0c             	mov    0xc(%ebp),%eax
  800078:	8b 00                	mov    (%eax),%eax
  80007a:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  80007f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800082:	89 44 24 04          	mov    %eax,0x4(%esp)
  800086:	8b 45 08             	mov    0x8(%ebp),%eax
  800089:	89 04 24             	mov    %eax,(%esp)
  80008c:	e8 a2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800091:	e8 02 00 00 00       	call   800098 <exit>
}
  800096:	c9                   	leave  
  800097:	c3                   	ret    

00800098 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800098:	55                   	push   %ebp
  800099:	89 e5                	mov    %esp,%ebp
  80009b:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  80009e:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000a5:	e8 e9 00 00 00       	call   800193 <sys_env_destroy>
}
  8000aa:	c9                   	leave  
  8000ab:	c3                   	ret    

008000ac <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ac:	55                   	push   %ebp
  8000ad:	89 e5                	mov    %esp,%ebp
  8000af:	57                   	push   %edi
  8000b0:	56                   	push   %esi
  8000b1:	53                   	push   %ebx
  8000b2:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b8:	8b 55 10             	mov    0x10(%ebp),%edx
  8000bb:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000be:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000c1:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000c4:	8b 75 20             	mov    0x20(%ebp),%esi
  8000c7:	cd 30                	int    $0x30
  8000c9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000cc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000d0:	74 30                	je     800102 <syscall+0x56>
  8000d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d6:	7e 2a                	jle    800102 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000db:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000df:	8b 45 08             	mov    0x8(%ebp),%eax
  8000e2:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000e6:	c7 44 24 08 2f 14 80 	movl   $0x80142f,0x8(%esp)
  8000ed:	00 
  8000ee:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000f5:	00 
  8000f6:	c7 04 24 4c 14 80 00 	movl   $0x80144c,(%esp)
  8000fd:	e8 2c 03 00 00       	call   80042e <_panic>

	return ret;
  800102:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  800105:	83 c4 3c             	add    $0x3c,%esp
  800108:	5b                   	pop    %ebx
  800109:	5e                   	pop    %esi
  80010a:	5f                   	pop    %edi
  80010b:	5d                   	pop    %ebp
  80010c:	c3                   	ret    

0080010d <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80010d:	55                   	push   %ebp
  80010e:	89 e5                	mov    %esp,%ebp
  800110:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800113:	8b 45 08             	mov    0x8(%ebp),%eax
  800116:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80011d:	00 
  80011e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800125:	00 
  800126:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80012d:	00 
  80012e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800131:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800135:	89 44 24 08          	mov    %eax,0x8(%esp)
  800139:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800140:	00 
  800141:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800148:	e8 5f ff ff ff       	call   8000ac <syscall>
}
  80014d:	c9                   	leave  
  80014e:	c3                   	ret    

0080014f <sys_cgetc>:

int
sys_cgetc(void)
{
  80014f:	55                   	push   %ebp
  800150:	89 e5                	mov    %esp,%ebp
  800152:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800155:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80015c:	00 
  80015d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800164:	00 
  800165:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80016c:	00 
  80016d:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800174:	00 
  800175:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80017c:	00 
  80017d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800184:	00 
  800185:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80018c:	e8 1b ff ff ff       	call   8000ac <syscall>
}
  800191:	c9                   	leave  
  800192:	c3                   	ret    

00800193 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800199:	8b 45 08             	mov    0x8(%ebp),%eax
  80019c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001a3:	00 
  8001a4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001ab:	00 
  8001ac:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001b3:	00 
  8001b4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001bb:	00 
  8001bc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001c0:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c7:	00 
  8001c8:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001cf:	e8 d8 fe ff ff       	call   8000ac <syscall>
}
  8001d4:	c9                   	leave  
  8001d5:	c3                   	ret    

008001d6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001dc:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001e3:	00 
  8001e4:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001eb:	00 
  8001ec:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001f3:	00 
  8001f4:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001fb:	00 
  8001fc:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800203:	00 
  800204:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80020b:	00 
  80020c:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800213:	e8 94 fe ff ff       	call   8000ac <syscall>
}
  800218:	c9                   	leave  
  800219:	c3                   	ret    

0080021a <sys_yield>:

void
sys_yield(void)
{
  80021a:	55                   	push   %ebp
  80021b:	89 e5                	mov    %esp,%ebp
  80021d:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800220:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800227:	00 
  800228:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80022f:	00 
  800230:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800237:	00 
  800238:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80023f:	00 
  800240:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800247:	00 
  800248:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80024f:	00 
  800250:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800257:	e8 50 fe ff ff       	call   8000ac <syscall>
}
  80025c:	c9                   	leave  
  80025d:	c3                   	ret    

0080025e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800264:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800267:	8b 55 0c             	mov    0xc(%ebp),%edx
  80026a:	8b 45 08             	mov    0x8(%ebp),%eax
  80026d:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800274:	00 
  800275:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80027c:	00 
  80027d:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800281:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800285:	89 44 24 08          	mov    %eax,0x8(%esp)
  800289:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800290:	00 
  800291:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800298:	e8 0f fe ff ff       	call   8000ac <syscall>
}
  80029d:	c9                   	leave  
  80029e:	c3                   	ret    

0080029f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80029f:	55                   	push   %ebp
  8002a0:	89 e5                	mov    %esp,%ebp
  8002a2:	56                   	push   %esi
  8002a3:	53                   	push   %ebx
  8002a4:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002a7:	8b 75 18             	mov    0x18(%ebp),%esi
  8002aa:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002ad:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b6:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002ba:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002be:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002c2:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002c6:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002ca:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002d1:	00 
  8002d2:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002d9:	e8 ce fd ff ff       	call   8000ac <syscall>
}
  8002de:	83 c4 20             	add    $0x20,%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5d                   	pop    %ebp
  8002e4:	c3                   	ret    

008002e5 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002e5:	55                   	push   %ebp
  8002e6:	89 e5                	mov    %esp,%ebp
  8002e8:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ee:	8b 45 08             	mov    0x8(%ebp),%eax
  8002f1:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002f8:	00 
  8002f9:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800300:	00 
  800301:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800308:	00 
  800309:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80030d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800311:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800318:	00 
  800319:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800320:	e8 87 fd ff ff       	call   8000ac <syscall>
}
  800325:	c9                   	leave  
  800326:	c3                   	ret    

00800327 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80032d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800330:	8b 45 08             	mov    0x8(%ebp),%eax
  800333:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80033a:	00 
  80033b:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800342:	00 
  800343:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80034a:	00 
  80034b:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80034f:	89 44 24 08          	mov    %eax,0x8(%esp)
  800353:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80035a:	00 
  80035b:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800362:	e8 45 fd ff ff       	call   8000ac <syscall>
}
  800367:	c9                   	leave  
  800368:	c3                   	ret    

00800369 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800369:	55                   	push   %ebp
  80036a:	89 e5                	mov    %esp,%ebp
  80036c:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80036f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800372:	8b 45 08             	mov    0x8(%ebp),%eax
  800375:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80037c:	00 
  80037d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800384:	00 
  800385:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80038c:	00 
  80038d:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800391:	89 44 24 08          	mov    %eax,0x8(%esp)
  800395:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80039c:	00 
  80039d:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  8003a4:	e8 03 fd ff ff       	call   8000ac <syscall>
}
  8003a9:	c9                   	leave  
  8003aa:	c3                   	ret    

008003ab <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003ab:	55                   	push   %ebp
  8003ac:	89 e5                	mov    %esp,%ebp
  8003ae:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003b1:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003b4:	8b 55 10             	mov    0x10(%ebp),%edx
  8003b7:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ba:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003c1:	00 
  8003c2:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003c6:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003ca:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003cd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003d1:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003d5:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003dc:	00 
  8003dd:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003e4:	e8 c3 fc ff ff       	call   8000ac <syscall>
}
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003eb:	55                   	push   %ebp
  8003ec:	89 e5                	mov    %esp,%ebp
  8003ee:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f4:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003fb:	00 
  8003fc:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800403:	00 
  800404:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80040b:	00 
  80040c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800413:	00 
  800414:	89 44 24 08          	mov    %eax,0x8(%esp)
  800418:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80041f:	00 
  800420:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800427:	e8 80 fc ff ff       	call   8000ac <syscall>
}
  80042c:	c9                   	leave  
  80042d:	c3                   	ret    

0080042e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80042e:	55                   	push   %ebp
  80042f:	89 e5                	mov    %esp,%ebp
  800431:	53                   	push   %ebx
  800432:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800435:	8d 45 14             	lea    0x14(%ebp),%eax
  800438:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80043b:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800441:	e8 90 fd ff ff       	call   8001d6 <sys_getenvid>
  800446:	8b 55 0c             	mov    0xc(%ebp),%edx
  800449:	89 54 24 10          	mov    %edx,0x10(%esp)
  80044d:	8b 55 08             	mov    0x8(%ebp),%edx
  800450:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800454:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800458:	89 44 24 04          	mov    %eax,0x4(%esp)
  80045c:	c7 04 24 5c 14 80 00 	movl   $0x80145c,(%esp)
  800463:	e8 e1 00 00 00       	call   800549 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800468:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80046b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80046f:	8b 45 10             	mov    0x10(%ebp),%eax
  800472:	89 04 24             	mov    %eax,(%esp)
  800475:	e8 6b 00 00 00       	call   8004e5 <vcprintf>
	cprintf("\n");
  80047a:	c7 04 24 7f 14 80 00 	movl   $0x80147f,(%esp)
  800481:	e8 c3 00 00 00       	call   800549 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800486:	cc                   	int3   
  800487:	eb fd                	jmp    800486 <_panic+0x58>

00800489 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800489:	55                   	push   %ebp
  80048a:	89 e5                	mov    %esp,%ebp
  80048c:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  80048f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800492:	8b 00                	mov    (%eax),%eax
  800494:	8d 48 01             	lea    0x1(%eax),%ecx
  800497:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049a:	89 0a                	mov    %ecx,(%edx)
  80049c:	8b 55 08             	mov    0x8(%ebp),%edx
  80049f:	89 d1                	mov    %edx,%ecx
  8004a1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004a4:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004b2:	75 20                	jne    8004d4 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b7:	8b 00                	mov    (%eax),%eax
  8004b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004bc:	83 c2 08             	add    $0x8,%edx
  8004bf:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004c3:	89 14 24             	mov    %edx,(%esp)
  8004c6:	e8 42 fc ff ff       	call   80010d <sys_cputs>
		b->idx = 0;
  8004cb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ce:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d7:	8b 40 04             	mov    0x4(%eax),%eax
  8004da:	8d 50 01             	lea    0x1(%eax),%edx
  8004dd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004e0:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004e3:	c9                   	leave  
  8004e4:	c3                   	ret    

008004e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004e5:	55                   	push   %ebp
  8004e6:	89 e5                	mov    %esp,%ebp
  8004e8:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004ee:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004f5:	00 00 00 
	b.cnt = 0;
  8004f8:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004ff:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800502:	8b 45 0c             	mov    0xc(%ebp),%eax
  800505:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800509:	8b 45 08             	mov    0x8(%ebp),%eax
  80050c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800510:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800516:	89 44 24 04          	mov    %eax,0x4(%esp)
  80051a:	c7 04 24 89 04 80 00 	movl   $0x800489,(%esp)
  800521:	e8 bd 01 00 00       	call   8006e3 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800526:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  80052c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800530:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800536:	83 c0 08             	add    $0x8,%eax
  800539:	89 04 24             	mov    %eax,(%esp)
  80053c:	e8 cc fb ff ff       	call   80010d <sys_cputs>

	return b.cnt;
  800541:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800547:	c9                   	leave  
  800548:	c3                   	ret    

00800549 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800549:	55                   	push   %ebp
  80054a:	89 e5                	mov    %esp,%ebp
  80054c:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80054f:	8d 45 0c             	lea    0xc(%ebp),%eax
  800552:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800555:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800558:	89 44 24 04          	mov    %eax,0x4(%esp)
  80055c:	8b 45 08             	mov    0x8(%ebp),%eax
  80055f:	89 04 24             	mov    %eax,(%esp)
  800562:	e8 7e ff ff ff       	call   8004e5 <vcprintf>
  800567:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80056a:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  80056d:	c9                   	leave  
  80056e:	c3                   	ret    

0080056f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	53                   	push   %ebx
  800573:	83 ec 34             	sub    $0x34,%esp
  800576:	8b 45 10             	mov    0x10(%ebp),%eax
  800579:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80057c:	8b 45 14             	mov    0x14(%ebp),%eax
  80057f:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800582:	8b 45 18             	mov    0x18(%ebp),%eax
  800585:	ba 00 00 00 00       	mov    $0x0,%edx
  80058a:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80058d:	77 72                	ja     800601 <printnum+0x92>
  80058f:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800592:	72 05                	jb     800599 <printnum+0x2a>
  800594:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800597:	77 68                	ja     800601 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800599:	8b 45 1c             	mov    0x1c(%ebp),%eax
  80059c:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80059f:	8b 45 18             	mov    0x18(%ebp),%eax
  8005a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005ab:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005b2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005b5:	89 04 24             	mov    %eax,(%esp)
  8005b8:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005bc:	e8 cf 0b 00 00       	call   801190 <__udivdi3>
  8005c1:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005c4:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005c8:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005cc:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005cf:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005db:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005de:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8005e5:	89 04 24             	mov    %eax,(%esp)
  8005e8:	e8 82 ff ff ff       	call   80056f <printnum>
  8005ed:	eb 1c                	jmp    80060b <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005f6:	8b 45 20             	mov    0x20(%ebp),%eax
  8005f9:	89 04 24             	mov    %eax,(%esp)
  8005fc:	8b 45 08             	mov    0x8(%ebp),%eax
  8005ff:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800601:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  800605:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800609:	7f e4                	jg     8005ef <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80060b:	8b 4d 18             	mov    0x18(%ebp),%ecx
  80060e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800613:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800616:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800619:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80061d:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800621:	89 04 24             	mov    %eax,(%esp)
  800624:	89 54 24 04          	mov    %edx,0x4(%esp)
  800628:	e8 93 0c 00 00       	call   8012c0 <__umoddi3>
  80062d:	05 68 15 80 00       	add    $0x801568,%eax
  800632:	0f b6 00             	movzbl (%eax),%eax
  800635:	0f be c0             	movsbl %al,%eax
  800638:	8b 55 0c             	mov    0xc(%ebp),%edx
  80063b:	89 54 24 04          	mov    %edx,0x4(%esp)
  80063f:	89 04 24             	mov    %eax,(%esp)
  800642:	8b 45 08             	mov    0x8(%ebp),%eax
  800645:	ff d0                	call   *%eax
}
  800647:	83 c4 34             	add    $0x34,%esp
  80064a:	5b                   	pop    %ebx
  80064b:	5d                   	pop    %ebp
  80064c:	c3                   	ret    

0080064d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80064d:	55                   	push   %ebp
  80064e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800650:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800654:	7e 14                	jle    80066a <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  800656:	8b 45 08             	mov    0x8(%ebp),%eax
  800659:	8b 00                	mov    (%eax),%eax
  80065b:	8d 48 08             	lea    0x8(%eax),%ecx
  80065e:	8b 55 08             	mov    0x8(%ebp),%edx
  800661:	89 0a                	mov    %ecx,(%edx)
  800663:	8b 50 04             	mov    0x4(%eax),%edx
  800666:	8b 00                	mov    (%eax),%eax
  800668:	eb 30                	jmp    80069a <getuint+0x4d>
	else if (lflag)
  80066a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80066e:	74 16                	je     800686 <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800670:	8b 45 08             	mov    0x8(%ebp),%eax
  800673:	8b 00                	mov    (%eax),%eax
  800675:	8d 48 04             	lea    0x4(%eax),%ecx
  800678:	8b 55 08             	mov    0x8(%ebp),%edx
  80067b:	89 0a                	mov    %ecx,(%edx)
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	ba 00 00 00 00       	mov    $0x0,%edx
  800684:	eb 14                	jmp    80069a <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  800686:	8b 45 08             	mov    0x8(%ebp),%eax
  800689:	8b 00                	mov    (%eax),%eax
  80068b:	8d 48 04             	lea    0x4(%eax),%ecx
  80068e:	8b 55 08             	mov    0x8(%ebp),%edx
  800691:	89 0a                	mov    %ecx,(%edx)
  800693:	8b 00                	mov    (%eax),%eax
  800695:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80069a:	5d                   	pop    %ebp
  80069b:	c3                   	ret    

0080069c <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  80069c:	55                   	push   %ebp
  80069d:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  80069f:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  8006a3:	7e 14                	jle    8006b9 <getint+0x1d>
		return va_arg(*ap, long long);
  8006a5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a8:	8b 00                	mov    (%eax),%eax
  8006aa:	8d 48 08             	lea    0x8(%eax),%ecx
  8006ad:	8b 55 08             	mov    0x8(%ebp),%edx
  8006b0:	89 0a                	mov    %ecx,(%edx)
  8006b2:	8b 50 04             	mov    0x4(%eax),%edx
  8006b5:	8b 00                	mov    (%eax),%eax
  8006b7:	eb 28                	jmp    8006e1 <getint+0x45>
	else if (lflag)
  8006b9:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006bd:	74 12                	je     8006d1 <getint+0x35>
		return va_arg(*ap, long);
  8006bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c2:	8b 00                	mov    (%eax),%eax
  8006c4:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c7:	8b 55 08             	mov    0x8(%ebp),%edx
  8006ca:	89 0a                	mov    %ecx,(%edx)
  8006cc:	8b 00                	mov    (%eax),%eax
  8006ce:	99                   	cltd   
  8006cf:	eb 10                	jmp    8006e1 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 00                	mov    (%eax),%eax
  8006d6:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d9:	8b 55 08             	mov    0x8(%ebp),%edx
  8006dc:	89 0a                	mov    %ecx,(%edx)
  8006de:	8b 00                	mov    (%eax),%eax
  8006e0:	99                   	cltd   
}
  8006e1:	5d                   	pop    %ebp
  8006e2:	c3                   	ret    

008006e3 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006e3:	55                   	push   %ebp
  8006e4:	89 e5                	mov    %esp,%ebp
  8006e6:	56                   	push   %esi
  8006e7:	53                   	push   %ebx
  8006e8:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006eb:	eb 18                	jmp    800705 <vprintfmt+0x22>
			if (ch == '\0')
  8006ed:	85 db                	test   %ebx,%ebx
  8006ef:	75 05                	jne    8006f6 <vprintfmt+0x13>
				return;
  8006f1:	e9 05 04 00 00       	jmp    800afb <vprintfmt+0x418>
			putch(ch, putdat);
  8006f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006fd:	89 1c 24             	mov    %ebx,(%esp)
  800700:	8b 45 08             	mov    0x8(%ebp),%eax
  800703:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800705:	8b 45 10             	mov    0x10(%ebp),%eax
  800708:	8d 50 01             	lea    0x1(%eax),%edx
  80070b:	89 55 10             	mov    %edx,0x10(%ebp)
  80070e:	0f b6 00             	movzbl (%eax),%eax
  800711:	0f b6 d8             	movzbl %al,%ebx
  800714:	83 fb 25             	cmp    $0x25,%ebx
  800717:	75 d4                	jne    8006ed <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800719:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  80071d:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800724:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80072b:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800732:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800739:	8b 45 10             	mov    0x10(%ebp),%eax
  80073c:	8d 50 01             	lea    0x1(%eax),%edx
  80073f:	89 55 10             	mov    %edx,0x10(%ebp)
  800742:	0f b6 00             	movzbl (%eax),%eax
  800745:	0f b6 d8             	movzbl %al,%ebx
  800748:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80074b:	83 f8 55             	cmp    $0x55,%eax
  80074e:	0f 87 76 03 00 00    	ja     800aca <vprintfmt+0x3e7>
  800754:	8b 04 85 8c 15 80 00 	mov    0x80158c(,%eax,4),%eax
  80075b:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  80075d:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800761:	eb d6                	jmp    800739 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800763:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800767:	eb d0                	jmp    800739 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800769:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800770:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800773:	89 d0                	mov    %edx,%eax
  800775:	c1 e0 02             	shl    $0x2,%eax
  800778:	01 d0                	add    %edx,%eax
  80077a:	01 c0                	add    %eax,%eax
  80077c:	01 d8                	add    %ebx,%eax
  80077e:	83 e8 30             	sub    $0x30,%eax
  800781:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800784:	8b 45 10             	mov    0x10(%ebp),%eax
  800787:	0f b6 00             	movzbl (%eax),%eax
  80078a:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  80078d:	83 fb 2f             	cmp    $0x2f,%ebx
  800790:	7e 0b                	jle    80079d <vprintfmt+0xba>
  800792:	83 fb 39             	cmp    $0x39,%ebx
  800795:	7f 06                	jg     80079d <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800797:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80079b:	eb d3                	jmp    800770 <vprintfmt+0x8d>
			goto process_precision;
  80079d:	eb 33                	jmp    8007d2 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  80079f:	8b 45 14             	mov    0x14(%ebp),%eax
  8007a2:	8d 50 04             	lea    0x4(%eax),%edx
  8007a5:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a8:	8b 00                	mov    (%eax),%eax
  8007aa:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007ad:	eb 23                	jmp    8007d2 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007af:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007b3:	79 0c                	jns    8007c1 <vprintfmt+0xde>
				width = 0;
  8007b5:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007bc:	e9 78 ff ff ff       	jmp    800739 <vprintfmt+0x56>
  8007c1:	e9 73 ff ff ff       	jmp    800739 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007c6:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007cd:	e9 67 ff ff ff       	jmp    800739 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007d2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007d6:	79 12                	jns    8007ea <vprintfmt+0x107>
				width = precision, precision = -1;
  8007d8:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007db:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007de:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007e5:	e9 4f ff ff ff       	jmp    800739 <vprintfmt+0x56>
  8007ea:	e9 4a ff ff ff       	jmp    800739 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007ef:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007f3:	e9 41 ff ff ff       	jmp    800739 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fb:	8d 50 04             	lea    0x4(%eax),%edx
  8007fe:	89 55 14             	mov    %edx,0x14(%ebp)
  800801:	8b 00                	mov    (%eax),%eax
  800803:	8b 55 0c             	mov    0xc(%ebp),%edx
  800806:	89 54 24 04          	mov    %edx,0x4(%esp)
  80080a:	89 04 24             	mov    %eax,(%esp)
  80080d:	8b 45 08             	mov    0x8(%ebp),%eax
  800810:	ff d0                	call   *%eax
			break;
  800812:	e9 de 02 00 00       	jmp    800af5 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800817:	8b 45 14             	mov    0x14(%ebp),%eax
  80081a:	8d 50 04             	lea    0x4(%eax),%edx
  80081d:	89 55 14             	mov    %edx,0x14(%ebp)
  800820:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800822:	85 db                	test   %ebx,%ebx
  800824:	79 02                	jns    800828 <vprintfmt+0x145>
				err = -err;
  800826:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800828:	83 fb 09             	cmp    $0x9,%ebx
  80082b:	7f 0b                	jg     800838 <vprintfmt+0x155>
  80082d:	8b 34 9d 40 15 80 00 	mov    0x801540(,%ebx,4),%esi
  800834:	85 f6                	test   %esi,%esi
  800836:	75 23                	jne    80085b <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800838:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80083c:	c7 44 24 08 79 15 80 	movl   $0x801579,0x8(%esp)
  800843:	00 
  800844:	8b 45 0c             	mov    0xc(%ebp),%eax
  800847:	89 44 24 04          	mov    %eax,0x4(%esp)
  80084b:	8b 45 08             	mov    0x8(%ebp),%eax
  80084e:	89 04 24             	mov    %eax,(%esp)
  800851:	e8 ac 02 00 00       	call   800b02 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  800856:	e9 9a 02 00 00       	jmp    800af5 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80085b:	89 74 24 0c          	mov    %esi,0xc(%esp)
  80085f:	c7 44 24 08 82 15 80 	movl   $0x801582,0x8(%esp)
  800866:	00 
  800867:	8b 45 0c             	mov    0xc(%ebp),%eax
  80086a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80086e:	8b 45 08             	mov    0x8(%ebp),%eax
  800871:	89 04 24             	mov    %eax,(%esp)
  800874:	e8 89 02 00 00       	call   800b02 <printfmt>
			break;
  800879:	e9 77 02 00 00       	jmp    800af5 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  80087e:	8b 45 14             	mov    0x14(%ebp),%eax
  800881:	8d 50 04             	lea    0x4(%eax),%edx
  800884:	89 55 14             	mov    %edx,0x14(%ebp)
  800887:	8b 30                	mov    (%eax),%esi
  800889:	85 f6                	test   %esi,%esi
  80088b:	75 05                	jne    800892 <vprintfmt+0x1af>
				p = "(null)";
  80088d:	be 85 15 80 00       	mov    $0x801585,%esi
			if (width > 0 && padc != '-')
  800892:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800896:	7e 37                	jle    8008cf <vprintfmt+0x1ec>
  800898:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  80089c:	74 31                	je     8008cf <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  80089e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8008a1:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008a5:	89 34 24             	mov    %esi,(%esp)
  8008a8:	e8 72 03 00 00       	call   800c1f <strnlen>
  8008ad:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008b0:	eb 17                	jmp    8008c9 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008b2:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b9:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008bd:	89 04 24             	mov    %eax,(%esp)
  8008c0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008c3:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008c5:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008c9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008cd:	7f e3                	jg     8008b2 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008cf:	eb 38                	jmp    800909 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008d1:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008d5:	74 1f                	je     8008f6 <vprintfmt+0x213>
  8008d7:	83 fb 1f             	cmp    $0x1f,%ebx
  8008da:	7e 05                	jle    8008e1 <vprintfmt+0x1fe>
  8008dc:	83 fb 7e             	cmp    $0x7e,%ebx
  8008df:	7e 15                	jle    8008f6 <vprintfmt+0x213>
					putch('?', putdat);
  8008e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e8:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008ef:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f2:	ff d0                	call   *%eax
  8008f4:	eb 0f                	jmp    800905 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f9:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008fd:	89 1c 24             	mov    %ebx,(%esp)
  800900:	8b 45 08             	mov    0x8(%ebp),%eax
  800903:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800905:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800909:	89 f0                	mov    %esi,%eax
  80090b:	8d 70 01             	lea    0x1(%eax),%esi
  80090e:	0f b6 00             	movzbl (%eax),%eax
  800911:	0f be d8             	movsbl %al,%ebx
  800914:	85 db                	test   %ebx,%ebx
  800916:	74 10                	je     800928 <vprintfmt+0x245>
  800918:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80091c:	78 b3                	js     8008d1 <vprintfmt+0x1ee>
  80091e:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800922:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800926:	79 a9                	jns    8008d1 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800928:	eb 17                	jmp    800941 <vprintfmt+0x25e>
				putch(' ', putdat);
  80092a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800931:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800938:	8b 45 08             	mov    0x8(%ebp),%eax
  80093b:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80093d:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800941:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800945:	7f e3                	jg     80092a <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800947:	e9 a9 01 00 00       	jmp    800af5 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80094c:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80094f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800953:	8d 45 14             	lea    0x14(%ebp),%eax
  800956:	89 04 24             	mov    %eax,(%esp)
  800959:	e8 3e fd ff ff       	call   80069c <getint>
  80095e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800961:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800964:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800967:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80096a:	85 d2                	test   %edx,%edx
  80096c:	79 26                	jns    800994 <vprintfmt+0x2b1>
				putch('-', putdat);
  80096e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800971:	89 44 24 04          	mov    %eax,0x4(%esp)
  800975:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  80097c:	8b 45 08             	mov    0x8(%ebp),%eax
  80097f:	ff d0                	call   *%eax
				num = -(long long) num;
  800981:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800984:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800987:	f7 d8                	neg    %eax
  800989:	83 d2 00             	adc    $0x0,%edx
  80098c:	f7 da                	neg    %edx
  80098e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800991:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800994:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80099b:	e9 e1 00 00 00       	jmp    800a81 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  8009a0:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009a3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8009aa:	89 04 24             	mov    %eax,(%esp)
  8009ad:	e8 9b fc ff ff       	call   80064d <getuint>
  8009b2:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009b5:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009b8:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009bf:	e9 bd 00 00 00       	jmp    800a81 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009c4:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009cb:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009ce:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8009d5:	89 04 24             	mov    %eax,(%esp)
  8009d8:	e8 70 fc ff ff       	call   80064d <getuint>
  8009dd:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009e0:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8009e3:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8009e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009ea:	89 54 24 18          	mov    %edx,0x18(%esp)
  8009ee:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009f1:	89 54 24 14          	mov    %edx,0x14(%esp)
  8009f5:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009f9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009fc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009ff:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a03:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a0a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a0e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a11:	89 04 24             	mov    %eax,(%esp)
  800a14:	e8 56 fb ff ff       	call   80056f <printnum>
			break;
  800a19:	e9 d7 00 00 00       	jmp    800af5 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a1e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a21:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a25:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2f:	ff d0                	call   *%eax
			putch('x', putdat);
  800a31:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a34:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a38:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a3f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a42:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a44:	8b 45 14             	mov    0x14(%ebp),%eax
  800a47:	8d 50 04             	lea    0x4(%eax),%edx
  800a4a:	89 55 14             	mov    %edx,0x14(%ebp)
  800a4d:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a4f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a52:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a59:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a60:	eb 1f                	jmp    800a81 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a62:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a65:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a69:	8d 45 14             	lea    0x14(%ebp),%eax
  800a6c:	89 04 24             	mov    %eax,(%esp)
  800a6f:	e8 d9 fb ff ff       	call   80064d <getuint>
  800a74:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a77:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a7a:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a81:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a85:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a88:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a8c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a8f:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a93:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a97:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a9a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a9d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800aa1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800aa5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa8:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aac:	8b 45 08             	mov    0x8(%ebp),%eax
  800aaf:	89 04 24             	mov    %eax,(%esp)
  800ab2:	e8 b8 fa ff ff       	call   80056f <printnum>
			break;
  800ab7:	eb 3c                	jmp    800af5 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800abc:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac0:	89 1c 24             	mov    %ebx,(%esp)
  800ac3:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac6:	ff d0                	call   *%eax
			break;
  800ac8:	eb 2b                	jmp    800af5 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800aca:	8b 45 0c             	mov    0xc(%ebp),%eax
  800acd:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ad1:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad8:	8b 45 08             	mov    0x8(%ebp),%eax
  800adb:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800add:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae1:	eb 04                	jmp    800ae7 <vprintfmt+0x404>
  800ae3:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae7:	8b 45 10             	mov    0x10(%ebp),%eax
  800aea:	83 e8 01             	sub    $0x1,%eax
  800aed:	0f b6 00             	movzbl (%eax),%eax
  800af0:	3c 25                	cmp    $0x25,%al
  800af2:	75 ef                	jne    800ae3 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800af4:	90                   	nop
		}
	}
  800af5:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800af6:	e9 0a fc ff ff       	jmp    800705 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800afb:	83 c4 40             	add    $0x40,%esp
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5d                   	pop    %ebp
  800b01:	c3                   	ret    

00800b02 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800b02:	55                   	push   %ebp
  800b03:	89 e5                	mov    %esp,%ebp
  800b05:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b08:	8d 45 14             	lea    0x14(%ebp),%eax
  800b0b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b11:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b15:	8b 45 10             	mov    0x10(%ebp),%eax
  800b18:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b1f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b23:	8b 45 08             	mov    0x8(%ebp),%eax
  800b26:	89 04 24             	mov    %eax,(%esp)
  800b29:	e8 b5 fb ff ff       	call   8006e3 <vprintfmt>
	va_end(ap);
}
  800b2e:	c9                   	leave  
  800b2f:	c3                   	ret    

00800b30 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b30:	55                   	push   %ebp
  800b31:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b33:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b36:	8b 40 08             	mov    0x8(%eax),%eax
  800b39:	8d 50 01             	lea    0x1(%eax),%edx
  800b3c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3f:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b42:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b45:	8b 10                	mov    (%eax),%edx
  800b47:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4a:	8b 40 04             	mov    0x4(%eax),%eax
  800b4d:	39 c2                	cmp    %eax,%edx
  800b4f:	73 12                	jae    800b63 <sprintputch+0x33>
		*b->buf++ = ch;
  800b51:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b54:	8b 00                	mov    (%eax),%eax
  800b56:	8d 48 01             	lea    0x1(%eax),%ecx
  800b59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b5c:	89 0a                	mov    %ecx,(%edx)
  800b5e:	8b 55 08             	mov    0x8(%ebp),%edx
  800b61:	88 10                	mov    %dl,(%eax)
}
  800b63:	5d                   	pop    %ebp
  800b64:	c3                   	ret    

00800b65 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b71:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b74:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b77:	8b 45 08             	mov    0x8(%ebp),%eax
  800b7a:	01 d0                	add    %edx,%eax
  800b7c:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b7f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b86:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b8a:	74 06                	je     800b92 <vsnprintf+0x2d>
  800b8c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b90:	7f 07                	jg     800b99 <vsnprintf+0x34>
		return -E_INVAL;
  800b92:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b97:	eb 2a                	jmp    800bc3 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b99:	8b 45 14             	mov    0x14(%ebp),%eax
  800b9c:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800ba0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba3:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800baa:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bae:	c7 04 24 30 0b 80 00 	movl   $0x800b30,(%esp)
  800bb5:	e8 29 fb ff ff       	call   8006e3 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bba:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bbd:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bc0:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bcb:	8d 45 14             	lea    0x14(%ebp),%eax
  800bce:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bd1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bd4:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd8:	8b 45 10             	mov    0x10(%ebp),%eax
  800bdb:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bdf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800be2:	89 44 24 04          	mov    %eax,0x4(%esp)
  800be6:	8b 45 08             	mov    0x8(%ebp),%eax
  800be9:	89 04 24             	mov    %eax,(%esp)
  800bec:	e8 74 ff ff ff       	call   800b65 <vsnprintf>
  800bf1:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bf4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bf9:	55                   	push   %ebp
  800bfa:	89 e5                	mov    %esp,%ebp
  800bfc:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bff:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c06:	eb 08                	jmp    800c10 <strlen+0x17>
		n++;
  800c08:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c0c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c10:	8b 45 08             	mov    0x8(%ebp),%eax
  800c13:	0f b6 00             	movzbl (%eax),%eax
  800c16:	84 c0                	test   %al,%al
  800c18:	75 ee                	jne    800c08 <strlen+0xf>
		n++;
	return n;
  800c1a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c1d:	c9                   	leave  
  800c1e:	c3                   	ret    

00800c1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c1f:	55                   	push   %ebp
  800c20:	89 e5                	mov    %esp,%ebp
  800c22:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c25:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c2c:	eb 0c                	jmp    800c3a <strnlen+0x1b>
		n++;
  800c2e:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c32:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c36:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c3a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c3e:	74 0a                	je     800c4a <strnlen+0x2b>
  800c40:	8b 45 08             	mov    0x8(%ebp),%eax
  800c43:	0f b6 00             	movzbl (%eax),%eax
  800c46:	84 c0                	test   %al,%al
  800c48:	75 e4                	jne    800c2e <strnlen+0xf>
		n++;
	return n;
  800c4a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c4f:	55                   	push   %ebp
  800c50:	89 e5                	mov    %esp,%ebp
  800c52:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c5b:	90                   	nop
  800c5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800c5f:	8d 50 01             	lea    0x1(%eax),%edx
  800c62:	89 55 08             	mov    %edx,0x8(%ebp)
  800c65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c68:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c6b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c6e:	0f b6 12             	movzbl (%edx),%edx
  800c71:	88 10                	mov    %dl,(%eax)
  800c73:	0f b6 00             	movzbl (%eax),%eax
  800c76:	84 c0                	test   %al,%al
  800c78:	75 e2                	jne    800c5c <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c7a:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c7d:	c9                   	leave  
  800c7e:	c3                   	ret    

00800c7f <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c85:	8b 45 08             	mov    0x8(%ebp),%eax
  800c88:	89 04 24             	mov    %eax,(%esp)
  800c8b:	e8 69 ff ff ff       	call   800bf9 <strlen>
  800c90:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c93:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c96:	8b 45 08             	mov    0x8(%ebp),%eax
  800c99:	01 c2                	add    %eax,%edx
  800c9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ca2:	89 14 24             	mov    %edx,(%esp)
  800ca5:	e8 a5 ff ff ff       	call   800c4f <strcpy>
	return dst;
  800caa:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800caf:	55                   	push   %ebp
  800cb0:	89 e5                	mov    %esp,%ebp
  800cb2:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cb5:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb8:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cbb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cc2:	eb 23                	jmp    800ce7 <strncpy+0x38>
		*dst++ = *src;
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	8d 50 01             	lea    0x1(%eax),%edx
  800cca:	89 55 08             	mov    %edx,0x8(%ebp)
  800ccd:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cd0:	0f b6 12             	movzbl (%edx),%edx
  800cd3:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd8:	0f b6 00             	movzbl (%eax),%eax
  800cdb:	84 c0                	test   %al,%al
  800cdd:	74 04                	je     800ce3 <strncpy+0x34>
			src++;
  800cdf:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ce3:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce7:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cea:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ced:	72 d5                	jb     800cc4 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800cef:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800cf2:	c9                   	leave  
  800cf3:	c3                   	ret    

00800cf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cfa:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfd:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800d00:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d04:	74 33                	je     800d39 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800d06:	eb 17                	jmp    800d1f <strlcpy+0x2b>
			*dst++ = *src++;
  800d08:	8b 45 08             	mov    0x8(%ebp),%eax
  800d0b:	8d 50 01             	lea    0x1(%eax),%edx
  800d0e:	89 55 08             	mov    %edx,0x8(%ebp)
  800d11:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d14:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d17:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d1a:	0f b6 12             	movzbl (%edx),%edx
  800d1d:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d1f:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d23:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d27:	74 0a                	je     800d33 <strlcpy+0x3f>
  800d29:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d2c:	0f b6 00             	movzbl (%eax),%eax
  800d2f:	84 c0                	test   %al,%al
  800d31:	75 d5                	jne    800d08 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d33:	8b 45 08             	mov    0x8(%ebp),%eax
  800d36:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d39:	8b 55 08             	mov    0x8(%ebp),%edx
  800d3c:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d3f:	29 c2                	sub    %eax,%edx
  800d41:	89 d0                	mov    %edx,%eax
}
  800d43:	c9                   	leave  
  800d44:	c3                   	ret    

00800d45 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d48:	eb 08                	jmp    800d52 <strcmp+0xd>
		p++, q++;
  800d4a:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d4e:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	0f b6 00             	movzbl (%eax),%eax
  800d58:	84 c0                	test   %al,%al
  800d5a:	74 10                	je     800d6c <strcmp+0x27>
  800d5c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d5f:	0f b6 10             	movzbl (%eax),%edx
  800d62:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d65:	0f b6 00             	movzbl (%eax),%eax
  800d68:	38 c2                	cmp    %al,%dl
  800d6a:	74 de                	je     800d4a <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d6c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6f:	0f b6 00             	movzbl (%eax),%eax
  800d72:	0f b6 d0             	movzbl %al,%edx
  800d75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d78:	0f b6 00             	movzbl (%eax),%eax
  800d7b:	0f b6 c0             	movzbl %al,%eax
  800d7e:	29 c2                	sub    %eax,%edx
  800d80:	89 d0                	mov    %edx,%eax
}
  800d82:	5d                   	pop    %ebp
  800d83:	c3                   	ret    

00800d84 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d84:	55                   	push   %ebp
  800d85:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d87:	eb 0c                	jmp    800d95 <strncmp+0x11>
		n--, p++, q++;
  800d89:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d8d:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d91:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d99:	74 1a                	je     800db5 <strncmp+0x31>
  800d9b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9e:	0f b6 00             	movzbl (%eax),%eax
  800da1:	84 c0                	test   %al,%al
  800da3:	74 10                	je     800db5 <strncmp+0x31>
  800da5:	8b 45 08             	mov    0x8(%ebp),%eax
  800da8:	0f b6 10             	movzbl (%eax),%edx
  800dab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dae:	0f b6 00             	movzbl (%eax),%eax
  800db1:	38 c2                	cmp    %al,%dl
  800db3:	74 d4                	je     800d89 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800db5:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db9:	75 07                	jne    800dc2 <strncmp+0x3e>
		return 0;
  800dbb:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc0:	eb 16                	jmp    800dd8 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc5:	0f b6 00             	movzbl (%eax),%eax
  800dc8:	0f b6 d0             	movzbl %al,%edx
  800dcb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dce:	0f b6 00             	movzbl (%eax),%eax
  800dd1:	0f b6 c0             	movzbl %al,%eax
  800dd4:	29 c2                	sub    %eax,%edx
  800dd6:	89 d0                	mov    %edx,%eax
}
  800dd8:	5d                   	pop    %ebp
  800dd9:	c3                   	ret    

00800dda <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 04             	sub    $0x4,%esp
  800de0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800de3:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800de6:	eb 14                	jmp    800dfc <strchr+0x22>
		if (*s == c)
  800de8:	8b 45 08             	mov    0x8(%ebp),%eax
  800deb:	0f b6 00             	movzbl (%eax),%eax
  800dee:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800df1:	75 05                	jne    800df8 <strchr+0x1e>
			return (char *) s;
  800df3:	8b 45 08             	mov    0x8(%ebp),%eax
  800df6:	eb 13                	jmp    800e0b <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df8:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800dfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800dff:	0f b6 00             	movzbl (%eax),%eax
  800e02:	84 c0                	test   %al,%al
  800e04:	75 e2                	jne    800de8 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e0b:	c9                   	leave  
  800e0c:	c3                   	ret    

00800e0d <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e0d:	55                   	push   %ebp
  800e0e:	89 e5                	mov    %esp,%ebp
  800e10:	83 ec 04             	sub    $0x4,%esp
  800e13:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e16:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e19:	eb 11                	jmp    800e2c <strfind+0x1f>
		if (*s == c)
  800e1b:	8b 45 08             	mov    0x8(%ebp),%eax
  800e1e:	0f b6 00             	movzbl (%eax),%eax
  800e21:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e24:	75 02                	jne    800e28 <strfind+0x1b>
			break;
  800e26:	eb 0e                	jmp    800e36 <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e28:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2f:	0f b6 00             	movzbl (%eax),%eax
  800e32:	84 c0                	test   %al,%al
  800e34:	75 e5                	jne    800e1b <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e36:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e39:	c9                   	leave  
  800e3a:	c3                   	ret    

00800e3b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e3b:	55                   	push   %ebp
  800e3c:	89 e5                	mov    %esp,%ebp
  800e3e:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e43:	75 05                	jne    800e4a <memset+0xf>
		return v;
  800e45:	8b 45 08             	mov    0x8(%ebp),%eax
  800e48:	eb 5c                	jmp    800ea6 <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
  800e4d:	83 e0 03             	and    $0x3,%eax
  800e50:	85 c0                	test   %eax,%eax
  800e52:	75 41                	jne    800e95 <memset+0x5a>
  800e54:	8b 45 10             	mov    0x10(%ebp),%eax
  800e57:	83 e0 03             	and    $0x3,%eax
  800e5a:	85 c0                	test   %eax,%eax
  800e5c:	75 37                	jne    800e95 <memset+0x5a>
		c &= 0xFF;
  800e5e:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e68:	c1 e0 18             	shl    $0x18,%eax
  800e6b:	89 c2                	mov    %eax,%edx
  800e6d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e70:	c1 e0 10             	shl    $0x10,%eax
  800e73:	09 c2                	or     %eax,%edx
  800e75:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e78:	c1 e0 08             	shl    $0x8,%eax
  800e7b:	09 d0                	or     %edx,%eax
  800e7d:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e80:	8b 45 10             	mov    0x10(%ebp),%eax
  800e83:	c1 e8 02             	shr    $0x2,%eax
  800e86:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e88:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8e:	89 d7                	mov    %edx,%edi
  800e90:	fc                   	cld    
  800e91:	f3 ab                	rep stos %eax,%es:(%edi)
  800e93:	eb 0e                	jmp    800ea3 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e95:	8b 55 08             	mov    0x8(%ebp),%edx
  800e98:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e9b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e9e:	89 d7                	mov    %edx,%edi
  800ea0:	fc                   	cld    
  800ea1:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800ea3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    

00800ea9 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea9:	55                   	push   %ebp
  800eaa:	89 e5                	mov    %esp,%ebp
  800eac:	57                   	push   %edi
  800ead:	56                   	push   %esi
  800eae:	53                   	push   %ebx
  800eaf:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eb2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eb5:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800ebb:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800ebe:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ec1:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec4:	73 6d                	jae    800f33 <memmove+0x8a>
  800ec6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ecc:	01 d0                	add    %edx,%eax
  800ece:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ed1:	76 60                	jbe    800f33 <memmove+0x8a>
		s += n;
  800ed3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed6:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ed9:	8b 45 10             	mov    0x10(%ebp),%eax
  800edc:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800edf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ee2:	83 e0 03             	and    $0x3,%eax
  800ee5:	85 c0                	test   %eax,%eax
  800ee7:	75 2f                	jne    800f18 <memmove+0x6f>
  800ee9:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800eec:	83 e0 03             	and    $0x3,%eax
  800eef:	85 c0                	test   %eax,%eax
  800ef1:	75 25                	jne    800f18 <memmove+0x6f>
  800ef3:	8b 45 10             	mov    0x10(%ebp),%eax
  800ef6:	83 e0 03             	and    $0x3,%eax
  800ef9:	85 c0                	test   %eax,%eax
  800efb:	75 1b                	jne    800f18 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800efd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f00:	83 e8 04             	sub    $0x4,%eax
  800f03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f06:	83 ea 04             	sub    $0x4,%edx
  800f09:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f0c:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f0f:	89 c7                	mov    %eax,%edi
  800f11:	89 d6                	mov    %edx,%esi
  800f13:	fd                   	std    
  800f14:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f16:	eb 18                	jmp    800f30 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f18:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f1b:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f1e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f21:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f24:	8b 45 10             	mov    0x10(%ebp),%eax
  800f27:	89 d7                	mov    %edx,%edi
  800f29:	89 de                	mov    %ebx,%esi
  800f2b:	89 c1                	mov    %eax,%ecx
  800f2d:	fd                   	std    
  800f2e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f30:	fc                   	cld    
  800f31:	eb 45                	jmp    800f78 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f33:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f36:	83 e0 03             	and    $0x3,%eax
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	75 2b                	jne    800f68 <memmove+0xbf>
  800f3d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f40:	83 e0 03             	and    $0x3,%eax
  800f43:	85 c0                	test   %eax,%eax
  800f45:	75 21                	jne    800f68 <memmove+0xbf>
  800f47:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4a:	83 e0 03             	and    $0x3,%eax
  800f4d:	85 c0                	test   %eax,%eax
  800f4f:	75 17                	jne    800f68 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f51:	8b 45 10             	mov    0x10(%ebp),%eax
  800f54:	c1 e8 02             	shr    $0x2,%eax
  800f57:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f59:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f5f:	89 c7                	mov    %eax,%edi
  800f61:	89 d6                	mov    %edx,%esi
  800f63:	fc                   	cld    
  800f64:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f66:	eb 10                	jmp    800f78 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f68:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f6b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f6e:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f71:	89 c7                	mov    %eax,%edi
  800f73:	89 d6                	mov    %edx,%esi
  800f75:	fc                   	cld    
  800f76:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f78:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f7b:	83 c4 10             	add    $0x10,%esp
  800f7e:	5b                   	pop    %ebx
  800f7f:	5e                   	pop    %esi
  800f80:	5f                   	pop    %edi
  800f81:	5d                   	pop    %ebp
  800f82:	c3                   	ret    

00800f83 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f83:	55                   	push   %ebp
  800f84:	89 e5                	mov    %esp,%ebp
  800f86:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f89:	8b 45 10             	mov    0x10(%ebp),%eax
  800f8c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f90:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f93:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f97:	8b 45 08             	mov    0x8(%ebp),%eax
  800f9a:	89 04 24             	mov    %eax,(%esp)
  800f9d:	e8 07 ff ff ff       	call   800ea9 <memmove>
}
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800faa:	8b 45 08             	mov    0x8(%ebp),%eax
  800fad:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fb0:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fb3:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800fb6:	eb 30                	jmp    800fe8 <memcmp+0x44>
		if (*s1 != *s2)
  800fb8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fbb:	0f b6 10             	movzbl (%eax),%edx
  800fbe:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc1:	0f b6 00             	movzbl (%eax),%eax
  800fc4:	38 c2                	cmp    %al,%dl
  800fc6:	74 18                	je     800fe0 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fc8:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fcb:	0f b6 00             	movzbl (%eax),%eax
  800fce:	0f b6 d0             	movzbl %al,%edx
  800fd1:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fd4:	0f b6 00             	movzbl (%eax),%eax
  800fd7:	0f b6 c0             	movzbl %al,%eax
  800fda:	29 c2                	sub    %eax,%edx
  800fdc:	89 d0                	mov    %edx,%eax
  800fde:	eb 1a                	jmp    800ffa <memcmp+0x56>
		s1++, s2++;
  800fe0:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fe4:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe8:	8b 45 10             	mov    0x10(%ebp),%eax
  800feb:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fee:	89 55 10             	mov    %edx,0x10(%ebp)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	75 c3                	jne    800fb8 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800ff5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ffa:	c9                   	leave  
  800ffb:	c3                   	ret    

00800ffc <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ffc:	55                   	push   %ebp
  800ffd:	89 e5                	mov    %esp,%ebp
  800fff:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  801002:	8b 45 10             	mov    0x10(%ebp),%eax
  801005:	8b 55 08             	mov    0x8(%ebp),%edx
  801008:	01 d0                	add    %edx,%eax
  80100a:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  80100d:	eb 13                	jmp    801022 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  80100f:	8b 45 08             	mov    0x8(%ebp),%eax
  801012:	0f b6 10             	movzbl (%eax),%edx
  801015:	8b 45 0c             	mov    0xc(%ebp),%eax
  801018:	38 c2                	cmp    %al,%dl
  80101a:	75 02                	jne    80101e <memfind+0x22>
			break;
  80101c:	eb 0c                	jmp    80102a <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80101e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801022:	8b 45 08             	mov    0x8(%ebp),%eax
  801025:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801028:	72 e5                	jb     80100f <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80102a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  80102d:	c9                   	leave  
  80102e:	c3                   	ret    

0080102f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80102f:	55                   	push   %ebp
  801030:	89 e5                	mov    %esp,%ebp
  801032:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801035:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  80103c:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801043:	eb 04                	jmp    801049 <strtol+0x1a>
		s++;
  801045:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	0f b6 00             	movzbl (%eax),%eax
  80104f:	3c 20                	cmp    $0x20,%al
  801051:	74 f2                	je     801045 <strtol+0x16>
  801053:	8b 45 08             	mov    0x8(%ebp),%eax
  801056:	0f b6 00             	movzbl (%eax),%eax
  801059:	3c 09                	cmp    $0x9,%al
  80105b:	74 e8                	je     801045 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  80105d:	8b 45 08             	mov    0x8(%ebp),%eax
  801060:	0f b6 00             	movzbl (%eax),%eax
  801063:	3c 2b                	cmp    $0x2b,%al
  801065:	75 06                	jne    80106d <strtol+0x3e>
		s++;
  801067:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80106b:	eb 15                	jmp    801082 <strtol+0x53>
	else if (*s == '-')
  80106d:	8b 45 08             	mov    0x8(%ebp),%eax
  801070:	0f b6 00             	movzbl (%eax),%eax
  801073:	3c 2d                	cmp    $0x2d,%al
  801075:	75 0b                	jne    801082 <strtol+0x53>
		s++, neg = 1;
  801077:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80107b:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801082:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801086:	74 06                	je     80108e <strtol+0x5f>
  801088:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  80108c:	75 24                	jne    8010b2 <strtol+0x83>
  80108e:	8b 45 08             	mov    0x8(%ebp),%eax
  801091:	0f b6 00             	movzbl (%eax),%eax
  801094:	3c 30                	cmp    $0x30,%al
  801096:	75 1a                	jne    8010b2 <strtol+0x83>
  801098:	8b 45 08             	mov    0x8(%ebp),%eax
  80109b:	83 c0 01             	add    $0x1,%eax
  80109e:	0f b6 00             	movzbl (%eax),%eax
  8010a1:	3c 78                	cmp    $0x78,%al
  8010a3:	75 0d                	jne    8010b2 <strtol+0x83>
		s += 2, base = 16;
  8010a5:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010a9:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010b0:	eb 2a                	jmp    8010dc <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010b2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010b6:	75 17                	jne    8010cf <strtol+0xa0>
  8010b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8010bb:	0f b6 00             	movzbl (%eax),%eax
  8010be:	3c 30                	cmp    $0x30,%al
  8010c0:	75 0d                	jne    8010cf <strtol+0xa0>
		s++, base = 8;
  8010c2:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010c6:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010cd:	eb 0d                	jmp    8010dc <strtol+0xad>
	else if (base == 0)
  8010cf:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010d3:	75 07                	jne    8010dc <strtol+0xad>
		base = 10;
  8010d5:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010dc:	8b 45 08             	mov    0x8(%ebp),%eax
  8010df:	0f b6 00             	movzbl (%eax),%eax
  8010e2:	3c 2f                	cmp    $0x2f,%al
  8010e4:	7e 1b                	jle    801101 <strtol+0xd2>
  8010e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e9:	0f b6 00             	movzbl (%eax),%eax
  8010ec:	3c 39                	cmp    $0x39,%al
  8010ee:	7f 11                	jg     801101 <strtol+0xd2>
			dig = *s - '0';
  8010f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f3:	0f b6 00             	movzbl (%eax),%eax
  8010f6:	0f be c0             	movsbl %al,%eax
  8010f9:	83 e8 30             	sub    $0x30,%eax
  8010fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010ff:	eb 48                	jmp    801149 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  801101:	8b 45 08             	mov    0x8(%ebp),%eax
  801104:	0f b6 00             	movzbl (%eax),%eax
  801107:	3c 60                	cmp    $0x60,%al
  801109:	7e 1b                	jle    801126 <strtol+0xf7>
  80110b:	8b 45 08             	mov    0x8(%ebp),%eax
  80110e:	0f b6 00             	movzbl (%eax),%eax
  801111:	3c 7a                	cmp    $0x7a,%al
  801113:	7f 11                	jg     801126 <strtol+0xf7>
			dig = *s - 'a' + 10;
  801115:	8b 45 08             	mov    0x8(%ebp),%eax
  801118:	0f b6 00             	movzbl (%eax),%eax
  80111b:	0f be c0             	movsbl %al,%eax
  80111e:	83 e8 57             	sub    $0x57,%eax
  801121:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801124:	eb 23                	jmp    801149 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  801126:	8b 45 08             	mov    0x8(%ebp),%eax
  801129:	0f b6 00             	movzbl (%eax),%eax
  80112c:	3c 40                	cmp    $0x40,%al
  80112e:	7e 3d                	jle    80116d <strtol+0x13e>
  801130:	8b 45 08             	mov    0x8(%ebp),%eax
  801133:	0f b6 00             	movzbl (%eax),%eax
  801136:	3c 5a                	cmp    $0x5a,%al
  801138:	7f 33                	jg     80116d <strtol+0x13e>
			dig = *s - 'A' + 10;
  80113a:	8b 45 08             	mov    0x8(%ebp),%eax
  80113d:	0f b6 00             	movzbl (%eax),%eax
  801140:	0f be c0             	movsbl %al,%eax
  801143:	83 e8 37             	sub    $0x37,%eax
  801146:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801149:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80114c:	3b 45 10             	cmp    0x10(%ebp),%eax
  80114f:	7c 02                	jl     801153 <strtol+0x124>
			break;
  801151:	eb 1a                	jmp    80116d <strtol+0x13e>
		s++, val = (val * base) + dig;
  801153:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801157:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80115a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80115e:	89 c2                	mov    %eax,%edx
  801160:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801163:	01 d0                	add    %edx,%eax
  801165:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801168:	e9 6f ff ff ff       	jmp    8010dc <strtol+0xad>

	if (endptr)
  80116d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801171:	74 08                	je     80117b <strtol+0x14c>
		*endptr = (char *) s;
  801173:	8b 45 0c             	mov    0xc(%ebp),%eax
  801176:	8b 55 08             	mov    0x8(%ebp),%edx
  801179:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80117b:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  80117f:	74 07                	je     801188 <strtol+0x159>
  801181:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801184:	f7 d8                	neg    %eax
  801186:	eb 03                	jmp    80118b <strtol+0x15c>
  801188:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80118b:	c9                   	leave  
  80118c:	c3                   	ret    
  80118d:	66 90                	xchg   %ax,%ax
  80118f:	90                   	nop

00801190 <__udivdi3>:
  801190:	55                   	push   %ebp
  801191:	57                   	push   %edi
  801192:	56                   	push   %esi
  801193:	83 ec 0c             	sub    $0xc,%esp
  801196:	8b 44 24 28          	mov    0x28(%esp),%eax
  80119a:	8b 7c 24 1c          	mov    0x1c(%esp),%edi
  80119e:	8b 6c 24 20          	mov    0x20(%esp),%ebp
  8011a2:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8011a6:	85 c0                	test   %eax,%eax
  8011a8:	89 7c 24 04          	mov    %edi,0x4(%esp)
  8011ac:	89 ea                	mov    %ebp,%edx
  8011ae:	89 0c 24             	mov    %ecx,(%esp)
  8011b1:	75 2d                	jne    8011e0 <__udivdi3+0x50>
  8011b3:	39 e9                	cmp    %ebp,%ecx
  8011b5:	77 61                	ja     801218 <__udivdi3+0x88>
  8011b7:	85 c9                	test   %ecx,%ecx
  8011b9:	89 ce                	mov    %ecx,%esi
  8011bb:	75 0b                	jne    8011c8 <__udivdi3+0x38>
  8011bd:	b8 01 00 00 00       	mov    $0x1,%eax
  8011c2:	31 d2                	xor    %edx,%edx
  8011c4:	f7 f1                	div    %ecx
  8011c6:	89 c6                	mov    %eax,%esi
  8011c8:	31 d2                	xor    %edx,%edx
  8011ca:	89 e8                	mov    %ebp,%eax
  8011cc:	f7 f6                	div    %esi
  8011ce:	89 c5                	mov    %eax,%ebp
  8011d0:	89 f8                	mov    %edi,%eax
  8011d2:	f7 f6                	div    %esi
  8011d4:	89 ea                	mov    %ebp,%edx
  8011d6:	83 c4 0c             	add    $0xc,%esp
  8011d9:	5e                   	pop    %esi
  8011da:	5f                   	pop    %edi
  8011db:	5d                   	pop    %ebp
  8011dc:	c3                   	ret    
  8011dd:	8d 76 00             	lea    0x0(%esi),%esi
  8011e0:	39 e8                	cmp    %ebp,%eax
  8011e2:	77 24                	ja     801208 <__udivdi3+0x78>
  8011e4:	0f bd e8             	bsr    %eax,%ebp
  8011e7:	83 f5 1f             	xor    $0x1f,%ebp
  8011ea:	75 3c                	jne    801228 <__udivdi3+0x98>
  8011ec:	8b 74 24 04          	mov    0x4(%esp),%esi
  8011f0:	39 34 24             	cmp    %esi,(%esp)
  8011f3:	0f 86 9f 00 00 00    	jbe    801298 <__udivdi3+0x108>
  8011f9:	39 d0                	cmp    %edx,%eax
  8011fb:	0f 82 97 00 00 00    	jb     801298 <__udivdi3+0x108>
  801201:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801208:	31 d2                	xor    %edx,%edx
  80120a:	31 c0                	xor    %eax,%eax
  80120c:	83 c4 0c             	add    $0xc,%esp
  80120f:	5e                   	pop    %esi
  801210:	5f                   	pop    %edi
  801211:	5d                   	pop    %ebp
  801212:	c3                   	ret    
  801213:	90                   	nop
  801214:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801218:	89 f8                	mov    %edi,%eax
  80121a:	f7 f1                	div    %ecx
  80121c:	31 d2                	xor    %edx,%edx
  80121e:	83 c4 0c             	add    $0xc,%esp
  801221:	5e                   	pop    %esi
  801222:	5f                   	pop    %edi
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    
  801225:	8d 76 00             	lea    0x0(%esi),%esi
  801228:	89 e9                	mov    %ebp,%ecx
  80122a:	8b 3c 24             	mov    (%esp),%edi
  80122d:	d3 e0                	shl    %cl,%eax
  80122f:	89 c6                	mov    %eax,%esi
  801231:	b8 20 00 00 00       	mov    $0x20,%eax
  801236:	29 e8                	sub    %ebp,%eax
  801238:	89 c1                	mov    %eax,%ecx
  80123a:	d3 ef                	shr    %cl,%edi
  80123c:	89 e9                	mov    %ebp,%ecx
  80123e:	89 7c 24 08          	mov    %edi,0x8(%esp)
  801242:	8b 3c 24             	mov    (%esp),%edi
  801245:	09 74 24 08          	or     %esi,0x8(%esp)
  801249:	89 d6                	mov    %edx,%esi
  80124b:	d3 e7                	shl    %cl,%edi
  80124d:	89 c1                	mov    %eax,%ecx
  80124f:	89 3c 24             	mov    %edi,(%esp)
  801252:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801256:	d3 ee                	shr    %cl,%esi
  801258:	89 e9                	mov    %ebp,%ecx
  80125a:	d3 e2                	shl    %cl,%edx
  80125c:	89 c1                	mov    %eax,%ecx
  80125e:	d3 ef                	shr    %cl,%edi
  801260:	09 d7                	or     %edx,%edi
  801262:	89 f2                	mov    %esi,%edx
  801264:	89 f8                	mov    %edi,%eax
  801266:	f7 74 24 08          	divl   0x8(%esp)
  80126a:	89 d6                	mov    %edx,%esi
  80126c:	89 c7                	mov    %eax,%edi
  80126e:	f7 24 24             	mull   (%esp)
  801271:	39 d6                	cmp    %edx,%esi
  801273:	89 14 24             	mov    %edx,(%esp)
  801276:	72 30                	jb     8012a8 <__udivdi3+0x118>
  801278:	8b 54 24 04          	mov    0x4(%esp),%edx
  80127c:	89 e9                	mov    %ebp,%ecx
  80127e:	d3 e2                	shl    %cl,%edx
  801280:	39 c2                	cmp    %eax,%edx
  801282:	73 05                	jae    801289 <__udivdi3+0xf9>
  801284:	3b 34 24             	cmp    (%esp),%esi
  801287:	74 1f                	je     8012a8 <__udivdi3+0x118>
  801289:	89 f8                	mov    %edi,%eax
  80128b:	31 d2                	xor    %edx,%edx
  80128d:	e9 7a ff ff ff       	jmp    80120c <__udivdi3+0x7c>
  801292:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801298:	31 d2                	xor    %edx,%edx
  80129a:	b8 01 00 00 00       	mov    $0x1,%eax
  80129f:	e9 68 ff ff ff       	jmp    80120c <__udivdi3+0x7c>
  8012a4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  8012a8:	8d 47 ff             	lea    -0x1(%edi),%eax
  8012ab:	31 d2                	xor    %edx,%edx
  8012ad:	83 c4 0c             	add    $0xc,%esp
  8012b0:	5e                   	pop    %esi
  8012b1:	5f                   	pop    %edi
  8012b2:	5d                   	pop    %ebp
  8012b3:	c3                   	ret    
  8012b4:	66 90                	xchg   %ax,%ax
  8012b6:	66 90                	xchg   %ax,%ax
  8012b8:	66 90                	xchg   %ax,%ax
  8012ba:	66 90                	xchg   %ax,%ax
  8012bc:	66 90                	xchg   %ax,%ax
  8012be:	66 90                	xchg   %ax,%ax

008012c0 <__umoddi3>:
  8012c0:	55                   	push   %ebp
  8012c1:	57                   	push   %edi
  8012c2:	56                   	push   %esi
  8012c3:	83 ec 14             	sub    $0x14,%esp
  8012c6:	8b 44 24 28          	mov    0x28(%esp),%eax
  8012ca:	8b 4c 24 24          	mov    0x24(%esp),%ecx
  8012ce:	8b 74 24 2c          	mov    0x2c(%esp),%esi
  8012d2:	89 c7                	mov    %eax,%edi
  8012d4:	89 44 24 04          	mov    %eax,0x4(%esp)
  8012d8:	8b 44 24 30          	mov    0x30(%esp),%eax
  8012dc:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8012e0:	89 34 24             	mov    %esi,(%esp)
  8012e3:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8012e7:	85 c0                	test   %eax,%eax
  8012e9:	89 c2                	mov    %eax,%edx
  8012eb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8012ef:	75 17                	jne    801308 <__umoddi3+0x48>
  8012f1:	39 fe                	cmp    %edi,%esi
  8012f3:	76 4b                	jbe    801340 <__umoddi3+0x80>
  8012f5:	89 c8                	mov    %ecx,%eax
  8012f7:	89 fa                	mov    %edi,%edx
  8012f9:	f7 f6                	div    %esi
  8012fb:	89 d0                	mov    %edx,%eax
  8012fd:	31 d2                	xor    %edx,%edx
  8012ff:	83 c4 14             	add    $0x14,%esp
  801302:	5e                   	pop    %esi
  801303:	5f                   	pop    %edi
  801304:	5d                   	pop    %ebp
  801305:	c3                   	ret    
  801306:	66 90                	xchg   %ax,%ax
  801308:	39 f8                	cmp    %edi,%eax
  80130a:	77 54                	ja     801360 <__umoddi3+0xa0>
  80130c:	0f bd e8             	bsr    %eax,%ebp
  80130f:	83 f5 1f             	xor    $0x1f,%ebp
  801312:	75 5c                	jne    801370 <__umoddi3+0xb0>
  801314:	8b 7c 24 08          	mov    0x8(%esp),%edi
  801318:	39 3c 24             	cmp    %edi,(%esp)
  80131b:	0f 87 e7 00 00 00    	ja     801408 <__umoddi3+0x148>
  801321:	8b 7c 24 04          	mov    0x4(%esp),%edi
  801325:	29 f1                	sub    %esi,%ecx
  801327:	19 c7                	sbb    %eax,%edi
  801329:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  80132d:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801331:	8b 44 24 08          	mov    0x8(%esp),%eax
  801335:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801339:	83 c4 14             	add    $0x14,%esp
  80133c:	5e                   	pop    %esi
  80133d:	5f                   	pop    %edi
  80133e:	5d                   	pop    %ebp
  80133f:	c3                   	ret    
  801340:	85 f6                	test   %esi,%esi
  801342:	89 f5                	mov    %esi,%ebp
  801344:	75 0b                	jne    801351 <__umoddi3+0x91>
  801346:	b8 01 00 00 00       	mov    $0x1,%eax
  80134b:	31 d2                	xor    %edx,%edx
  80134d:	f7 f6                	div    %esi
  80134f:	89 c5                	mov    %eax,%ebp
  801351:	8b 44 24 04          	mov    0x4(%esp),%eax
  801355:	31 d2                	xor    %edx,%edx
  801357:	f7 f5                	div    %ebp
  801359:	89 c8                	mov    %ecx,%eax
  80135b:	f7 f5                	div    %ebp
  80135d:	eb 9c                	jmp    8012fb <__umoddi3+0x3b>
  80135f:	90                   	nop
  801360:	89 c8                	mov    %ecx,%eax
  801362:	89 fa                	mov    %edi,%edx
  801364:	83 c4 14             	add    $0x14,%esp
  801367:	5e                   	pop    %esi
  801368:	5f                   	pop    %edi
  801369:	5d                   	pop    %ebp
  80136a:	c3                   	ret    
  80136b:	90                   	nop
  80136c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801370:	8b 04 24             	mov    (%esp),%eax
  801373:	be 20 00 00 00       	mov    $0x20,%esi
  801378:	89 e9                	mov    %ebp,%ecx
  80137a:	29 ee                	sub    %ebp,%esi
  80137c:	d3 e2                	shl    %cl,%edx
  80137e:	89 f1                	mov    %esi,%ecx
  801380:	d3 e8                	shr    %cl,%eax
  801382:	89 e9                	mov    %ebp,%ecx
  801384:	89 44 24 04          	mov    %eax,0x4(%esp)
  801388:	8b 04 24             	mov    (%esp),%eax
  80138b:	09 54 24 04          	or     %edx,0x4(%esp)
  80138f:	89 fa                	mov    %edi,%edx
  801391:	d3 e0                	shl    %cl,%eax
  801393:	89 f1                	mov    %esi,%ecx
  801395:	89 44 24 08          	mov    %eax,0x8(%esp)
  801399:	8b 44 24 10          	mov    0x10(%esp),%eax
  80139d:	d3 ea                	shr    %cl,%edx
  80139f:	89 e9                	mov    %ebp,%ecx
  8013a1:	d3 e7                	shl    %cl,%edi
  8013a3:	89 f1                	mov    %esi,%ecx
  8013a5:	d3 e8                	shr    %cl,%eax
  8013a7:	89 e9                	mov    %ebp,%ecx
  8013a9:	09 f8                	or     %edi,%eax
  8013ab:	8b 7c 24 10          	mov    0x10(%esp),%edi
  8013af:	f7 74 24 04          	divl   0x4(%esp)
  8013b3:	d3 e7                	shl    %cl,%edi
  8013b5:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8013b9:	89 d7                	mov    %edx,%edi
  8013bb:	f7 64 24 08          	mull   0x8(%esp)
  8013bf:	39 d7                	cmp    %edx,%edi
  8013c1:	89 c1                	mov    %eax,%ecx
  8013c3:	89 14 24             	mov    %edx,(%esp)
  8013c6:	72 2c                	jb     8013f4 <__umoddi3+0x134>
  8013c8:	39 44 24 0c          	cmp    %eax,0xc(%esp)
  8013cc:	72 22                	jb     8013f0 <__umoddi3+0x130>
  8013ce:	8b 44 24 0c          	mov    0xc(%esp),%eax
  8013d2:	29 c8                	sub    %ecx,%eax
  8013d4:	19 d7                	sbb    %edx,%edi
  8013d6:	89 e9                	mov    %ebp,%ecx
  8013d8:	89 fa                	mov    %edi,%edx
  8013da:	d3 e8                	shr    %cl,%eax
  8013dc:	89 f1                	mov    %esi,%ecx
  8013de:	d3 e2                	shl    %cl,%edx
  8013e0:	89 e9                	mov    %ebp,%ecx
  8013e2:	d3 ef                	shr    %cl,%edi
  8013e4:	09 d0                	or     %edx,%eax
  8013e6:	89 fa                	mov    %edi,%edx
  8013e8:	83 c4 14             	add    $0x14,%esp
  8013eb:	5e                   	pop    %esi
  8013ec:	5f                   	pop    %edi
  8013ed:	5d                   	pop    %ebp
  8013ee:	c3                   	ret    
  8013ef:	90                   	nop
  8013f0:	39 d7                	cmp    %edx,%edi
  8013f2:	75 da                	jne    8013ce <__umoddi3+0x10e>
  8013f4:	8b 14 24             	mov    (%esp),%edx
  8013f7:	89 c1                	mov    %eax,%ecx
  8013f9:	2b 4c 24 08          	sub    0x8(%esp),%ecx
  8013fd:	1b 54 24 04          	sbb    0x4(%esp),%edx
  801401:	eb cb                	jmp    8013ce <__umoddi3+0x10e>
  801403:	90                   	nop
  801404:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801408:	3b 44 24 0c          	cmp    0xc(%esp),%eax
  80140c:	0f 82 0f ff ff ff    	jb     801321 <__umoddi3+0x61>
  801412:	e9 1a ff ff ff       	jmp    801331 <__umoddi3+0x71>
