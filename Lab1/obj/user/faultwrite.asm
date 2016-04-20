
obj/user/faultwrite:     file format elf32-i386


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
  80002c:	e8 12 00 00 00       	call   800043 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	b8 00 00 00 00       	mov    $0x0,%eax
  80003b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
}
  800041:	5d                   	pop    %ebp
  800042:	c3                   	ret    

00800043 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800043:	55                   	push   %ebp
  800044:	89 e5                	mov    %esp,%ebp
  800046:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 81 01 00 00       	call   8001cf <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	c1 e0 02             	shl    $0x2,%eax
  800056:	89 c2                	mov    %eax,%edx
  800058:	c1 e2 05             	shl    $0x5,%edx
  80005b:	29 c2                	sub    %eax,%edx
  80005d:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  800063:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800068:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  80006c:	7e 0a                	jle    800078 <libmain+0x35>
		binaryname = argv[0];
  80006e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800071:	8b 00                	mov    (%eax),%eax
  800073:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800078:	8b 45 0c             	mov    0xc(%ebp),%eax
  80007b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007f:	8b 45 08             	mov    0x8(%ebp),%eax
  800082:	89 04 24             	mov    %eax,(%esp)
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 02 00 00 00       	call   800091 <exit>
}
  80008f:	c9                   	leave  
  800090:	c3                   	ret    

00800091 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800091:	55                   	push   %ebp
  800092:	89 e5                	mov    %esp,%ebp
  800094:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800097:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80009e:	e8 e9 00 00 00       	call   80018c <sys_env_destroy>
}
  8000a3:	c9                   	leave  
  8000a4:	c3                   	ret    

008000a5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a5:	55                   	push   %ebp
  8000a6:	89 e5                	mov    %esp,%ebp
  8000a8:	57                   	push   %edi
  8000a9:	56                   	push   %esi
  8000aa:	53                   	push   %ebx
  8000ab:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8000b1:	8b 55 10             	mov    0x10(%ebp),%edx
  8000b4:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000b7:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000ba:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000bd:	8b 75 20             	mov    0x20(%ebp),%esi
  8000c0:	cd 30                	int    $0x30
  8000c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c9:	74 30                	je     8000fb <syscall+0x56>
  8000cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000cf:	7e 2a                	jle    8000fb <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000d4:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d8:	8b 45 08             	mov    0x8(%ebp),%eax
  8000db:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000df:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8000e6:	00 
  8000e7:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000ee:	00 
  8000ef:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000f6:	e8 2c 03 00 00       	call   800427 <_panic>

	return ret;
  8000fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000fe:	83 c4 3c             	add    $0x3c,%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    

00800106 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800106:	55                   	push   %ebp
  800107:	89 e5                	mov    %esp,%ebp
  800109:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010c:	8b 45 08             	mov    0x8(%ebp),%eax
  80010f:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800116:	00 
  800117:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80011e:	00 
  80011f:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800126:	00 
  800127:	8b 55 0c             	mov    0xc(%ebp),%edx
  80012a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80012e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800132:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800139:	00 
  80013a:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800141:	e8 5f ff ff ff       	call   8000a5 <syscall>
}
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <sys_cgetc>:

int
sys_cgetc(void)
{
  800148:	55                   	push   %ebp
  800149:	89 e5                	mov    %esp,%ebp
  80014b:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80014e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800155:	00 
  800156:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80015d:	00 
  80015e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800165:	00 
  800166:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80016d:	00 
  80016e:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800175:	00 
  800176:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  80017d:	00 
  80017e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800185:	e8 1b ff ff ff       	call   8000a5 <syscall>
}
  80018a:	c9                   	leave  
  80018b:	c3                   	ret    

0080018c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800192:	8b 45 08             	mov    0x8(%ebp),%eax
  800195:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80019c:	00 
  80019d:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001a4:	00 
  8001a5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001ac:	00 
  8001ad:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001b4:	00 
  8001b5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b9:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001c0:	00 
  8001c1:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c8:	e8 d8 fe ff ff       	call   8000a5 <syscall>
}
  8001cd:	c9                   	leave  
  8001ce:	c3                   	ret    

008001cf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001d5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001dc:	00 
  8001dd:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001e4:	00 
  8001e5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001ec:	00 
  8001ed:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001f4:	00 
  8001f5:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001fc:	00 
  8001fd:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800204:	00 
  800205:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  80020c:	e8 94 fe ff ff       	call   8000a5 <syscall>
}
  800211:	c9                   	leave  
  800212:	c3                   	ret    

00800213 <sys_yield>:

void
sys_yield(void)
{
  800213:	55                   	push   %ebp
  800214:	89 e5                	mov    %esp,%ebp
  800216:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800219:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800220:	00 
  800221:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800228:	00 
  800229:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800230:	00 
  800231:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800238:	00 
  800239:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800240:	00 
  800241:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800248:	00 
  800249:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  800250:	e8 50 fe ff ff       	call   8000a5 <syscall>
}
  800255:	c9                   	leave  
  800256:	c3                   	ret    

00800257 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80025d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800260:	8b 55 0c             	mov    0xc(%ebp),%edx
  800263:	8b 45 08             	mov    0x8(%ebp),%eax
  800266:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80026d:	00 
  80026e:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800275:	00 
  800276:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  80027a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80027e:	89 44 24 08          	mov    %eax,0x8(%esp)
  800282:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800289:	00 
  80028a:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  800291:	e8 0f fe ff ff       	call   8000a5 <syscall>
}
  800296:	c9                   	leave  
  800297:	c3                   	ret    

00800298 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800298:	55                   	push   %ebp
  800299:	89 e5                	mov    %esp,%ebp
  80029b:	56                   	push   %esi
  80029c:	53                   	push   %ebx
  80029d:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8002a0:	8b 75 18             	mov    0x18(%ebp),%esi
  8002a3:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a6:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8002af:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002b3:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002b7:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002bb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002bf:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002c3:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002ca:	00 
  8002cb:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002d2:	e8 ce fd ff ff       	call   8000a5 <syscall>
}
  8002d7:	83 c4 20             	add    $0x20,%esp
  8002da:	5b                   	pop    %ebx
  8002db:	5e                   	pop    %esi
  8002dc:	5d                   	pop    %ebp
  8002dd:	c3                   	ret    

008002de <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002de:	55                   	push   %ebp
  8002df:	89 e5                	mov    %esp,%ebp
  8002e1:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002e4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002ea:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002f1:	00 
  8002f2:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f9:	00 
  8002fa:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800301:	00 
  800302:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800306:	89 44 24 08          	mov    %eax,0x8(%esp)
  80030a:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800311:	00 
  800312:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800319:	e8 87 fd ff ff       	call   8000a5 <syscall>
}
  80031e:	c9                   	leave  
  80031f:	c3                   	ret    

00800320 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800326:	8b 55 0c             	mov    0xc(%ebp),%edx
  800329:	8b 45 08             	mov    0x8(%ebp),%eax
  80032c:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800333:	00 
  800334:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80033b:	00 
  80033c:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800343:	00 
  800344:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800348:	89 44 24 08          	mov    %eax,0x8(%esp)
  80034c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800353:	00 
  800354:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  80035b:	e8 45 fd ff ff       	call   8000a5 <syscall>
}
  800360:	c9                   	leave  
  800361:	c3                   	ret    

00800362 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800362:	55                   	push   %ebp
  800363:	89 e5                	mov    %esp,%ebp
  800365:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80036b:	8b 45 08             	mov    0x8(%ebp),%eax
  80036e:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800375:	00 
  800376:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80037d:	00 
  80037e:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800385:	00 
  800386:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80038a:	89 44 24 08          	mov    %eax,0x8(%esp)
  80038e:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800395:	00 
  800396:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  80039d:	e8 03 fd ff ff       	call   8000a5 <syscall>
}
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003aa:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003ad:	8b 55 10             	mov    0x10(%ebp),%edx
  8003b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b3:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ba:	00 
  8003bb:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003bf:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003c3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003ca:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003ce:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003d5:	00 
  8003d6:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003dd:	e8 c3 fc ff ff       	call   8000a5 <syscall>
}
  8003e2:	c9                   	leave  
  8003e3:	c3                   	ret    

008003e4 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003e4:	55                   	push   %ebp
  8003e5:	89 e5                	mov    %esp,%ebp
  8003e7:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ed:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003f4:	00 
  8003f5:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003fc:	00 
  8003fd:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800404:	00 
  800405:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  80040c:	00 
  80040d:	89 44 24 08          	mov    %eax,0x8(%esp)
  800411:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800418:	00 
  800419:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  800420:	e8 80 fc ff ff       	call   8000a5 <syscall>
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    

00800427 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	53                   	push   %ebx
  80042b:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  80042e:	8d 45 14             	lea    0x14(%ebp),%eax
  800431:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800434:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  80043a:	e8 90 fd ff ff       	call   8001cf <sys_getenvid>
  80043f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800442:	89 54 24 10          	mov    %edx,0x10(%esp)
  800446:	8b 55 08             	mov    0x8(%ebp),%edx
  800449:	89 54 24 0c          	mov    %edx,0xc(%esp)
  80044d:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800451:	89 44 24 04          	mov    %eax,0x4(%esp)
  800455:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  80045c:	e8 e1 00 00 00       	call   800542 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800461:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800464:	89 44 24 04          	mov    %eax,0x4(%esp)
  800468:	8b 45 10             	mov    0x10(%ebp),%eax
  80046b:	89 04 24             	mov    %eax,(%esp)
  80046e:	e8 6b 00 00 00       	call   8004de <vcprintf>
	cprintf("\n");
  800473:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  80047a:	e8 c3 00 00 00       	call   800542 <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047f:	cc                   	int3   
  800480:	eb fd                	jmp    80047f <_panic+0x58>

00800482 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800482:	55                   	push   %ebp
  800483:	89 e5                	mov    %esp,%ebp
  800485:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800488:	8b 45 0c             	mov    0xc(%ebp),%eax
  80048b:	8b 00                	mov    (%eax),%eax
  80048d:	8d 48 01             	lea    0x1(%eax),%ecx
  800490:	8b 55 0c             	mov    0xc(%ebp),%edx
  800493:	89 0a                	mov    %ecx,(%edx)
  800495:	8b 55 08             	mov    0x8(%ebp),%edx
  800498:	89 d1                	mov    %edx,%ecx
  80049a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80049d:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  8004a1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004a4:	8b 00                	mov    (%eax),%eax
  8004a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004ab:	75 20                	jne    8004cd <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004ad:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004b0:	8b 00                	mov    (%eax),%eax
  8004b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b5:	83 c2 08             	add    $0x8,%edx
  8004b8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004bc:	89 14 24             	mov    %edx,(%esp)
  8004bf:	e8 42 fc ff ff       	call   800106 <sys_cputs>
		b->idx = 0;
  8004c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004cd:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d0:	8b 40 04             	mov    0x4(%eax),%eax
  8004d3:	8d 50 01             	lea    0x1(%eax),%edx
  8004d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d9:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004dc:	c9                   	leave  
  8004dd:	c3                   	ret    

008004de <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004de:	55                   	push   %ebp
  8004df:	89 e5                	mov    %esp,%ebp
  8004e1:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004ee:	00 00 00 
	b.cnt = 0;
  8004f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004fe:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800502:	8b 45 08             	mov    0x8(%ebp),%eax
  800505:	89 44 24 08          	mov    %eax,0x8(%esp)
  800509:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80050f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800513:	c7 04 24 82 04 80 00 	movl   $0x800482,(%esp)
  80051a:	e8 bd 01 00 00       	call   8006dc <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051f:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800525:	89 44 24 04          	mov    %eax,0x4(%esp)
  800529:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052f:	83 c0 08             	add    $0x8,%eax
  800532:	89 04 24             	mov    %eax,(%esp)
  800535:	e8 cc fb ff ff       	call   800106 <sys_cputs>

	return b.cnt;
  80053a:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800542:	55                   	push   %ebp
  800543:	89 e5                	mov    %esp,%ebp
  800545:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800548:	8d 45 0c             	lea    0xc(%ebp),%eax
  80054b:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  80054e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800551:	89 44 24 04          	mov    %eax,0x4(%esp)
  800555:	8b 45 08             	mov    0x8(%ebp),%eax
  800558:	89 04 24             	mov    %eax,(%esp)
  80055b:	e8 7e ff ff ff       	call   8004de <vcprintf>
  800560:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  800563:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800566:	c9                   	leave  
  800567:	c3                   	ret    

00800568 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800568:	55                   	push   %ebp
  800569:	89 e5                	mov    %esp,%ebp
  80056b:	53                   	push   %ebx
  80056c:	83 ec 34             	sub    $0x34,%esp
  80056f:	8b 45 10             	mov    0x10(%ebp),%eax
  800572:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800575:	8b 45 14             	mov    0x14(%ebp),%eax
  800578:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80057b:	8b 45 18             	mov    0x18(%ebp),%eax
  80057e:	ba 00 00 00 00       	mov    $0x0,%edx
  800583:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800586:	77 72                	ja     8005fa <printnum+0x92>
  800588:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  80058b:	72 05                	jb     800592 <printnum+0x2a>
  80058d:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  800590:	77 68                	ja     8005fa <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800592:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800595:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800598:	8b 45 18             	mov    0x18(%ebp),%eax
  80059b:	ba 00 00 00 00       	mov    $0x0,%edx
  8005a0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005a4:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005ab:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005ae:	89 04 24             	mov    %eax,(%esp)
  8005b1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b5:	e8 d6 0b 00 00       	call   801190 <__udivdi3>
  8005ba:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005bd:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005c1:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005c5:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005c8:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005cc:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005d0:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005db:	8b 45 08             	mov    0x8(%ebp),%eax
  8005de:	89 04 24             	mov    %eax,(%esp)
  8005e1:	e8 82 ff ff ff       	call   800568 <printnum>
  8005e6:	eb 1c                	jmp    800604 <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005eb:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ef:	8b 45 20             	mov    0x20(%ebp),%eax
  8005f2:	89 04 24             	mov    %eax,(%esp)
  8005f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f8:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005fa:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005fe:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  800602:	7f e4                	jg     8005e8 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800604:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800607:	bb 00 00 00 00       	mov    $0x0,%ebx
  80060c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80060f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800612:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800616:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80061a:	89 04 24             	mov    %eax,(%esp)
  80061d:	89 54 24 04          	mov    %edx,0x4(%esp)
  800621:	e8 9a 0c 00 00       	call   8012c0 <__umoddi3>
  800626:	05 48 15 80 00       	add    $0x801548,%eax
  80062b:	0f b6 00             	movzbl (%eax),%eax
  80062e:	0f be c0             	movsbl %al,%eax
  800631:	8b 55 0c             	mov    0xc(%ebp),%edx
  800634:	89 54 24 04          	mov    %edx,0x4(%esp)
  800638:	89 04 24             	mov    %eax,(%esp)
  80063b:	8b 45 08             	mov    0x8(%ebp),%eax
  80063e:	ff d0                	call   *%eax
}
  800640:	83 c4 34             	add    $0x34,%esp
  800643:	5b                   	pop    %ebx
  800644:	5d                   	pop    %ebp
  800645:	c3                   	ret    

00800646 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800646:	55                   	push   %ebp
  800647:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800649:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80064d:	7e 14                	jle    800663 <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	8b 00                	mov    (%eax),%eax
  800654:	8d 48 08             	lea    0x8(%eax),%ecx
  800657:	8b 55 08             	mov    0x8(%ebp),%edx
  80065a:	89 0a                	mov    %ecx,(%edx)
  80065c:	8b 50 04             	mov    0x4(%eax),%edx
  80065f:	8b 00                	mov    (%eax),%eax
  800661:	eb 30                	jmp    800693 <getuint+0x4d>
	else if (lflag)
  800663:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800667:	74 16                	je     80067f <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800669:	8b 45 08             	mov    0x8(%ebp),%eax
  80066c:	8b 00                	mov    (%eax),%eax
  80066e:	8d 48 04             	lea    0x4(%eax),%ecx
  800671:	8b 55 08             	mov    0x8(%ebp),%edx
  800674:	89 0a                	mov    %ecx,(%edx)
  800676:	8b 00                	mov    (%eax),%eax
  800678:	ba 00 00 00 00       	mov    $0x0,%edx
  80067d:	eb 14                	jmp    800693 <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80067f:	8b 45 08             	mov    0x8(%ebp),%eax
  800682:	8b 00                	mov    (%eax),%eax
  800684:	8d 48 04             	lea    0x4(%eax),%ecx
  800687:	8b 55 08             	mov    0x8(%ebp),%edx
  80068a:	89 0a                	mov    %ecx,(%edx)
  80068c:	8b 00                	mov    (%eax),%eax
  80068e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800693:	5d                   	pop    %ebp
  800694:	c3                   	ret    

00800695 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800695:	55                   	push   %ebp
  800696:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800698:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  80069c:	7e 14                	jle    8006b2 <getint+0x1d>
		return va_arg(*ap, long long);
  80069e:	8b 45 08             	mov    0x8(%ebp),%eax
  8006a1:	8b 00                	mov    (%eax),%eax
  8006a3:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a9:	89 0a                	mov    %ecx,(%edx)
  8006ab:	8b 50 04             	mov    0x4(%eax),%edx
  8006ae:	8b 00                	mov    (%eax),%eax
  8006b0:	eb 28                	jmp    8006da <getint+0x45>
	else if (lflag)
  8006b2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b6:	74 12                	je     8006ca <getint+0x35>
		return va_arg(*ap, long);
  8006b8:	8b 45 08             	mov    0x8(%ebp),%eax
  8006bb:	8b 00                	mov    (%eax),%eax
  8006bd:	8d 48 04             	lea    0x4(%eax),%ecx
  8006c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8006c3:	89 0a                	mov    %ecx,(%edx)
  8006c5:	8b 00                	mov    (%eax),%eax
  8006c7:	99                   	cltd   
  8006c8:	eb 10                	jmp    8006da <getint+0x45>
	else
		return va_arg(*ap, int);
  8006ca:	8b 45 08             	mov    0x8(%ebp),%eax
  8006cd:	8b 00                	mov    (%eax),%eax
  8006cf:	8d 48 04             	lea    0x4(%eax),%ecx
  8006d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d5:	89 0a                	mov    %ecx,(%edx)
  8006d7:	8b 00                	mov    (%eax),%eax
  8006d9:	99                   	cltd   
}
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006dc:	55                   	push   %ebp
  8006dd:	89 e5                	mov    %esp,%ebp
  8006df:	56                   	push   %esi
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006e4:	eb 18                	jmp    8006fe <vprintfmt+0x22>
			if (ch == '\0')
  8006e6:	85 db                	test   %ebx,%ebx
  8006e8:	75 05                	jne    8006ef <vprintfmt+0x13>
				return;
  8006ea:	e9 05 04 00 00       	jmp    800af4 <vprintfmt+0x418>
			putch(ch, putdat);
  8006ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f6:	89 1c 24             	mov    %ebx,(%esp)
  8006f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fc:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006fe:	8b 45 10             	mov    0x10(%ebp),%eax
  800701:	8d 50 01             	lea    0x1(%eax),%edx
  800704:	89 55 10             	mov    %edx,0x10(%ebp)
  800707:	0f b6 00             	movzbl (%eax),%eax
  80070a:	0f b6 d8             	movzbl %al,%ebx
  80070d:	83 fb 25             	cmp    $0x25,%ebx
  800710:	75 d4                	jne    8006e6 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  800712:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800716:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  80071d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800724:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  80072b:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800732:	8b 45 10             	mov    0x10(%ebp),%eax
  800735:	8d 50 01             	lea    0x1(%eax),%edx
  800738:	89 55 10             	mov    %edx,0x10(%ebp)
  80073b:	0f b6 00             	movzbl (%eax),%eax
  80073e:	0f b6 d8             	movzbl %al,%ebx
  800741:	8d 43 dd             	lea    -0x23(%ebx),%eax
  800744:	83 f8 55             	cmp    $0x55,%eax
  800747:	0f 87 76 03 00 00    	ja     800ac3 <vprintfmt+0x3e7>
  80074d:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  800754:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800756:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  80075a:	eb d6                	jmp    800732 <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80075c:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  800760:	eb d0                	jmp    800732 <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800762:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800769:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80076c:	89 d0                	mov    %edx,%eax
  80076e:	c1 e0 02             	shl    $0x2,%eax
  800771:	01 d0                	add    %edx,%eax
  800773:	01 c0                	add    %eax,%eax
  800775:	01 d8                	add    %ebx,%eax
  800777:	83 e8 30             	sub    $0x30,%eax
  80077a:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  80077d:	8b 45 10             	mov    0x10(%ebp),%eax
  800780:	0f b6 00             	movzbl (%eax),%eax
  800783:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800786:	83 fb 2f             	cmp    $0x2f,%ebx
  800789:	7e 0b                	jle    800796 <vprintfmt+0xba>
  80078b:	83 fb 39             	cmp    $0x39,%ebx
  80078e:	7f 06                	jg     800796 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  800790:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  800794:	eb d3                	jmp    800769 <vprintfmt+0x8d>
			goto process_precision;
  800796:	eb 33                	jmp    8007cb <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800798:	8b 45 14             	mov    0x14(%ebp),%eax
  80079b:	8d 50 04             	lea    0x4(%eax),%edx
  80079e:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a1:	8b 00                	mov    (%eax),%eax
  8007a3:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007a6:	eb 23                	jmp    8007cb <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007a8:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ac:	79 0c                	jns    8007ba <vprintfmt+0xde>
				width = 0;
  8007ae:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007b5:	e9 78 ff ff ff       	jmp    800732 <vprintfmt+0x56>
  8007ba:	e9 73 ff ff ff       	jmp    800732 <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007bf:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007c6:	e9 67 ff ff ff       	jmp    800732 <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007cb:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007cf:	79 12                	jns    8007e3 <vprintfmt+0x107>
				width = precision, precision = -1;
  8007d1:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007d4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007de:	e9 4f ff ff ff       	jmp    800732 <vprintfmt+0x56>
  8007e3:	e9 4a ff ff ff       	jmp    800732 <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e8:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007ec:	e9 41 ff ff ff       	jmp    800732 <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8007f4:	8d 50 04             	lea    0x4(%eax),%edx
  8007f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8007fa:	8b 00                	mov    (%eax),%eax
  8007fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ff:	89 54 24 04          	mov    %edx,0x4(%esp)
  800803:	89 04 24             	mov    %eax,(%esp)
  800806:	8b 45 08             	mov    0x8(%ebp),%eax
  800809:	ff d0                	call   *%eax
			break;
  80080b:	e9 de 02 00 00       	jmp    800aee <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800810:	8b 45 14             	mov    0x14(%ebp),%eax
  800813:	8d 50 04             	lea    0x4(%eax),%edx
  800816:	89 55 14             	mov    %edx,0x14(%ebp)
  800819:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  80081b:	85 db                	test   %ebx,%ebx
  80081d:	79 02                	jns    800821 <vprintfmt+0x145>
				err = -err;
  80081f:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800821:	83 fb 09             	cmp    $0x9,%ebx
  800824:	7f 0b                	jg     800831 <vprintfmt+0x155>
  800826:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  80082d:	85 f6                	test   %esi,%esi
  80082f:	75 23                	jne    800854 <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  800831:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800835:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  80083c:	00 
  80083d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800840:	89 44 24 04          	mov    %eax,0x4(%esp)
  800844:	8b 45 08             	mov    0x8(%ebp),%eax
  800847:	89 04 24             	mov    %eax,(%esp)
  80084a:	e8 ac 02 00 00       	call   800afb <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80084f:	e9 9a 02 00 00       	jmp    800aee <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  800854:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800858:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80085f:	00 
  800860:	8b 45 0c             	mov    0xc(%ebp),%eax
  800863:	89 44 24 04          	mov    %eax,0x4(%esp)
  800867:	8b 45 08             	mov    0x8(%ebp),%eax
  80086a:	89 04 24             	mov    %eax,(%esp)
  80086d:	e8 89 02 00 00       	call   800afb <printfmt>
			break;
  800872:	e9 77 02 00 00       	jmp    800aee <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800877:	8b 45 14             	mov    0x14(%ebp),%eax
  80087a:	8d 50 04             	lea    0x4(%eax),%edx
  80087d:	89 55 14             	mov    %edx,0x14(%ebp)
  800880:	8b 30                	mov    (%eax),%esi
  800882:	85 f6                	test   %esi,%esi
  800884:	75 05                	jne    80088b <vprintfmt+0x1af>
				p = "(null)";
  800886:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  80088b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088f:	7e 37                	jle    8008c8 <vprintfmt+0x1ec>
  800891:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800895:	74 31                	je     8008c8 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800897:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80089a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80089e:	89 34 24             	mov    %esi,(%esp)
  8008a1:	e8 72 03 00 00       	call   800c18 <strnlen>
  8008a6:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008a9:	eb 17                	jmp    8008c2 <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008ab:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008af:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008b2:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b6:	89 04 24             	mov    %eax,(%esp)
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008be:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008c2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c6:	7f e3                	jg     8008ab <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c8:	eb 38                	jmp    800902 <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008ca:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008ce:	74 1f                	je     8008ef <vprintfmt+0x213>
  8008d0:	83 fb 1f             	cmp    $0x1f,%ebx
  8008d3:	7e 05                	jle    8008da <vprintfmt+0x1fe>
  8008d5:	83 fb 7e             	cmp    $0x7e,%ebx
  8008d8:	7e 15                	jle    8008ef <vprintfmt+0x213>
					putch('?', putdat);
  8008da:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008dd:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008e1:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008eb:	ff d0                	call   *%eax
  8008ed:	eb 0f                	jmp    8008fe <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008f2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fc:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008fe:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800902:	89 f0                	mov    %esi,%eax
  800904:	8d 70 01             	lea    0x1(%eax),%esi
  800907:	0f b6 00             	movzbl (%eax),%eax
  80090a:	0f be d8             	movsbl %al,%ebx
  80090d:	85 db                	test   %ebx,%ebx
  80090f:	74 10                	je     800921 <vprintfmt+0x245>
  800911:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800915:	78 b3                	js     8008ca <vprintfmt+0x1ee>
  800917:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  80091b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80091f:	79 a9                	jns    8008ca <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800921:	eb 17                	jmp    80093a <vprintfmt+0x25e>
				putch(' ', putdat);
  800923:	8b 45 0c             	mov    0xc(%ebp),%eax
  800926:	89 44 24 04          	mov    %eax,0x4(%esp)
  80092a:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  800931:	8b 45 08             	mov    0x8(%ebp),%eax
  800934:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800936:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  80093a:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80093e:	7f e3                	jg     800923 <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  800940:	e9 a9 01 00 00       	jmp    800aee <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800945:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800948:	89 44 24 04          	mov    %eax,0x4(%esp)
  80094c:	8d 45 14             	lea    0x14(%ebp),%eax
  80094f:	89 04 24             	mov    %eax,(%esp)
  800952:	e8 3e fd ff ff       	call   800695 <getint>
  800957:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80095a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  80095d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800960:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800963:	85 d2                	test   %edx,%edx
  800965:	79 26                	jns    80098d <vprintfmt+0x2b1>
				putch('-', putdat);
  800967:	8b 45 0c             	mov    0xc(%ebp),%eax
  80096a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80096e:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	ff d0                	call   *%eax
				num = -(long long) num;
  80097a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80097d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800980:	f7 d8                	neg    %eax
  800982:	83 d2 00             	adc    $0x0,%edx
  800985:	f7 da                	neg    %edx
  800987:	89 45 f0             	mov    %eax,-0x10(%ebp)
  80098a:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  80098d:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  800994:	e9 e1 00 00 00       	jmp    800a7a <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800999:	8b 45 e8             	mov    -0x18(%ebp),%eax
  80099c:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009a0:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a3:	89 04 24             	mov    %eax,(%esp)
  8009a6:	e8 9b fc ff ff       	call   800646 <getuint>
  8009ab:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009b1:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009b8:	e9 bd 00 00 00       	jmp    800a7a <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009bd:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c7:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8009ce:	89 04 24             	mov    %eax,(%esp)
  8009d1:	e8 70 fc ff ff       	call   800646 <getuint>
  8009d6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8009dc:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8009e0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009e3:	89 54 24 18          	mov    %edx,0x18(%esp)
  8009e7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009ea:	89 54 24 14          	mov    %edx,0x14(%esp)
  8009ee:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009f8:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009fc:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a00:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a03:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a07:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0a:	89 04 24             	mov    %eax,(%esp)
  800a0d:	e8 56 fb ff ff       	call   800568 <printnum>
			break;
  800a12:	e9 d7 00 00 00       	jmp    800aee <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a17:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a1a:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a1e:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a25:	8b 45 08             	mov    0x8(%ebp),%eax
  800a28:	ff d0                	call   *%eax
			putch('x', putdat);
  800a2a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a2d:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a31:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a38:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3b:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a3d:	8b 45 14             	mov    0x14(%ebp),%eax
  800a40:	8d 50 04             	lea    0x4(%eax),%edx
  800a43:	89 55 14             	mov    %edx,0x14(%ebp)
  800a46:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a48:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a4b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a52:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a59:	eb 1f                	jmp    800a7a <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a5b:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a5e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a62:	8d 45 14             	lea    0x14(%ebp),%eax
  800a65:	89 04 24             	mov    %eax,(%esp)
  800a68:	e8 d9 fb ff ff       	call   800646 <getuint>
  800a6d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a70:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a73:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a7a:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a81:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a85:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a88:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a8c:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a90:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a93:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a96:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a9a:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a9e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa5:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa8:	89 04 24             	mov    %eax,(%esp)
  800aab:	e8 b8 fa ff ff       	call   800568 <printnum>
			break;
  800ab0:	eb 3c                	jmp    800aee <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800ab2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab5:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab9:	89 1c 24             	mov    %ebx,(%esp)
  800abc:	8b 45 08             	mov    0x8(%ebp),%eax
  800abf:	ff d0                	call   *%eax
			break;
  800ac1:	eb 2b                	jmp    800aee <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800ac3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aca:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800ad1:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad4:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad6:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ada:	eb 04                	jmp    800ae0 <vprintfmt+0x404>
  800adc:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ae0:	8b 45 10             	mov    0x10(%ebp),%eax
  800ae3:	83 e8 01             	sub    $0x1,%eax
  800ae6:	0f b6 00             	movzbl (%eax),%eax
  800ae9:	3c 25                	cmp    $0x25,%al
  800aeb:	75 ef                	jne    800adc <vprintfmt+0x400>
				/* do nothing */;
			break;
  800aed:	90                   	nop
		}
	}
  800aee:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aef:	e9 0a fc ff ff       	jmp    8006fe <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800af4:	83 c4 40             	add    $0x40,%esp
  800af7:	5b                   	pop    %ebx
  800af8:	5e                   	pop    %esi
  800af9:	5d                   	pop    %ebp
  800afa:	c3                   	ret    

00800afb <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800afb:	55                   	push   %ebp
  800afc:	89 e5                	mov    %esp,%ebp
  800afe:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800b01:	8d 45 14             	lea    0x14(%ebp),%eax
  800b04:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b07:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b0a:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b0e:	8b 45 10             	mov    0x10(%ebp),%eax
  800b11:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b15:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b18:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b1c:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1f:	89 04 24             	mov    %eax,(%esp)
  800b22:	e8 b5 fb ff ff       	call   8006dc <vprintfmt>
	va_end(ap);
}
  800b27:	c9                   	leave  
  800b28:	c3                   	ret    

00800b29 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b29:	55                   	push   %ebp
  800b2a:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2f:	8b 40 08             	mov    0x8(%eax),%eax
  800b32:	8d 50 01             	lea    0x1(%eax),%edx
  800b35:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b38:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	8b 10                	mov    (%eax),%edx
  800b40:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b43:	8b 40 04             	mov    0x4(%eax),%eax
  800b46:	39 c2                	cmp    %eax,%edx
  800b48:	73 12                	jae    800b5c <sprintputch+0x33>
		*b->buf++ = ch;
  800b4a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b4d:	8b 00                	mov    (%eax),%eax
  800b4f:	8d 48 01             	lea    0x1(%eax),%ecx
  800b52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b55:	89 0a                	mov    %ecx,(%edx)
  800b57:	8b 55 08             	mov    0x8(%ebp),%edx
  800b5a:	88 10                	mov    %dl,(%eax)
}
  800b5c:	5d                   	pop    %ebp
  800b5d:	c3                   	ret    

00800b5e <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b5e:	55                   	push   %ebp
  800b5f:	89 e5                	mov    %esp,%ebp
  800b61:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b64:	8b 45 08             	mov    0x8(%ebp),%eax
  800b67:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b6a:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b6d:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b70:	8b 45 08             	mov    0x8(%ebp),%eax
  800b73:	01 d0                	add    %edx,%eax
  800b75:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b78:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b7f:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b83:	74 06                	je     800b8b <vsnprintf+0x2d>
  800b85:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b89:	7f 07                	jg     800b92 <vsnprintf+0x34>
		return -E_INVAL;
  800b8b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b90:	eb 2a                	jmp    800bbc <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b92:	8b 45 14             	mov    0x14(%ebp),%eax
  800b95:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b99:	8b 45 10             	mov    0x10(%ebp),%eax
  800b9c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800ba0:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800ba3:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba7:	c7 04 24 29 0b 80 00 	movl   $0x800b29,(%esp)
  800bae:	e8 29 fb ff ff       	call   8006dc <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bb3:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb6:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bb9:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bbc:	c9                   	leave  
  800bbd:	c3                   	ret    

00800bbe <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bbe:	55                   	push   %ebp
  800bbf:	89 e5                	mov    %esp,%ebp
  800bc1:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bc4:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc7:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bcd:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bd1:	8b 45 10             	mov    0x10(%ebp),%eax
  800bd4:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdb:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bdf:	8b 45 08             	mov    0x8(%ebp),%eax
  800be2:	89 04 24             	mov    %eax,(%esp)
  800be5:	e8 74 ff ff ff       	call   800b5e <vsnprintf>
  800bea:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800bed:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bf0:	c9                   	leave  
  800bf1:	c3                   	ret    

00800bf2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bf2:	55                   	push   %ebp
  800bf3:	89 e5                	mov    %esp,%ebp
  800bf5:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bf8:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bff:	eb 08                	jmp    800c09 <strlen+0x17>
		n++;
  800c01:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c05:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c09:	8b 45 08             	mov    0x8(%ebp),%eax
  800c0c:	0f b6 00             	movzbl (%eax),%eax
  800c0f:	84 c0                	test   %al,%al
  800c11:	75 ee                	jne    800c01 <strlen+0xf>
		n++;
	return n;
  800c13:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c16:	c9                   	leave  
  800c17:	c3                   	ret    

00800c18 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c18:	55                   	push   %ebp
  800c19:	89 e5                	mov    %esp,%ebp
  800c1b:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c1e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c25:	eb 0c                	jmp    800c33 <strnlen+0x1b>
		n++;
  800c27:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c2b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c2f:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c33:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c37:	74 0a                	je     800c43 <strnlen+0x2b>
  800c39:	8b 45 08             	mov    0x8(%ebp),%eax
  800c3c:	0f b6 00             	movzbl (%eax),%eax
  800c3f:	84 c0                	test   %al,%al
  800c41:	75 e4                	jne    800c27 <strnlen+0xf>
		n++;
	return n;
  800c43:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c46:	c9                   	leave  
  800c47:	c3                   	ret    

00800c48 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c48:	55                   	push   %ebp
  800c49:	89 e5                	mov    %esp,%ebp
  800c4b:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c4e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c51:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c54:	90                   	nop
  800c55:	8b 45 08             	mov    0x8(%ebp),%eax
  800c58:	8d 50 01             	lea    0x1(%eax),%edx
  800c5b:	89 55 08             	mov    %edx,0x8(%ebp)
  800c5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c61:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c64:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c67:	0f b6 12             	movzbl (%edx),%edx
  800c6a:	88 10                	mov    %dl,(%eax)
  800c6c:	0f b6 00             	movzbl (%eax),%eax
  800c6f:	84 c0                	test   %al,%al
  800c71:	75 e2                	jne    800c55 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c73:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c76:	c9                   	leave  
  800c77:	c3                   	ret    

00800c78 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c78:	55                   	push   %ebp
  800c79:	89 e5                	mov    %esp,%ebp
  800c7b:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c7e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c81:	89 04 24             	mov    %eax,(%esp)
  800c84:	e8 69 ff ff ff       	call   800bf2 <strlen>
  800c89:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c8c:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c92:	01 c2                	add    %eax,%edx
  800c94:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c97:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c9b:	89 14 24             	mov    %edx,(%esp)
  800c9e:	e8 a5 ff ff ff       	call   800c48 <strcpy>
	return dst;
  800ca3:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca6:	c9                   	leave  
  800ca7:	c3                   	ret    

00800ca8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800cae:	8b 45 08             	mov    0x8(%ebp),%eax
  800cb1:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800cb4:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cbb:	eb 23                	jmp    800ce0 <strncpy+0x38>
		*dst++ = *src;
  800cbd:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc0:	8d 50 01             	lea    0x1(%eax),%edx
  800cc3:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc6:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc9:	0f b6 12             	movzbl (%edx),%edx
  800ccc:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cce:	8b 45 0c             	mov    0xc(%ebp),%eax
  800cd1:	0f b6 00             	movzbl (%eax),%eax
  800cd4:	84 c0                	test   %al,%al
  800cd6:	74 04                	je     800cdc <strncpy+0x34>
			src++;
  800cd8:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cdc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800ce0:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800ce3:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ce6:	72 d5                	jb     800cbd <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ce8:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ceb:	c9                   	leave  
  800cec:	c3                   	ret    

00800ced <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ced:	55                   	push   %ebp
  800cee:	89 e5                	mov    %esp,%ebp
  800cf0:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cf3:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cf9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cfd:	74 33                	je     800d32 <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cff:	eb 17                	jmp    800d18 <strlcpy+0x2b>
			*dst++ = *src++;
  800d01:	8b 45 08             	mov    0x8(%ebp),%eax
  800d04:	8d 50 01             	lea    0x1(%eax),%edx
  800d07:	89 55 08             	mov    %edx,0x8(%ebp)
  800d0a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d0d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d10:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d13:	0f b6 12             	movzbl (%edx),%edx
  800d16:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d18:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d1c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d20:	74 0a                	je     800d2c <strlcpy+0x3f>
  800d22:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d25:	0f b6 00             	movzbl (%eax),%eax
  800d28:	84 c0                	test   %al,%al
  800d2a:	75 d5                	jne    800d01 <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d2c:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d32:	8b 55 08             	mov    0x8(%ebp),%edx
  800d35:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d38:	29 c2                	sub    %eax,%edx
  800d3a:	89 d0                	mov    %edx,%eax
}
  800d3c:	c9                   	leave  
  800d3d:	c3                   	ret    

00800d3e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d3e:	55                   	push   %ebp
  800d3f:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d41:	eb 08                	jmp    800d4b <strcmp+0xd>
		p++, q++;
  800d43:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d47:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d4b:	8b 45 08             	mov    0x8(%ebp),%eax
  800d4e:	0f b6 00             	movzbl (%eax),%eax
  800d51:	84 c0                	test   %al,%al
  800d53:	74 10                	je     800d65 <strcmp+0x27>
  800d55:	8b 45 08             	mov    0x8(%ebp),%eax
  800d58:	0f b6 10             	movzbl (%eax),%edx
  800d5b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d5e:	0f b6 00             	movzbl (%eax),%eax
  800d61:	38 c2                	cmp    %al,%dl
  800d63:	74 de                	je     800d43 <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d65:	8b 45 08             	mov    0x8(%ebp),%eax
  800d68:	0f b6 00             	movzbl (%eax),%eax
  800d6b:	0f b6 d0             	movzbl %al,%edx
  800d6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d71:	0f b6 00             	movzbl (%eax),%eax
  800d74:	0f b6 c0             	movzbl %al,%eax
  800d77:	29 c2                	sub    %eax,%edx
  800d79:	89 d0                	mov    %edx,%eax
}
  800d7b:	5d                   	pop    %ebp
  800d7c:	c3                   	ret    

00800d7d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d7d:	55                   	push   %ebp
  800d7e:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d80:	eb 0c                	jmp    800d8e <strncmp+0x11>
		n--, p++, q++;
  800d82:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d86:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d8a:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d8e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d92:	74 1a                	je     800dae <strncmp+0x31>
  800d94:	8b 45 08             	mov    0x8(%ebp),%eax
  800d97:	0f b6 00             	movzbl (%eax),%eax
  800d9a:	84 c0                	test   %al,%al
  800d9c:	74 10                	je     800dae <strncmp+0x31>
  800d9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800da1:	0f b6 10             	movzbl (%eax),%edx
  800da4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da7:	0f b6 00             	movzbl (%eax),%eax
  800daa:	38 c2                	cmp    %al,%dl
  800dac:	74 d4                	je     800d82 <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800dae:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800db2:	75 07                	jne    800dbb <strncmp+0x3e>
		return 0;
  800db4:	b8 00 00 00 00       	mov    $0x0,%eax
  800db9:	eb 16                	jmp    800dd1 <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800dbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800dbe:	0f b6 00             	movzbl (%eax),%eax
  800dc1:	0f b6 d0             	movzbl %al,%edx
  800dc4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc7:	0f b6 00             	movzbl (%eax),%eax
  800dca:	0f b6 c0             	movzbl %al,%eax
  800dcd:	29 c2                	sub    %eax,%edx
  800dcf:	89 d0                	mov    %edx,%eax
}
  800dd1:	5d                   	pop    %ebp
  800dd2:	c3                   	ret    

00800dd3 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dd3:	55                   	push   %ebp
  800dd4:	89 e5                	mov    %esp,%ebp
  800dd6:	83 ec 04             	sub    $0x4,%esp
  800dd9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ddc:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800ddf:	eb 14                	jmp    800df5 <strchr+0x22>
		if (*s == c)
  800de1:	8b 45 08             	mov    0x8(%ebp),%eax
  800de4:	0f b6 00             	movzbl (%eax),%eax
  800de7:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800dea:	75 05                	jne    800df1 <strchr+0x1e>
			return (char *) s;
  800dec:	8b 45 08             	mov    0x8(%ebp),%eax
  800def:	eb 13                	jmp    800e04 <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800df1:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df5:	8b 45 08             	mov    0x8(%ebp),%eax
  800df8:	0f b6 00             	movzbl (%eax),%eax
  800dfb:	84 c0                	test   %al,%al
  800dfd:	75 e2                	jne    800de1 <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e04:	c9                   	leave  
  800e05:	c3                   	ret    

00800e06 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e06:	55                   	push   %ebp
  800e07:	89 e5                	mov    %esp,%ebp
  800e09:	83 ec 04             	sub    $0x4,%esp
  800e0c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0f:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e12:	eb 11                	jmp    800e25 <strfind+0x1f>
		if (*s == c)
  800e14:	8b 45 08             	mov    0x8(%ebp),%eax
  800e17:	0f b6 00             	movzbl (%eax),%eax
  800e1a:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e1d:	75 02                	jne    800e21 <strfind+0x1b>
			break;
  800e1f:	eb 0e                	jmp    800e2f <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e21:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e25:	8b 45 08             	mov    0x8(%ebp),%eax
  800e28:	0f b6 00             	movzbl (%eax),%eax
  800e2b:	84 c0                	test   %al,%al
  800e2d:	75 e5                	jne    800e14 <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e32:	c9                   	leave  
  800e33:	c3                   	ret    

00800e34 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e34:	55                   	push   %ebp
  800e35:	89 e5                	mov    %esp,%ebp
  800e37:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e3c:	75 05                	jne    800e43 <memset+0xf>
		return v;
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	eb 5c                	jmp    800e9f <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e43:	8b 45 08             	mov    0x8(%ebp),%eax
  800e46:	83 e0 03             	and    $0x3,%eax
  800e49:	85 c0                	test   %eax,%eax
  800e4b:	75 41                	jne    800e8e <memset+0x5a>
  800e4d:	8b 45 10             	mov    0x10(%ebp),%eax
  800e50:	83 e0 03             	and    $0x3,%eax
  800e53:	85 c0                	test   %eax,%eax
  800e55:	75 37                	jne    800e8e <memset+0x5a>
		c &= 0xFF;
  800e57:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e5e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e61:	c1 e0 18             	shl    $0x18,%eax
  800e64:	89 c2                	mov    %eax,%edx
  800e66:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e69:	c1 e0 10             	shl    $0x10,%eax
  800e6c:	09 c2                	or     %eax,%edx
  800e6e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e71:	c1 e0 08             	shl    $0x8,%eax
  800e74:	09 d0                	or     %edx,%eax
  800e76:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e79:	8b 45 10             	mov    0x10(%ebp),%eax
  800e7c:	c1 e8 02             	shr    $0x2,%eax
  800e7f:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e81:	8b 55 08             	mov    0x8(%ebp),%edx
  800e84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e87:	89 d7                	mov    %edx,%edi
  800e89:	fc                   	cld    
  800e8a:	f3 ab                	rep stos %eax,%es:(%edi)
  800e8c:	eb 0e                	jmp    800e9c <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e8e:	8b 55 08             	mov    0x8(%ebp),%edx
  800e91:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e94:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e97:	89 d7                	mov    %edx,%edi
  800e99:	fc                   	cld    
  800e9a:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e9c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e9f:	5f                   	pop    %edi
  800ea0:	5d                   	pop    %ebp
  800ea1:	c3                   	ret    

00800ea2 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800ea2:	55                   	push   %ebp
  800ea3:	89 e5                	mov    %esp,%ebp
  800ea5:	57                   	push   %edi
  800ea6:	56                   	push   %esi
  800ea7:	53                   	push   %ebx
  800ea8:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800eab:	8b 45 0c             	mov    0xc(%ebp),%eax
  800eae:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eb1:	8b 45 08             	mov    0x8(%ebp),%eax
  800eb4:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eb7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eba:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ebd:	73 6d                	jae    800f2c <memmove+0x8a>
  800ebf:	8b 45 10             	mov    0x10(%ebp),%eax
  800ec2:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec5:	01 d0                	add    %edx,%eax
  800ec7:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eca:	76 60                	jbe    800f2c <memmove+0x8a>
		s += n;
  800ecc:	8b 45 10             	mov    0x10(%ebp),%eax
  800ecf:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ed2:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed5:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800edb:	83 e0 03             	and    $0x3,%eax
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	75 2f                	jne    800f11 <memmove+0x6f>
  800ee2:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee5:	83 e0 03             	and    $0x3,%eax
  800ee8:	85 c0                	test   %eax,%eax
  800eea:	75 25                	jne    800f11 <memmove+0x6f>
  800eec:	8b 45 10             	mov    0x10(%ebp),%eax
  800eef:	83 e0 03             	and    $0x3,%eax
  800ef2:	85 c0                	test   %eax,%eax
  800ef4:	75 1b                	jne    800f11 <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef6:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef9:	83 e8 04             	sub    $0x4,%eax
  800efc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800eff:	83 ea 04             	sub    $0x4,%edx
  800f02:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f05:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f08:	89 c7                	mov    %eax,%edi
  800f0a:	89 d6                	mov    %edx,%esi
  800f0c:	fd                   	std    
  800f0d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0f:	eb 18                	jmp    800f29 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f11:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f14:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f17:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f1a:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f1d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f20:	89 d7                	mov    %edx,%edi
  800f22:	89 de                	mov    %ebx,%esi
  800f24:	89 c1                	mov    %eax,%ecx
  800f26:	fd                   	std    
  800f27:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f29:	fc                   	cld    
  800f2a:	eb 45                	jmp    800f71 <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2f:	83 e0 03             	and    $0x3,%eax
  800f32:	85 c0                	test   %eax,%eax
  800f34:	75 2b                	jne    800f61 <memmove+0xbf>
  800f36:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f39:	83 e0 03             	and    $0x3,%eax
  800f3c:	85 c0                	test   %eax,%eax
  800f3e:	75 21                	jne    800f61 <memmove+0xbf>
  800f40:	8b 45 10             	mov    0x10(%ebp),%eax
  800f43:	83 e0 03             	and    $0x3,%eax
  800f46:	85 c0                	test   %eax,%eax
  800f48:	75 17                	jne    800f61 <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f4a:	8b 45 10             	mov    0x10(%ebp),%eax
  800f4d:	c1 e8 02             	shr    $0x2,%eax
  800f50:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f52:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f55:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f58:	89 c7                	mov    %eax,%edi
  800f5a:	89 d6                	mov    %edx,%esi
  800f5c:	fc                   	cld    
  800f5d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5f:	eb 10                	jmp    800f71 <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f61:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f64:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f67:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f6a:	89 c7                	mov    %eax,%edi
  800f6c:	89 d6                	mov    %edx,%esi
  800f6e:	fc                   	cld    
  800f6f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f71:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	5b                   	pop    %ebx
  800f78:	5e                   	pop    %esi
  800f79:	5f                   	pop    %edi
  800f7a:	5d                   	pop    %ebp
  800f7b:	c3                   	ret    

00800f7c <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f7c:	55                   	push   %ebp
  800f7d:	89 e5                	mov    %esp,%ebp
  800f7f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f82:	8b 45 10             	mov    0x10(%ebp),%eax
  800f85:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f89:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f8c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f90:	8b 45 08             	mov    0x8(%ebp),%eax
  800f93:	89 04 24             	mov    %eax,(%esp)
  800f96:	e8 07 ff ff ff       	call   800ea2 <memmove>
}
  800f9b:	c9                   	leave  
  800f9c:	c3                   	ret    

00800f9d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800fa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa6:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fa9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fac:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800faf:	eb 30                	jmp    800fe1 <memcmp+0x44>
		if (*s1 != *s2)
  800fb1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fb4:	0f b6 10             	movzbl (%eax),%edx
  800fb7:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fba:	0f b6 00             	movzbl (%eax),%eax
  800fbd:	38 c2                	cmp    %al,%dl
  800fbf:	74 18                	je     800fd9 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fc1:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fc4:	0f b6 00             	movzbl (%eax),%eax
  800fc7:	0f b6 d0             	movzbl %al,%edx
  800fca:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fcd:	0f b6 00             	movzbl (%eax),%eax
  800fd0:	0f b6 c0             	movzbl %al,%eax
  800fd3:	29 c2                	sub    %eax,%edx
  800fd5:	89 d0                	mov    %edx,%eax
  800fd7:	eb 1a                	jmp    800ff3 <memcmp+0x56>
		s1++, s2++;
  800fd9:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fdd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fe1:	8b 45 10             	mov    0x10(%ebp),%eax
  800fe4:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe7:	89 55 10             	mov    %edx,0x10(%ebp)
  800fea:	85 c0                	test   %eax,%eax
  800fec:	75 c3                	jne    800fb1 <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fee:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ff3:	c9                   	leave  
  800ff4:	c3                   	ret    

00800ff5 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff5:	55                   	push   %ebp
  800ff6:	89 e5                	mov    %esp,%ebp
  800ff8:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ffb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ffe:	8b 55 08             	mov    0x8(%ebp),%edx
  801001:	01 d0                	add    %edx,%eax
  801003:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801006:	eb 13                	jmp    80101b <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801008:	8b 45 08             	mov    0x8(%ebp),%eax
  80100b:	0f b6 10             	movzbl (%eax),%edx
  80100e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801011:	38 c2                	cmp    %al,%dl
  801013:	75 02                	jne    801017 <memfind+0x22>
			break;
  801015:	eb 0c                	jmp    801023 <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801017:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80101b:	8b 45 08             	mov    0x8(%ebp),%eax
  80101e:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  801021:	72 e5                	jb     801008 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  801023:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801026:	c9                   	leave  
  801027:	c3                   	ret    

00801028 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801028:	55                   	push   %ebp
  801029:	89 e5                	mov    %esp,%ebp
  80102b:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  80102e:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801035:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103c:	eb 04                	jmp    801042 <strtol+0x1a>
		s++;
  80103e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801042:	8b 45 08             	mov    0x8(%ebp),%eax
  801045:	0f b6 00             	movzbl (%eax),%eax
  801048:	3c 20                	cmp    $0x20,%al
  80104a:	74 f2                	je     80103e <strtol+0x16>
  80104c:	8b 45 08             	mov    0x8(%ebp),%eax
  80104f:	0f b6 00             	movzbl (%eax),%eax
  801052:	3c 09                	cmp    $0x9,%al
  801054:	74 e8                	je     80103e <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801056:	8b 45 08             	mov    0x8(%ebp),%eax
  801059:	0f b6 00             	movzbl (%eax),%eax
  80105c:	3c 2b                	cmp    $0x2b,%al
  80105e:	75 06                	jne    801066 <strtol+0x3e>
		s++;
  801060:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801064:	eb 15                	jmp    80107b <strtol+0x53>
	else if (*s == '-')
  801066:	8b 45 08             	mov    0x8(%ebp),%eax
  801069:	0f b6 00             	movzbl (%eax),%eax
  80106c:	3c 2d                	cmp    $0x2d,%al
  80106e:	75 0b                	jne    80107b <strtol+0x53>
		s++, neg = 1;
  801070:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801074:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80107b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80107f:	74 06                	je     801087 <strtol+0x5f>
  801081:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801085:	75 24                	jne    8010ab <strtol+0x83>
  801087:	8b 45 08             	mov    0x8(%ebp),%eax
  80108a:	0f b6 00             	movzbl (%eax),%eax
  80108d:	3c 30                	cmp    $0x30,%al
  80108f:	75 1a                	jne    8010ab <strtol+0x83>
  801091:	8b 45 08             	mov    0x8(%ebp),%eax
  801094:	83 c0 01             	add    $0x1,%eax
  801097:	0f b6 00             	movzbl (%eax),%eax
  80109a:	3c 78                	cmp    $0x78,%al
  80109c:	75 0d                	jne    8010ab <strtol+0x83>
		s += 2, base = 16;
  80109e:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  8010a2:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010a9:	eb 2a                	jmp    8010d5 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010ab:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010af:	75 17                	jne    8010c8 <strtol+0xa0>
  8010b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b4:	0f b6 00             	movzbl (%eax),%eax
  8010b7:	3c 30                	cmp    $0x30,%al
  8010b9:	75 0d                	jne    8010c8 <strtol+0xa0>
		s++, base = 8;
  8010bb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010bf:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010c6:	eb 0d                	jmp    8010d5 <strtol+0xad>
	else if (base == 0)
  8010c8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010cc:	75 07                	jne    8010d5 <strtol+0xad>
		base = 10;
  8010ce:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d8:	0f b6 00             	movzbl (%eax),%eax
  8010db:	3c 2f                	cmp    $0x2f,%al
  8010dd:	7e 1b                	jle    8010fa <strtol+0xd2>
  8010df:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e2:	0f b6 00             	movzbl (%eax),%eax
  8010e5:	3c 39                	cmp    $0x39,%al
  8010e7:	7f 11                	jg     8010fa <strtol+0xd2>
			dig = *s - '0';
  8010e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8010ec:	0f b6 00             	movzbl (%eax),%eax
  8010ef:	0f be c0             	movsbl %al,%eax
  8010f2:	83 e8 30             	sub    $0x30,%eax
  8010f5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f8:	eb 48                	jmp    801142 <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8010fd:	0f b6 00             	movzbl (%eax),%eax
  801100:	3c 60                	cmp    $0x60,%al
  801102:	7e 1b                	jle    80111f <strtol+0xf7>
  801104:	8b 45 08             	mov    0x8(%ebp),%eax
  801107:	0f b6 00             	movzbl (%eax),%eax
  80110a:	3c 7a                	cmp    $0x7a,%al
  80110c:	7f 11                	jg     80111f <strtol+0xf7>
			dig = *s - 'a' + 10;
  80110e:	8b 45 08             	mov    0x8(%ebp),%eax
  801111:	0f b6 00             	movzbl (%eax),%eax
  801114:	0f be c0             	movsbl %al,%eax
  801117:	83 e8 57             	sub    $0x57,%eax
  80111a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  80111d:	eb 23                	jmp    801142 <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80111f:	8b 45 08             	mov    0x8(%ebp),%eax
  801122:	0f b6 00             	movzbl (%eax),%eax
  801125:	3c 40                	cmp    $0x40,%al
  801127:	7e 3d                	jle    801166 <strtol+0x13e>
  801129:	8b 45 08             	mov    0x8(%ebp),%eax
  80112c:	0f b6 00             	movzbl (%eax),%eax
  80112f:	3c 5a                	cmp    $0x5a,%al
  801131:	7f 33                	jg     801166 <strtol+0x13e>
			dig = *s - 'A' + 10;
  801133:	8b 45 08             	mov    0x8(%ebp),%eax
  801136:	0f b6 00             	movzbl (%eax),%eax
  801139:	0f be c0             	movsbl %al,%eax
  80113c:	83 e8 37             	sub    $0x37,%eax
  80113f:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  801142:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801145:	3b 45 10             	cmp    0x10(%ebp),%eax
  801148:	7c 02                	jl     80114c <strtol+0x124>
			break;
  80114a:	eb 1a                	jmp    801166 <strtol+0x13e>
		s++, val = (val * base) + dig;
  80114c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801150:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801153:	0f af 45 10          	imul   0x10(%ebp),%eax
  801157:	89 c2                	mov    %eax,%edx
  801159:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80115c:	01 d0                	add    %edx,%eax
  80115e:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  801161:	e9 6f ff ff ff       	jmp    8010d5 <strtol+0xad>

	if (endptr)
  801166:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  80116a:	74 08                	je     801174 <strtol+0x14c>
		*endptr = (char *) s;
  80116c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116f:	8b 55 08             	mov    0x8(%ebp),%edx
  801172:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  801174:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801178:	74 07                	je     801181 <strtol+0x159>
  80117a:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80117d:	f7 d8                	neg    %eax
  80117f:	eb 03                	jmp    801184 <strtol+0x15c>
  801181:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  801184:	c9                   	leave  
  801185:	c3                   	ret    
  801186:	66 90                	xchg   %ax,%ax
  801188:	66 90                	xchg   %ax,%ax
  80118a:	66 90                	xchg   %ax,%ax
  80118c:	66 90                	xchg   %ax,%ax
  80118e:	66 90                	xchg   %ax,%ax

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
