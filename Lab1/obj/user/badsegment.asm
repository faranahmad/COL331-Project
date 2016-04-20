
obj/user/badsegment:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	83 ec 18             	sub    $0x18,%esp
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	// thisenv = 0;
	thisenv = &envs[ENVX(sys_getenvid())];
  800044:	e8 81 01 00 00       	call   8001ca <sys_getenvid>
  800049:	25 ff 03 00 00       	and    $0x3ff,%eax
  80004e:	c1 e0 02             	shl    $0x2,%eax
  800051:	89 c2                	mov    %eax,%edx
  800053:	c1 e2 05             	shl    $0x5,%edx
  800056:	29 c2                	sub    %eax,%edx
  800058:	8d 82 00 00 c0 ee    	lea    -0x11400000(%edx),%eax
  80005e:	a3 04 20 80 00       	mov    %eax,0x802004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800063:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800067:	7e 0a                	jle    800073 <libmain+0x35>
		binaryname = argv[0];
  800069:	8b 45 0c             	mov    0xc(%ebp),%eax
  80006c:	8b 00                	mov    (%eax),%eax
  80006e:	a3 00 20 80 00       	mov    %eax,0x802000

	// call user main routine
	umain(argc, argv);
  800073:	8b 45 0c             	mov    0xc(%ebp),%eax
  800076:	89 44 24 04          	mov    %eax,0x4(%esp)
  80007a:	8b 45 08             	mov    0x8(%ebp),%eax
  80007d:	89 04 24             	mov    %eax,(%esp)
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 02 00 00 00       	call   80008c <exit>
}
  80008a:	c9                   	leave  
  80008b:	c3                   	ret    

0080008c <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 18             	sub    $0x18,%esp
	sys_env_destroy(0);
  800092:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800099:	e8 e9 00 00 00       	call   800187 <sys_env_destroy>
}
  80009e:	c9                   	leave  
  80009f:	c3                   	ret    

008000a0 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a0:	55                   	push   %ebp
  8000a1:	89 e5                	mov    %esp,%ebp
  8000a3:	57                   	push   %edi
  8000a4:	56                   	push   %esi
  8000a5:	53                   	push   %ebx
  8000a6:	83 ec 3c             	sub    $0x3c,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000a9:	8b 45 08             	mov    0x8(%ebp),%eax
  8000ac:	8b 55 10             	mov    0x10(%ebp),%edx
  8000af:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8000b2:	8b 5d 18             	mov    0x18(%ebp),%ebx
  8000b5:	8b 7d 1c             	mov    0x1c(%ebp),%edi
  8000b8:	8b 75 20             	mov    0x20(%ebp),%esi
  8000bb:	cd 30                	int    $0x30
  8000bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
		  "b" (a3),
		  "D" (a4),
		  "S" (a5)
		: "cc", "memory");

	if(check && ret > 0)
  8000c0:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8000c4:	74 30                	je     8000f6 <syscall+0x56>
  8000c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000ca:	7e 2a                	jle    8000f6 <syscall+0x56>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000cc:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8000cf:	89 44 24 10          	mov    %eax,0x10(%esp)
  8000d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8000d6:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8000da:	c7 44 24 08 2a 14 80 	movl   $0x80142a,0x8(%esp)
  8000e1:	00 
  8000e2:	c7 44 24 04 23 00 00 	movl   $0x23,0x4(%esp)
  8000e9:	00 
  8000ea:	c7 04 24 47 14 80 00 	movl   $0x801447,(%esp)
  8000f1:	e8 2c 03 00 00       	call   800422 <_panic>

	return ret;
  8000f6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
}
  8000f9:	83 c4 3c             	add    $0x3c,%esp
  8000fc:	5b                   	pop    %ebx
  8000fd:	5e                   	pop    %esi
  8000fe:	5f                   	pop    %edi
  8000ff:	5d                   	pop    %ebp
  800100:	c3                   	ret    

00800101 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800101:	55                   	push   %ebp
  800102:	89 e5                	mov    %esp,%ebp
  800104:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800107:	8b 45 08             	mov    0x8(%ebp),%eax
  80010a:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800111:	00 
  800112:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800119:	00 
  80011a:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800121:	00 
  800122:	8b 55 0c             	mov    0xc(%ebp),%edx
  800125:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800129:	89 44 24 08          	mov    %eax,0x8(%esp)
  80012d:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800134:	00 
  800135:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  80013c:	e8 5f ff ff ff       	call   8000a0 <syscall>
}
  800141:	c9                   	leave  
  800142:	c3                   	ret    

00800143 <sys_cgetc>:

int
sys_cgetc(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800149:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800150:	00 
  800151:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800158:	00 
  800159:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800160:	00 
  800161:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800168:	00 
  800169:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  800170:	00 
  800171:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800178:	00 
  800179:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800180:	e8 1b ff ff ff       	call   8000a0 <syscall>
}
  800185:	c9                   	leave  
  800186:	c3                   	ret    

00800187 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80018d:	8b 45 08             	mov    0x8(%ebp),%eax
  800190:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800197:	00 
  800198:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  80019f:	00 
  8001a0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001a7:	00 
  8001a8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001af:	00 
  8001b0:	89 44 24 08          	mov    %eax,0x8(%esp)
  8001b4:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8001bb:	00 
  8001bc:	c7 04 24 03 00 00 00 	movl   $0x3,(%esp)
  8001c3:	e8 d8 fe ff ff       	call   8000a0 <syscall>
}
  8001c8:	c9                   	leave  
  8001c9:	c3                   	ret    

008001ca <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8001ca:	55                   	push   %ebp
  8001cb:	89 e5                	mov    %esp,%ebp
  8001cd:	83 ec 28             	sub    $0x28,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001d0:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8001d7:	00 
  8001d8:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8001df:	00 
  8001e0:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8001e7:	00 
  8001e8:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  8001ef:	00 
  8001f0:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  8001f7:	00 
  8001f8:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8001ff:	00 
  800200:	c7 04 24 02 00 00 00 	movl   $0x2,(%esp)
  800207:	e8 94 fe ff ff       	call   8000a0 <syscall>
}
  80020c:	c9                   	leave  
  80020d:	c3                   	ret    

0080020e <sys_yield>:

void
sys_yield(void)
{
  80020e:	55                   	push   %ebp
  80020f:	89 e5                	mov    %esp,%ebp
  800211:	83 ec 28             	sub    $0x28,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800214:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80021b:	00 
  80021c:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800223:	00 
  800224:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80022b:	00 
  80022c:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800233:	00 
  800234:	c7 44 24 08 00 00 00 	movl   $0x0,0x8(%esp)
  80023b:	00 
  80023c:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  800243:	00 
  800244:	c7 04 24 0a 00 00 00 	movl   $0xa,(%esp)
  80024b:	e8 50 fe ff ff       	call   8000a0 <syscall>
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800258:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80025b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80025e:	8b 45 08             	mov    0x8(%ebp),%eax
  800261:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800268:	00 
  800269:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800270:	00 
  800271:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  800275:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800279:	89 44 24 08          	mov    %eax,0x8(%esp)
  80027d:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800284:	00 
  800285:	c7 04 24 04 00 00 00 	movl   $0x4,(%esp)
  80028c:	e8 0f fe ff ff       	call   8000a0 <syscall>
}
  800291:	c9                   	leave  
  800292:	c3                   	ret    

00800293 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800293:	55                   	push   %ebp
  800294:	89 e5                	mov    %esp,%ebp
  800296:	56                   	push   %esi
  800297:	53                   	push   %ebx
  800298:	83 ec 20             	sub    $0x20,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80029b:	8b 75 18             	mov    0x18(%ebp),%esi
  80029e:	8b 5d 14             	mov    0x14(%ebp),%ebx
  8002a1:	8b 4d 10             	mov    0x10(%ebp),%ecx
  8002a4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002aa:	89 74 24 18          	mov    %esi,0x18(%esp)
  8002ae:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8002b2:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8002b6:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8002ba:	89 44 24 08          	mov    %eax,0x8(%esp)
  8002be:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  8002c5:	00 
  8002c6:	c7 04 24 05 00 00 00 	movl   $0x5,(%esp)
  8002cd:	e8 ce fd ff ff       	call   8000a0 <syscall>
}
  8002d2:	83 c4 20             	add    $0x20,%esp
  8002d5:	5b                   	pop    %ebx
  8002d6:	5e                   	pop    %esi
  8002d7:	5d                   	pop    %ebp
  8002d8:	c3                   	ret    

008002d9 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8002d9:	55                   	push   %ebp
  8002da:	89 e5                	mov    %esp,%ebp
  8002dc:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8002df:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8002ec:	00 
  8002ed:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8002f4:	00 
  8002f5:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8002fc:	00 
  8002fd:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800301:	89 44 24 08          	mov    %eax,0x8(%esp)
  800305:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80030c:	00 
  80030d:	c7 04 24 06 00 00 00 	movl   $0x6,(%esp)
  800314:	e8 87 fd ff ff       	call   8000a0 <syscall>
}
  800319:	c9                   	leave  
  80031a:	c3                   	ret    

0080031b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80031b:	55                   	push   %ebp
  80031c:	89 e5                	mov    %esp,%ebp
  80031e:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800321:	8b 55 0c             	mov    0xc(%ebp),%edx
  800324:	8b 45 08             	mov    0x8(%ebp),%eax
  800327:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  80032e:	00 
  80032f:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800336:	00 
  800337:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  80033e:	00 
  80033f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800343:	89 44 24 08          	mov    %eax,0x8(%esp)
  800347:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  80034e:	00 
  80034f:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
  800356:	e8 45 fd ff ff       	call   8000a0 <syscall>
}
  80035b:	c9                   	leave  
  80035c:	c3                   	ret    

0080035d <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800363:	8b 55 0c             	mov    0xc(%ebp),%edx
  800366:	8b 45 08             	mov    0x8(%ebp),%eax
  800369:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  800370:	00 
  800371:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  800378:	00 
  800379:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  800380:	00 
  800381:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800385:	89 44 24 08          	mov    %eax,0x8(%esp)
  800389:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800390:	00 
  800391:	c7 04 24 09 00 00 00 	movl   $0x9,(%esp)
  800398:	e8 03 fd ff ff       	call   8000a0 <syscall>
}
  80039d:	c9                   	leave  
  80039e:	c3                   	ret    

0080039f <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80039f:	55                   	push   %ebp
  8003a0:	89 e5                	mov    %esp,%ebp
  8003a2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8003a5:	8b 4d 14             	mov    0x14(%ebp),%ecx
  8003a8:	8b 55 10             	mov    0x10(%ebp),%edx
  8003ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ae:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003b5:	00 
  8003b6:	89 4c 24 14          	mov    %ecx,0x14(%esp)
  8003ba:	89 54 24 10          	mov    %edx,0x10(%esp)
  8003be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c1:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8003c5:	89 44 24 08          	mov    %eax,0x8(%esp)
  8003c9:	c7 44 24 04 00 00 00 	movl   $0x0,0x4(%esp)
  8003d0:	00 
  8003d1:	c7 04 24 0b 00 00 00 	movl   $0xb,(%esp)
  8003d8:	e8 c3 fc ff ff       	call   8000a0 <syscall>
}
  8003dd:	c9                   	leave  
  8003de:	c3                   	ret    

008003df <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8003df:	55                   	push   %ebp
  8003e0:	89 e5                	mov    %esp,%ebp
  8003e2:	83 ec 28             	sub    $0x28,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8003e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8003e8:	c7 44 24 18 00 00 00 	movl   $0x0,0x18(%esp)
  8003ef:	00 
  8003f0:	c7 44 24 14 00 00 00 	movl   $0x0,0x14(%esp)
  8003f7:	00 
  8003f8:	c7 44 24 10 00 00 00 	movl   $0x0,0x10(%esp)
  8003ff:	00 
  800400:	c7 44 24 0c 00 00 00 	movl   $0x0,0xc(%esp)
  800407:	00 
  800408:	89 44 24 08          	mov    %eax,0x8(%esp)
  80040c:	c7 44 24 04 01 00 00 	movl   $0x1,0x4(%esp)
  800413:	00 
  800414:	c7 04 24 0c 00 00 00 	movl   $0xc,(%esp)
  80041b:	e8 80 fc ff ff       	call   8000a0 <syscall>
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    

00800422 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800422:	55                   	push   %ebp
  800423:	89 e5                	mov    %esp,%ebp
  800425:	53                   	push   %ebx
  800426:	83 ec 34             	sub    $0x34,%esp
	va_list ap;

	va_start(ap, fmt);
  800429:	8d 45 14             	lea    0x14(%ebp),%eax
  80042c:	89 45 f4             	mov    %eax,-0xc(%ebp)

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80042f:	8b 1d 00 20 80 00    	mov    0x802000,%ebx
  800435:	e8 90 fd ff ff       	call   8001ca <sys_getenvid>
  80043a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80043d:	89 54 24 10          	mov    %edx,0x10(%esp)
  800441:	8b 55 08             	mov    0x8(%ebp),%edx
  800444:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800448:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  80044c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800450:	c7 04 24 58 14 80 00 	movl   $0x801458,(%esp)
  800457:	e8 e1 00 00 00       	call   80053d <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80045c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80045f:	89 44 24 04          	mov    %eax,0x4(%esp)
  800463:	8b 45 10             	mov    0x10(%ebp),%eax
  800466:	89 04 24             	mov    %eax,(%esp)
  800469:	e8 6b 00 00 00       	call   8004d9 <vcprintf>
	cprintf("\n");
  80046e:	c7 04 24 7b 14 80 00 	movl   $0x80147b,(%esp)
  800475:	e8 c3 00 00 00       	call   80053d <cprintf>

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80047a:	cc                   	int3   
  80047b:	eb fd                	jmp    80047a <_panic+0x58>

0080047d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80047d:	55                   	push   %ebp
  80047e:	89 e5                	mov    %esp,%ebp
  800480:	83 ec 18             	sub    $0x18,%esp
	b->buf[b->idx++] = ch;
  800483:	8b 45 0c             	mov    0xc(%ebp),%eax
  800486:	8b 00                	mov    (%eax),%eax
  800488:	8d 48 01             	lea    0x1(%eax),%ecx
  80048b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80048e:	89 0a                	mov    %ecx,(%edx)
  800490:	8b 55 08             	mov    0x8(%ebp),%edx
  800493:	89 d1                	mov    %edx,%ecx
  800495:	8b 55 0c             	mov    0xc(%ebp),%edx
  800498:	88 4c 02 08          	mov    %cl,0x8(%edx,%eax,1)
	if (b->idx == 256-1) {
  80049c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80049f:	8b 00                	mov    (%eax),%eax
  8004a1:	3d ff 00 00 00       	cmp    $0xff,%eax
  8004a6:	75 20                	jne    8004c8 <putch+0x4b>
		sys_cputs(b->buf, b->idx);
  8004a8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004ab:	8b 00                	mov    (%eax),%eax
  8004ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8004b0:	83 c2 08             	add    $0x8,%edx
  8004b3:	89 44 24 04          	mov    %eax,0x4(%esp)
  8004b7:	89 14 24             	mov    %edx,(%esp)
  8004ba:	e8 42 fc ff ff       	call   800101 <sys_cputs>
		b->idx = 0;
  8004bf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004c2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	}
	b->cnt++;
  8004c8:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004cb:	8b 40 04             	mov    0x4(%eax),%eax
  8004ce:	8d 50 01             	lea    0x1(%eax),%edx
  8004d1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004d4:	89 50 04             	mov    %edx,0x4(%eax)
}
  8004d7:	c9                   	leave  
  8004d8:	c3                   	ret    

008004d9 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004d9:	55                   	push   %ebp
  8004da:	89 e5                	mov    %esp,%ebp
  8004dc:	81 ec 28 01 00 00    	sub    $0x128,%esp
	struct printbuf b;

	b.idx = 0;
  8004e2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004e9:	00 00 00 
	b.cnt = 0;
  8004ec:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004f3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004f6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8004f9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	89 44 24 08          	mov    %eax,0x8(%esp)
  800504:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80050a:	89 44 24 04          	mov    %eax,0x4(%esp)
  80050e:	c7 04 24 7d 04 80 00 	movl   $0x80047d,(%esp)
  800515:	e8 bd 01 00 00       	call   8006d7 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80051a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  800520:	89 44 24 04          	mov    %eax,0x4(%esp)
  800524:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80052a:	83 c0 08             	add    $0x8,%eax
  80052d:	89 04 24             	mov    %eax,(%esp)
  800530:	e8 cc fb ff ff       	call   800101 <sys_cputs>

	return b.cnt;
  800535:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800543:	8d 45 0c             	lea    0xc(%ebp),%eax
  800546:	89 45 f0             	mov    %eax,-0x10(%ebp)
	cnt = vcprintf(fmt, ap);
  800549:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80054c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800550:	8b 45 08             	mov    0x8(%ebp),%eax
  800553:	89 04 24             	mov    %eax,(%esp)
  800556:	e8 7e ff ff ff       	call   8004d9 <vcprintf>
  80055b:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return cnt;
  80055e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800561:	c9                   	leave  
  800562:	c3                   	ret    

00800563 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800563:	55                   	push   %ebp
  800564:	89 e5                	mov    %esp,%ebp
  800566:	53                   	push   %ebx
  800567:	83 ec 34             	sub    $0x34,%esp
  80056a:	8b 45 10             	mov    0x10(%ebp),%eax
  80056d:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800570:	8b 45 14             	mov    0x14(%ebp),%eax
  800573:	89 45 f4             	mov    %eax,-0xc(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800576:	8b 45 18             	mov    0x18(%ebp),%eax
  800579:	ba 00 00 00 00       	mov    $0x0,%edx
  80057e:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800581:	77 72                	ja     8005f5 <printnum+0x92>
  800583:	3b 55 f4             	cmp    -0xc(%ebp),%edx
  800586:	72 05                	jb     80058d <printnum+0x2a>
  800588:	3b 45 f0             	cmp    -0x10(%ebp),%eax
  80058b:	77 68                	ja     8005f5 <printnum+0x92>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80058d:	8b 45 1c             	mov    0x1c(%ebp),%eax
  800590:	8d 58 ff             	lea    -0x1(%eax),%ebx
  800593:	8b 45 18             	mov    0x18(%ebp),%eax
  800596:	ba 00 00 00 00       	mov    $0x0,%edx
  80059b:	89 44 24 08          	mov    %eax,0x8(%esp)
  80059f:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8005a6:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8005a9:	89 04 24             	mov    %eax,(%esp)
  8005ac:	89 54 24 04          	mov    %edx,0x4(%esp)
  8005b0:	e8 db 0b 00 00       	call   801190 <__udivdi3>
  8005b5:	8b 4d 20             	mov    0x20(%ebp),%ecx
  8005b8:	89 4c 24 18          	mov    %ecx,0x18(%esp)
  8005bc:	89 5c 24 14          	mov    %ebx,0x14(%esp)
  8005c0:	8b 4d 18             	mov    0x18(%ebp),%ecx
  8005c3:	89 4c 24 10          	mov    %ecx,0x10(%esp)
  8005c7:	89 44 24 08          	mov    %eax,0x8(%esp)
  8005cb:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8005cf:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005d2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8005d9:	89 04 24             	mov    %eax,(%esp)
  8005dc:	e8 82 ff ff ff       	call   800563 <printnum>
  8005e1:	eb 1c                	jmp    8005ff <printnum+0x9c>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8005e3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8005e6:	89 44 24 04          	mov    %eax,0x4(%esp)
  8005ea:	8b 45 20             	mov    0x20(%ebp),%eax
  8005ed:	89 04 24             	mov    %eax,(%esp)
  8005f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8005f3:	ff d0                	call   *%eax
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8005f5:	83 6d 1c 01          	subl   $0x1,0x1c(%ebp)
  8005f9:	83 7d 1c 00          	cmpl   $0x0,0x1c(%ebp)
  8005fd:	7f e4                	jg     8005e3 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005ff:	8b 4d 18             	mov    0x18(%ebp),%ecx
  800602:	bb 00 00 00 00       	mov    $0x0,%ebx
  800607:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80060a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80060d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800611:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800615:	89 04 24             	mov    %eax,(%esp)
  800618:	89 54 24 04          	mov    %edx,0x4(%esp)
  80061c:	e8 9f 0c 00 00       	call   8012c0 <__umoddi3>
  800621:	05 48 15 80 00       	add    $0x801548,%eax
  800626:	0f b6 00             	movzbl (%eax),%eax
  800629:	0f be c0             	movsbl %al,%eax
  80062c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80062f:	89 54 24 04          	mov    %edx,0x4(%esp)
  800633:	89 04 24             	mov    %eax,(%esp)
  800636:	8b 45 08             	mov    0x8(%ebp),%eax
  800639:	ff d0                	call   *%eax
}
  80063b:	83 c4 34             	add    $0x34,%esp
  80063e:	5b                   	pop    %ebx
  80063f:	5d                   	pop    %ebp
  800640:	c3                   	ret    

00800641 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  800641:	55                   	push   %ebp
  800642:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800644:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800648:	7e 14                	jle    80065e <getuint+0x1d>
		return va_arg(*ap, unsigned long long);
  80064a:	8b 45 08             	mov    0x8(%ebp),%eax
  80064d:	8b 00                	mov    (%eax),%eax
  80064f:	8d 48 08             	lea    0x8(%eax),%ecx
  800652:	8b 55 08             	mov    0x8(%ebp),%edx
  800655:	89 0a                	mov    %ecx,(%edx)
  800657:	8b 50 04             	mov    0x4(%eax),%edx
  80065a:	8b 00                	mov    (%eax),%eax
  80065c:	eb 30                	jmp    80068e <getuint+0x4d>
	else if (lflag)
  80065e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800662:	74 16                	je     80067a <getuint+0x39>
		return va_arg(*ap, unsigned long);
  800664:	8b 45 08             	mov    0x8(%ebp),%eax
  800667:	8b 00                	mov    (%eax),%eax
  800669:	8d 48 04             	lea    0x4(%eax),%ecx
  80066c:	8b 55 08             	mov    0x8(%ebp),%edx
  80066f:	89 0a                	mov    %ecx,(%edx)
  800671:	8b 00                	mov    (%eax),%eax
  800673:	ba 00 00 00 00       	mov    $0x0,%edx
  800678:	eb 14                	jmp    80068e <getuint+0x4d>
	else
		return va_arg(*ap, unsigned int);
  80067a:	8b 45 08             	mov    0x8(%ebp),%eax
  80067d:	8b 00                	mov    (%eax),%eax
  80067f:	8d 48 04             	lea    0x4(%eax),%ecx
  800682:	8b 55 08             	mov    0x8(%ebp),%edx
  800685:	89 0a                	mov    %ecx,(%edx)
  800687:	8b 00                	mov    (%eax),%eax
  800689:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80068e:	5d                   	pop    %ebp
  80068f:	c3                   	ret    

00800690 <getint>:

// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
  800690:	55                   	push   %ebp
  800691:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  800693:	83 7d 0c 01          	cmpl   $0x1,0xc(%ebp)
  800697:	7e 14                	jle    8006ad <getint+0x1d>
		return va_arg(*ap, long long);
  800699:	8b 45 08             	mov    0x8(%ebp),%eax
  80069c:	8b 00                	mov    (%eax),%eax
  80069e:	8d 48 08             	lea    0x8(%eax),%ecx
  8006a1:	8b 55 08             	mov    0x8(%ebp),%edx
  8006a4:	89 0a                	mov    %ecx,(%edx)
  8006a6:	8b 50 04             	mov    0x4(%eax),%edx
  8006a9:	8b 00                	mov    (%eax),%eax
  8006ab:	eb 28                	jmp    8006d5 <getint+0x45>
	else if (lflag)
  8006ad:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8006b1:	74 12                	je     8006c5 <getint+0x35>
		return va_arg(*ap, long);
  8006b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8006b6:	8b 00                	mov    (%eax),%eax
  8006b8:	8d 48 04             	lea    0x4(%eax),%ecx
  8006bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8006be:	89 0a                	mov    %ecx,(%edx)
  8006c0:	8b 00                	mov    (%eax),%eax
  8006c2:	99                   	cltd   
  8006c3:	eb 10                	jmp    8006d5 <getint+0x45>
	else
		return va_arg(*ap, int);
  8006c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8006c8:	8b 00                	mov    (%eax),%eax
  8006ca:	8d 48 04             	lea    0x4(%eax),%ecx
  8006cd:	8b 55 08             	mov    0x8(%ebp),%edx
  8006d0:	89 0a                	mov    %ecx,(%edx)
  8006d2:	8b 00                	mov    (%eax),%eax
  8006d4:	99                   	cltd   
}
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  8006d7:	55                   	push   %ebp
  8006d8:	89 e5                	mov    %esp,%ebp
  8006da:	56                   	push   %esi
  8006db:	53                   	push   %ebx
  8006dc:	83 ec 40             	sub    $0x40,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006df:	eb 18                	jmp    8006f9 <vprintfmt+0x22>
			if (ch == '\0')
  8006e1:	85 db                	test   %ebx,%ebx
  8006e3:	75 05                	jne    8006ea <vprintfmt+0x13>
				return;
  8006e5:	e9 05 04 00 00       	jmp    800aef <vprintfmt+0x418>
			putch(ch, putdat);
  8006ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8006ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8006f1:	89 1c 24             	mov    %ebx,(%esp)
  8006f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8006f7:	ff d0                	call   *%eax
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006f9:	8b 45 10             	mov    0x10(%ebp),%eax
  8006fc:	8d 50 01             	lea    0x1(%eax),%edx
  8006ff:	89 55 10             	mov    %edx,0x10(%ebp)
  800702:	0f b6 00             	movzbl (%eax),%eax
  800705:	0f b6 d8             	movzbl %al,%ebx
  800708:	83 fb 25             	cmp    $0x25,%ebx
  80070b:	75 d4                	jne    8006e1 <vprintfmt+0xa>
				return;
			putch(ch, putdat);
		}

		// Process a %-escape sequence
		padc = ' ';
  80070d:	c6 45 db 20          	movb   $0x20,-0x25(%ebp)
		width = -1;
  800711:	c7 45 e4 ff ff ff ff 	movl   $0xffffffff,-0x1c(%ebp)
		precision = -1;
  800718:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80071f:	c7 45 e8 00 00 00 00 	movl   $0x0,-0x18(%ebp)
		altflag = 0;
  800726:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80072d:	8b 45 10             	mov    0x10(%ebp),%eax
  800730:	8d 50 01             	lea    0x1(%eax),%edx
  800733:	89 55 10             	mov    %edx,0x10(%ebp)
  800736:	0f b6 00             	movzbl (%eax),%eax
  800739:	0f b6 d8             	movzbl %al,%ebx
  80073c:	8d 43 dd             	lea    -0x23(%ebx),%eax
  80073f:	83 f8 55             	cmp    $0x55,%eax
  800742:	0f 87 76 03 00 00    	ja     800abe <vprintfmt+0x3e7>
  800748:	8b 04 85 6c 15 80 00 	mov    0x80156c(,%eax,4),%eax
  80074f:	ff e0                	jmp    *%eax

		// flag to pad on the right
		case '-':
			padc = '-';
  800751:	c6 45 db 2d          	movb   $0x2d,-0x25(%ebp)
			goto reswitch;
  800755:	eb d6                	jmp    80072d <vprintfmt+0x56>

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  800757:	c6 45 db 30          	movb   $0x30,-0x25(%ebp)
			goto reswitch;
  80075b:	eb d0                	jmp    80072d <vprintfmt+0x56>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80075d:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
				precision = precision * 10 + ch - '0';
  800764:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800767:	89 d0                	mov    %edx,%eax
  800769:	c1 e0 02             	shl    $0x2,%eax
  80076c:	01 d0                	add    %edx,%eax
  80076e:	01 c0                	add    %eax,%eax
  800770:	01 d8                	add    %ebx,%eax
  800772:	83 e8 30             	sub    $0x30,%eax
  800775:	89 45 e0             	mov    %eax,-0x20(%ebp)
				ch = *fmt;
  800778:	8b 45 10             	mov    0x10(%ebp),%eax
  80077b:	0f b6 00             	movzbl (%eax),%eax
  80077e:	0f be d8             	movsbl %al,%ebx
				if (ch < '0' || ch > '9')
  800781:	83 fb 2f             	cmp    $0x2f,%ebx
  800784:	7e 0b                	jle    800791 <vprintfmt+0xba>
  800786:	83 fb 39             	cmp    $0x39,%ebx
  800789:	7f 06                	jg     800791 <vprintfmt+0xba>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  80078b:	83 45 10 01          	addl   $0x1,0x10(%ebp)
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  80078f:	eb d3                	jmp    800764 <vprintfmt+0x8d>
			goto process_precision;
  800791:	eb 33                	jmp    8007c6 <vprintfmt+0xef>

		case '*':
			precision = va_arg(ap, int);
  800793:	8b 45 14             	mov    0x14(%ebp),%eax
  800796:	8d 50 04             	lea    0x4(%eax),%edx
  800799:	89 55 14             	mov    %edx,0x14(%ebp)
  80079c:	8b 00                	mov    (%eax),%eax
  80079e:	89 45 e0             	mov    %eax,-0x20(%ebp)
			goto process_precision;
  8007a1:	eb 23                	jmp    8007c6 <vprintfmt+0xef>

		case '.':
			if (width < 0)
  8007a3:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007a7:	79 0c                	jns    8007b5 <vprintfmt+0xde>
				width = 0;
  8007a9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
			goto reswitch;
  8007b0:	e9 78 ff ff ff       	jmp    80072d <vprintfmt+0x56>
  8007b5:	e9 73 ff ff ff       	jmp    80072d <vprintfmt+0x56>

		case '#':
			altflag = 1;
  8007ba:	c7 45 dc 01 00 00 00 	movl   $0x1,-0x24(%ebp)
			goto reswitch;
  8007c1:	e9 67 ff ff ff       	jmp    80072d <vprintfmt+0x56>

		process_precision:
			if (width < 0)
  8007c6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8007ca:	79 12                	jns    8007de <vprintfmt+0x107>
				width = precision, precision = -1;
  8007cc:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8007cf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007d2:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
			goto reswitch;
  8007d9:	e9 4f ff ff ff       	jmp    80072d <vprintfmt+0x56>
  8007de:	e9 4a ff ff ff       	jmp    80072d <vprintfmt+0x56>

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  8007e3:	83 45 e8 01          	addl   $0x1,-0x18(%ebp)
			goto reswitch;
  8007e7:	e9 41 ff ff ff       	jmp    80072d <vprintfmt+0x56>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  8007ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ef:	8d 50 04             	lea    0x4(%eax),%edx
  8007f2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007f5:	8b 00                	mov    (%eax),%eax
  8007f7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007fa:	89 54 24 04          	mov    %edx,0x4(%esp)
  8007fe:	89 04 24             	mov    %eax,(%esp)
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	ff d0                	call   *%eax
			break;
  800806:	e9 de 02 00 00       	jmp    800ae9 <vprintfmt+0x412>

		// error message
		case 'e':
			err = va_arg(ap, int);
  80080b:	8b 45 14             	mov    0x14(%ebp),%eax
  80080e:	8d 50 04             	lea    0x4(%eax),%edx
  800811:	89 55 14             	mov    %edx,0x14(%ebp)
  800814:	8b 18                	mov    (%eax),%ebx
			if (err < 0)
  800816:	85 db                	test   %ebx,%ebx
  800818:	79 02                	jns    80081c <vprintfmt+0x145>
				err = -err;
  80081a:	f7 db                	neg    %ebx
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80081c:	83 fb 09             	cmp    $0x9,%ebx
  80081f:	7f 0b                	jg     80082c <vprintfmt+0x155>
  800821:	8b 34 9d 20 15 80 00 	mov    0x801520(,%ebx,4),%esi
  800828:	85 f6                	test   %esi,%esi
  80082a:	75 23                	jne    80084f <vprintfmt+0x178>
				printfmt(putch, putdat, "error %d", err);
  80082c:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  800830:	c7 44 24 08 59 15 80 	movl   $0x801559,0x8(%esp)
  800837:	00 
  800838:	8b 45 0c             	mov    0xc(%ebp),%eax
  80083b:	89 44 24 04          	mov    %eax,0x4(%esp)
  80083f:	8b 45 08             	mov    0x8(%ebp),%eax
  800842:	89 04 24             	mov    %eax,(%esp)
  800845:	e8 ac 02 00 00       	call   800af6 <printfmt>
			else
				printfmt(putch, putdat, "%s", p);
			break;
  80084a:	e9 9a 02 00 00       	jmp    800ae9 <vprintfmt+0x412>
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
  80084f:	89 74 24 0c          	mov    %esi,0xc(%esp)
  800853:	c7 44 24 08 62 15 80 	movl   $0x801562,0x8(%esp)
  80085a:	00 
  80085b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80085e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800862:	8b 45 08             	mov    0x8(%ebp),%eax
  800865:	89 04 24             	mov    %eax,(%esp)
  800868:	e8 89 02 00 00       	call   800af6 <printfmt>
			break;
  80086d:	e9 77 02 00 00       	jmp    800ae9 <vprintfmt+0x412>

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 30                	mov    (%eax),%esi
  80087d:	85 f6                	test   %esi,%esi
  80087f:	75 05                	jne    800886 <vprintfmt+0x1af>
				p = "(null)";
  800881:	be 65 15 80 00       	mov    $0x801565,%esi
			if (width > 0 && padc != '-')
  800886:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80088a:	7e 37                	jle    8008c3 <vprintfmt+0x1ec>
  80088c:	80 7d db 2d          	cmpb   $0x2d,-0x25(%ebp)
  800890:	74 31                	je     8008c3 <vprintfmt+0x1ec>
				for (width -= strnlen(p, precision); width > 0; width--)
  800892:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800895:	89 44 24 04          	mov    %eax,0x4(%esp)
  800899:	89 34 24             	mov    %esi,(%esp)
  80089c:	e8 72 03 00 00       	call   800c13 <strnlen>
  8008a1:	29 45 e4             	sub    %eax,-0x1c(%ebp)
  8008a4:	eb 17                	jmp    8008bd <vprintfmt+0x1e6>
					putch(padc, putdat);
  8008a6:	0f be 45 db          	movsbl -0x25(%ebp),%eax
  8008aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ad:	89 54 24 04          	mov    %edx,0x4(%esp)
  8008b1:	89 04 24             	mov    %eax,(%esp)
  8008b4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008b7:	ff d0                	call   *%eax
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8008b9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008bd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8008c1:	7f e3                	jg     8008a6 <vprintfmt+0x1cf>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008c3:	eb 38                	jmp    8008fd <vprintfmt+0x226>
				if (altflag && (ch < ' ' || ch > '~'))
  8008c5:	83 7d dc 00          	cmpl   $0x0,-0x24(%ebp)
  8008c9:	74 1f                	je     8008ea <vprintfmt+0x213>
  8008cb:	83 fb 1f             	cmp    $0x1f,%ebx
  8008ce:	7e 05                	jle    8008d5 <vprintfmt+0x1fe>
  8008d0:	83 fb 7e             	cmp    $0x7e,%ebx
  8008d3:	7e 15                	jle    8008ea <vprintfmt+0x213>
					putch('?', putdat);
  8008d5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008d8:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008dc:	c7 04 24 3f 00 00 00 	movl   $0x3f,(%esp)
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	ff d0                	call   *%eax
  8008e8:	eb 0f                	jmp    8008f9 <vprintfmt+0x222>
				else
					putch(ch, putdat);
  8008ea:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008ed:	89 44 24 04          	mov    %eax,0x4(%esp)
  8008f1:	89 1c 24             	mov    %ebx,(%esp)
  8008f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f7:	ff d0                	call   *%eax
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8008f9:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  8008fd:	89 f0                	mov    %esi,%eax
  8008ff:	8d 70 01             	lea    0x1(%eax),%esi
  800902:	0f b6 00             	movzbl (%eax),%eax
  800905:	0f be d8             	movsbl %al,%ebx
  800908:	85 db                	test   %ebx,%ebx
  80090a:	74 10                	je     80091c <vprintfmt+0x245>
  80090c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800910:	78 b3                	js     8008c5 <vprintfmt+0x1ee>
  800912:	83 6d e0 01          	subl   $0x1,-0x20(%ebp)
  800916:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80091a:	79 a9                	jns    8008c5 <vprintfmt+0x1ee>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  80091c:	eb 17                	jmp    800935 <vprintfmt+0x25e>
				putch(' ', putdat);
  80091e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800921:	89 44 24 04          	mov    %eax,0x4(%esp)
  800925:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
  80092c:	8b 45 08             	mov    0x8(%ebp),%eax
  80092f:	ff d0                	call   *%eax
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800931:	83 6d e4 01          	subl   $0x1,-0x1c(%ebp)
  800935:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800939:	7f e3                	jg     80091e <vprintfmt+0x247>
				putch(' ', putdat);
			break;
  80093b:	e9 a9 01 00 00       	jmp    800ae9 <vprintfmt+0x412>

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  800940:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800943:	89 44 24 04          	mov    %eax,0x4(%esp)
  800947:	8d 45 14             	lea    0x14(%ebp),%eax
  80094a:	89 04 24             	mov    %eax,(%esp)
  80094d:	e8 3e fd ff ff       	call   800690 <getint>
  800952:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800955:	89 55 f4             	mov    %edx,-0xc(%ebp)
			if ((long long) num < 0) {
  800958:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80095b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80095e:	85 d2                	test   %edx,%edx
  800960:	79 26                	jns    800988 <vprintfmt+0x2b1>
				putch('-', putdat);
  800962:	8b 45 0c             	mov    0xc(%ebp),%eax
  800965:	89 44 24 04          	mov    %eax,0x4(%esp)
  800969:	c7 04 24 2d 00 00 00 	movl   $0x2d,(%esp)
  800970:	8b 45 08             	mov    0x8(%ebp),%eax
  800973:	ff d0                	call   *%eax
				num = -(long long) num;
  800975:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800978:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80097b:	f7 d8                	neg    %eax
  80097d:	83 d2 00             	adc    $0x0,%edx
  800980:	f7 da                	neg    %edx
  800982:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800985:	89 55 f4             	mov    %edx,-0xc(%ebp)
			}
			base = 10;
  800988:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  80098f:	e9 e1 00 00 00       	jmp    800a75 <vprintfmt+0x39e>

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800994:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800997:	89 44 24 04          	mov    %eax,0x4(%esp)
  80099b:	8d 45 14             	lea    0x14(%ebp),%eax
  80099e:	89 04 24             	mov    %eax,(%esp)
  8009a1:	e8 9b fc ff ff       	call   800641 <getuint>
  8009a6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009a9:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 10;
  8009ac:	c7 45 ec 0a 00 00 00 	movl   $0xa,-0x14(%ebp)
			goto number;
  8009b3:	e9 bd 00 00 00       	jmp    800a75 <vprintfmt+0x39e>
		case 'o':
			// Replace this with your code.
			// putch('X', putdat);
			// putch('X', putdat);
			// putch('X', putdat);
			base = 8;
  8009b8:	c7 45 ec 08 00 00 00 	movl   $0x8,-0x14(%ebp)
			num = getuint(&ap,lflag);
  8009bf:	8b 45 e8             	mov    -0x18(%ebp),%eax
  8009c2:	89 44 24 04          	mov    %eax,0x4(%esp)
  8009c6:	8d 45 14             	lea    0x14(%ebp),%eax
  8009c9:	89 04 24             	mov    %eax,(%esp)
  8009cc:	e8 70 fc ff ff       	call   800641 <getuint>
  8009d1:	89 45 f0             	mov    %eax,-0x10(%ebp)
  8009d4:	89 55 f4             	mov    %edx,-0xc(%ebp)
			// goto number;
			printnum(putch, putdat, num, base, width, padc);
  8009d7:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  8009db:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8009de:	89 54 24 18          	mov    %edx,0x18(%esp)
  8009e2:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8009e5:	89 54 24 14          	mov    %edx,0x14(%esp)
  8009e9:	89 44 24 10          	mov    %eax,0x10(%esp)
  8009ed:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8009f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8009f3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8009f7:	89 54 24 0c          	mov    %edx,0xc(%esp)
  8009fb:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009fe:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a02:	8b 45 08             	mov    0x8(%ebp),%eax
  800a05:	89 04 24             	mov    %eax,(%esp)
  800a08:	e8 56 fb ff ff       	call   800563 <printnum>
			break;
  800a0d:	e9 d7 00 00 00       	jmp    800ae9 <vprintfmt+0x412>

		// pointer
		case 'p':
			putch('0', putdat);
  800a12:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a15:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a19:	c7 04 24 30 00 00 00 	movl   $0x30,(%esp)
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	ff d0                	call   *%eax
			putch('x', putdat);
  800a25:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a28:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a2c:	c7 04 24 78 00 00 00 	movl   $0x78,(%esp)
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	ff d0                	call   *%eax
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  800a38:	8b 45 14             	mov    0x14(%ebp),%eax
  800a3b:	8d 50 04             	lea    0x4(%eax),%edx
  800a3e:	89 55 14             	mov    %edx,0x14(%ebp)
  800a41:	8b 00                	mov    (%eax),%eax

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800a43:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a46:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800a4d:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
			goto number;
  800a54:	eb 1f                	jmp    800a75 <vprintfmt+0x39e>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  800a56:	8b 45 e8             	mov    -0x18(%ebp),%eax
  800a59:	89 44 24 04          	mov    %eax,0x4(%esp)
  800a5d:	8d 45 14             	lea    0x14(%ebp),%eax
  800a60:	89 04 24             	mov    %eax,(%esp)
  800a63:	e8 d9 fb ff ff       	call   800641 <getuint>
  800a68:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800a6b:	89 55 f4             	mov    %edx,-0xc(%ebp)
			base = 16;
  800a6e:	c7 45 ec 10 00 00 00 	movl   $0x10,-0x14(%ebp)
		number:
			printnum(putch, putdat, num, base, width, padc);
  800a75:	0f be 55 db          	movsbl -0x25(%ebp),%edx
  800a79:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a7c:	89 54 24 18          	mov    %edx,0x18(%esp)
  800a80:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800a83:	89 54 24 14          	mov    %edx,0x14(%esp)
  800a87:	89 44 24 10          	mov    %eax,0x10(%esp)
  800a8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800a8e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800a91:	89 44 24 08          	mov    %eax,0x8(%esp)
  800a95:	89 54 24 0c          	mov    %edx,0xc(%esp)
  800a99:	8b 45 0c             	mov    0xc(%ebp),%eax
  800a9c:	89 44 24 04          	mov    %eax,0x4(%esp)
  800aa0:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa3:	89 04 24             	mov    %eax,(%esp)
  800aa6:	e8 b8 fa ff ff       	call   800563 <printnum>
			break;
  800aab:	eb 3c                	jmp    800ae9 <vprintfmt+0x412>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  800aad:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ab0:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ab4:	89 1c 24             	mov    %ebx,(%esp)
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	ff d0                	call   *%eax
			break;
  800abc:	eb 2b                	jmp    800ae9 <vprintfmt+0x412>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  800abe:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ac1:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ac5:	c7 04 24 25 00 00 00 	movl   $0x25,(%esp)
  800acc:	8b 45 08             	mov    0x8(%ebp),%eax
  800acf:	ff d0                	call   *%eax
			for (fmt--; fmt[-1] != '%'; fmt--)
  800ad1:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800ad5:	eb 04                	jmp    800adb <vprintfmt+0x404>
  800ad7:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800adb:	8b 45 10             	mov    0x10(%ebp),%eax
  800ade:	83 e8 01             	sub    $0x1,%eax
  800ae1:	0f b6 00             	movzbl (%eax),%eax
  800ae4:	3c 25                	cmp    $0x25,%al
  800ae6:	75 ef                	jne    800ad7 <vprintfmt+0x400>
				/* do nothing */;
			break;
  800ae8:	90                   	nop
		}
	}
  800ae9:	90                   	nop
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800aea:	e9 0a fc ff ff       	jmp    8006f9 <vprintfmt+0x22>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
  800aef:	83 c4 40             	add    $0x40,%esp
  800af2:	5b                   	pop    %ebx
  800af3:	5e                   	pop    %esi
  800af4:	5d                   	pop    %ebp
  800af5:	c3                   	ret    

00800af6 <printfmt>:

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800af6:	55                   	push   %ebp
  800af7:	89 e5                	mov    %esp,%ebp
  800af9:	83 ec 28             	sub    $0x28,%esp
	va_list ap;

	va_start(ap, fmt);
  800afc:	8d 45 14             	lea    0x14(%ebp),%eax
  800aff:	89 45 f4             	mov    %eax,-0xc(%ebp)
	vprintfmt(putch, putdat, fmt, ap);
  800b02:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b05:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b09:	8b 45 10             	mov    0x10(%ebp),%eax
  800b0c:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b10:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b13:	89 44 24 04          	mov    %eax,0x4(%esp)
  800b17:	8b 45 08             	mov    0x8(%ebp),%eax
  800b1a:	89 04 24             	mov    %eax,(%esp)
  800b1d:	e8 b5 fb ff ff       	call   8006d7 <vprintfmt>
	va_end(ap);
}
  800b22:	c9                   	leave  
  800b23:	c3                   	ret    

00800b24 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800b24:	55                   	push   %ebp
  800b25:	89 e5                	mov    %esp,%ebp
	b->cnt++;
  800b27:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b2a:	8b 40 08             	mov    0x8(%eax),%eax
  800b2d:	8d 50 01             	lea    0x1(%eax),%edx
  800b30:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b33:	89 50 08             	mov    %edx,0x8(%eax)
	if (b->buf < b->ebuf)
  800b36:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b39:	8b 10                	mov    (%eax),%edx
  800b3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b3e:	8b 40 04             	mov    0x4(%eax),%eax
  800b41:	39 c2                	cmp    %eax,%edx
  800b43:	73 12                	jae    800b57 <sprintputch+0x33>
		*b->buf++ = ch;
  800b45:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b48:	8b 00                	mov    (%eax),%eax
  800b4a:	8d 48 01             	lea    0x1(%eax),%ecx
  800b4d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b50:	89 0a                	mov    %ecx,(%edx)
  800b52:	8b 55 08             	mov    0x8(%ebp),%edx
  800b55:	88 10                	mov    %dl,(%eax)
}
  800b57:	5d                   	pop    %ebp
  800b58:	c3                   	ret    

00800b59 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 28             	sub    $0x28,%esp
	struct sprintbuf b = {buf, buf+n-1, 0};
  800b5f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b62:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800b65:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b68:	8d 50 ff             	lea    -0x1(%eax),%edx
  800b6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b6e:	01 d0                	add    %edx,%eax
  800b70:	89 45 f0             	mov    %eax,-0x10(%ebp)
  800b73:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800b7a:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
  800b7e:	74 06                	je     800b86 <vsnprintf+0x2d>
  800b80:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b84:	7f 07                	jg     800b8d <vsnprintf+0x34>
		return -E_INVAL;
  800b86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b8b:	eb 2a                	jmp    800bb7 <vsnprintf+0x5e>

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800b8d:	8b 45 14             	mov    0x14(%ebp),%eax
  800b90:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800b94:	8b 45 10             	mov    0x10(%ebp),%eax
  800b97:	89 44 24 08          	mov    %eax,0x8(%esp)
  800b9b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800b9e:	89 44 24 04          	mov    %eax,0x4(%esp)
  800ba2:	c7 04 24 24 0b 80 00 	movl   $0x800b24,(%esp)
  800ba9:	e8 29 fb ff ff       	call   8006d7 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800bae:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800bb1:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800bb4:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800bb7:	c9                   	leave  
  800bb8:	c3                   	ret    

00800bb9 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800bb9:	55                   	push   %ebp
  800bba:	89 e5                	mov    %esp,%ebp
  800bbc:	83 ec 28             	sub    $0x28,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800bbf:	8d 45 14             	lea    0x14(%ebp),%eax
  800bc2:	89 45 f0             	mov    %eax,-0x10(%ebp)
	rc = vsnprintf(buf, n, fmt, ap);
  800bc5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800bc8:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800bcc:	8b 45 10             	mov    0x10(%ebp),%eax
  800bcf:	89 44 24 08          	mov    %eax,0x8(%esp)
  800bd3:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bd6:	89 44 24 04          	mov    %eax,0x4(%esp)
  800bda:	8b 45 08             	mov    0x8(%ebp),%eax
  800bdd:	89 04 24             	mov    %eax,(%esp)
  800be0:	e8 74 ff ff ff       	call   800b59 <vsnprintf>
  800be5:	89 45 f4             	mov    %eax,-0xc(%ebp)
	va_end(ap);

	return rc;
  800be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
  800beb:	c9                   	leave  
  800bec:	c3                   	ret    

00800bed <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800bed:	55                   	push   %ebp
  800bee:	89 e5                	mov    %esp,%ebp
  800bf0:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; *s != '\0'; s++)
  800bf3:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800bfa:	eb 08                	jmp    800c04 <strlen+0x17>
		n++;
  800bfc:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800c00:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c04:	8b 45 08             	mov    0x8(%ebp),%eax
  800c07:	0f b6 00             	movzbl (%eax),%eax
  800c0a:	84 c0                	test   %al,%al
  800c0c:	75 ee                	jne    800bfc <strlen+0xf>
		n++;
	return n;
  800c0e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c11:	c9                   	leave  
  800c12:	c3                   	ret    

00800c13 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800c13:	55                   	push   %ebp
  800c14:	89 e5                	mov    %esp,%ebp
  800c16:	83 ec 10             	sub    $0x10,%esp
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c19:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800c20:	eb 0c                	jmp    800c2e <strnlen+0x1b>
		n++;
  800c22:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800c26:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800c2a:	83 6d 0c 01          	subl   $0x1,0xc(%ebp)
  800c2e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c32:	74 0a                	je     800c3e <strnlen+0x2b>
  800c34:	8b 45 08             	mov    0x8(%ebp),%eax
  800c37:	0f b6 00             	movzbl (%eax),%eax
  800c3a:	84 c0                	test   %al,%al
  800c3c:	75 e4                	jne    800c22 <strnlen+0xf>
		n++;
	return n;
  800c3e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c41:	c9                   	leave  
  800c42:	c3                   	ret    

00800c43 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 10             	sub    $0x10,%esp
	char *ret;

	ret = dst;
  800c49:	8b 45 08             	mov    0x8(%ebp),%eax
  800c4c:	89 45 fc             	mov    %eax,-0x4(%ebp)
	while ((*dst++ = *src++) != '\0')
  800c4f:	90                   	nop
  800c50:	8b 45 08             	mov    0x8(%ebp),%eax
  800c53:	8d 50 01             	lea    0x1(%eax),%edx
  800c56:	89 55 08             	mov    %edx,0x8(%ebp)
  800c59:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c5c:	8d 4a 01             	lea    0x1(%edx),%ecx
  800c5f:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800c62:	0f b6 12             	movzbl (%edx),%edx
  800c65:	88 10                	mov    %dl,(%eax)
  800c67:	0f b6 00             	movzbl (%eax),%eax
  800c6a:	84 c0                	test   %al,%al
  800c6c:	75 e2                	jne    800c50 <strcpy+0xd>
		/* do nothing */;
	return ret;
  800c6e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  800c71:	c9                   	leave  
  800c72:	c3                   	ret    

00800c73 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800c73:	55                   	push   %ebp
  800c74:	89 e5                	mov    %esp,%ebp
  800c76:	83 ec 18             	sub    $0x18,%esp
	int len = strlen(dst);
  800c79:	8b 45 08             	mov    0x8(%ebp),%eax
  800c7c:	89 04 24             	mov    %eax,(%esp)
  800c7f:	e8 69 ff ff ff       	call   800bed <strlen>
  800c84:	89 45 fc             	mov    %eax,-0x4(%ebp)
	strcpy(dst + len, src);
  800c87:	8b 55 fc             	mov    -0x4(%ebp),%edx
  800c8a:	8b 45 08             	mov    0x8(%ebp),%eax
  800c8d:	01 c2                	add    %eax,%edx
  800c8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c92:	89 44 24 04          	mov    %eax,0x4(%esp)
  800c96:	89 14 24             	mov    %edx,(%esp)
  800c99:	e8 a5 ff ff ff       	call   800c43 <strcpy>
	return dst;
  800c9e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800ca1:	c9                   	leave  
  800ca2:	c3                   	ret    

00800ca3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800ca3:	55                   	push   %ebp
  800ca4:	89 e5                	mov    %esp,%ebp
  800ca6:	83 ec 10             	sub    $0x10,%esp
	size_t i;
	char *ret;

	ret = dst;
  800ca9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cac:	89 45 f8             	mov    %eax,-0x8(%ebp)
	for (i = 0; i < size; i++) {
  800caf:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  800cb6:	eb 23                	jmp    800cdb <strncpy+0x38>
		*dst++ = *src;
  800cb8:	8b 45 08             	mov    0x8(%ebp),%eax
  800cbb:	8d 50 01             	lea    0x1(%eax),%edx
  800cbe:	89 55 08             	mov    %edx,0x8(%ebp)
  800cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc4:	0f b6 12             	movzbl (%edx),%edx
  800cc7:	88 10                	mov    %dl,(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
  800cc9:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ccc:	0f b6 00             	movzbl (%eax),%eax
  800ccf:	84 c0                	test   %al,%al
  800cd1:	74 04                	je     800cd7 <strncpy+0x34>
			src++;
  800cd3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800cd7:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800cdb:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800cde:	3b 45 10             	cmp    0x10(%ebp),%eax
  800ce1:	72 d5                	jb     800cb8 <strncpy+0x15>
		*dst++ = *src;
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
  800ce3:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  800ce6:	c9                   	leave  
  800ce7:	c3                   	ret    

00800ce8 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800ce8:	55                   	push   %ebp
  800ce9:	89 e5                	mov    %esp,%ebp
  800ceb:	83 ec 10             	sub    $0x10,%esp
	char *dst_in;

	dst_in = dst;
  800cee:	8b 45 08             	mov    0x8(%ebp),%eax
  800cf1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	if (size > 0) {
  800cf4:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800cf8:	74 33                	je     800d2d <strlcpy+0x45>
		while (--size > 0 && *src != '\0')
  800cfa:	eb 17                	jmp    800d13 <strlcpy+0x2b>
			*dst++ = *src++;
  800cfc:	8b 45 08             	mov    0x8(%ebp),%eax
  800cff:	8d 50 01             	lea    0x1(%eax),%edx
  800d02:	89 55 08             	mov    %edx,0x8(%ebp)
  800d05:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d08:	8d 4a 01             	lea    0x1(%edx),%ecx
  800d0b:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  800d0e:	0f b6 12             	movzbl (%edx),%edx
  800d11:	88 10                	mov    %dl,(%eax)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800d13:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d17:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d1b:	74 0a                	je     800d27 <strlcpy+0x3f>
  800d1d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d20:	0f b6 00             	movzbl (%eax),%eax
  800d23:	84 c0                	test   %al,%al
  800d25:	75 d5                	jne    800cfc <strlcpy+0x14>
			*dst++ = *src++;
		*dst = '\0';
  800d27:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800d2d:	8b 55 08             	mov    0x8(%ebp),%edx
  800d30:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800d33:	29 c2                	sub    %eax,%edx
  800d35:	89 d0                	mov    %edx,%eax
}
  800d37:	c9                   	leave  
  800d38:	c3                   	ret    

00800d39 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800d39:	55                   	push   %ebp
  800d3a:	89 e5                	mov    %esp,%ebp
	while (*p && *p == *q)
  800d3c:	eb 08                	jmp    800d46 <strcmp+0xd>
		p++, q++;
  800d3e:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d42:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800d46:	8b 45 08             	mov    0x8(%ebp),%eax
  800d49:	0f b6 00             	movzbl (%eax),%eax
  800d4c:	84 c0                	test   %al,%al
  800d4e:	74 10                	je     800d60 <strcmp+0x27>
  800d50:	8b 45 08             	mov    0x8(%ebp),%eax
  800d53:	0f b6 10             	movzbl (%eax),%edx
  800d56:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d59:	0f b6 00             	movzbl (%eax),%eax
  800d5c:	38 c2                	cmp    %al,%dl
  800d5e:	74 de                	je     800d3e <strcmp+0x5>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800d60:	8b 45 08             	mov    0x8(%ebp),%eax
  800d63:	0f b6 00             	movzbl (%eax),%eax
  800d66:	0f b6 d0             	movzbl %al,%edx
  800d69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d6c:	0f b6 00             	movzbl (%eax),%eax
  800d6f:	0f b6 c0             	movzbl %al,%eax
  800d72:	29 c2                	sub    %eax,%edx
  800d74:	89 d0                	mov    %edx,%eax
}
  800d76:	5d                   	pop    %ebp
  800d77:	c3                   	ret    

00800d78 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800d78:	55                   	push   %ebp
  800d79:	89 e5                	mov    %esp,%ebp
	while (n > 0 && *p && *p == *q)
  800d7b:	eb 0c                	jmp    800d89 <strncmp+0x11>
		n--, p++, q++;
  800d7d:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
  800d81:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800d85:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800d89:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800d8d:	74 1a                	je     800da9 <strncmp+0x31>
  800d8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800d92:	0f b6 00             	movzbl (%eax),%eax
  800d95:	84 c0                	test   %al,%al
  800d97:	74 10                	je     800da9 <strncmp+0x31>
  800d99:	8b 45 08             	mov    0x8(%ebp),%eax
  800d9c:	0f b6 10             	movzbl (%eax),%edx
  800d9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800da2:	0f b6 00             	movzbl (%eax),%eax
  800da5:	38 c2                	cmp    %al,%dl
  800da7:	74 d4                	je     800d7d <strncmp+0x5>
		n--, p++, q++;
	if (n == 0)
  800da9:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800dad:	75 07                	jne    800db6 <strncmp+0x3e>
		return 0;
  800daf:	b8 00 00 00 00       	mov    $0x0,%eax
  800db4:	eb 16                	jmp    800dcc <strncmp+0x54>
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800db6:	8b 45 08             	mov    0x8(%ebp),%eax
  800db9:	0f b6 00             	movzbl (%eax),%eax
  800dbc:	0f b6 d0             	movzbl %al,%edx
  800dbf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dc2:	0f b6 00             	movzbl (%eax),%eax
  800dc5:	0f b6 c0             	movzbl %al,%eax
  800dc8:	29 c2                	sub    %eax,%edx
  800dca:	89 d0                	mov    %edx,%eax
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800dce:	55                   	push   %ebp
  800dcf:	89 e5                	mov    %esp,%ebp
  800dd1:	83 ec 04             	sub    $0x4,%esp
  800dd4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd7:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800dda:	eb 14                	jmp    800df0 <strchr+0x22>
		if (*s == c)
  800ddc:	8b 45 08             	mov    0x8(%ebp),%eax
  800ddf:	0f b6 00             	movzbl (%eax),%eax
  800de2:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800de5:	75 05                	jne    800dec <strchr+0x1e>
			return (char *) s;
  800de7:	8b 45 08             	mov    0x8(%ebp),%eax
  800dea:	eb 13                	jmp    800dff <strchr+0x31>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800dec:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800df0:	8b 45 08             	mov    0x8(%ebp),%eax
  800df3:	0f b6 00             	movzbl (%eax),%eax
  800df6:	84 c0                	test   %al,%al
  800df8:	75 e2                	jne    800ddc <strchr+0xe>
		if (*s == c)
			return (char *) s;
	return 0;
  800dfa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800dff:	c9                   	leave  
  800e00:	c3                   	ret    

00800e01 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e01:	55                   	push   %ebp
  800e02:	89 e5                	mov    %esp,%ebp
  800e04:	83 ec 04             	sub    $0x4,%esp
  800e07:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e0a:	88 45 fc             	mov    %al,-0x4(%ebp)
	for (; *s; s++)
  800e0d:	eb 11                	jmp    800e20 <strfind+0x1f>
		if (*s == c)
  800e0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e12:	0f b6 00             	movzbl (%eax),%eax
  800e15:	3a 45 fc             	cmp    -0x4(%ebp),%al
  800e18:	75 02                	jne    800e1c <strfind+0x1b>
			break;
  800e1a:	eb 0e                	jmp    800e2a <strfind+0x29>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
  800e1c:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  800e20:	8b 45 08             	mov    0x8(%ebp),%eax
  800e23:	0f b6 00             	movzbl (%eax),%eax
  800e26:	84 c0                	test   %al,%al
  800e28:	75 e5                	jne    800e0f <strfind+0xe>
		if (*s == c)
			break;
	return (char *) s;
  800e2a:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e2d:	c9                   	leave  
  800e2e:	c3                   	ret    

00800e2f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800e2f:	55                   	push   %ebp
  800e30:	89 e5                	mov    %esp,%ebp
  800e32:	57                   	push   %edi
	char *p;

	if (n == 0)
  800e33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800e37:	75 05                	jne    800e3e <memset+0xf>
		return v;
  800e39:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3c:	eb 5c                	jmp    800e9a <memset+0x6b>
	if ((int)v%4 == 0 && n%4 == 0) {
  800e3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800e41:	83 e0 03             	and    $0x3,%eax
  800e44:	85 c0                	test   %eax,%eax
  800e46:	75 41                	jne    800e89 <memset+0x5a>
  800e48:	8b 45 10             	mov    0x10(%ebp),%eax
  800e4b:	83 e0 03             	and    $0x3,%eax
  800e4e:	85 c0                	test   %eax,%eax
  800e50:	75 37                	jne    800e89 <memset+0x5a>
		c &= 0xFF;
  800e52:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800e59:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e5c:	c1 e0 18             	shl    $0x18,%eax
  800e5f:	89 c2                	mov    %eax,%edx
  800e61:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e64:	c1 e0 10             	shl    $0x10,%eax
  800e67:	09 c2                	or     %eax,%edx
  800e69:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e6c:	c1 e0 08             	shl    $0x8,%eax
  800e6f:	09 d0                	or     %edx,%eax
  800e71:	09 45 0c             	or     %eax,0xc(%ebp)
		asm volatile("cld; rep stosl\n"
			:: "D" (v), "a" (c), "c" (n/4)
  800e74:	8b 45 10             	mov    0x10(%ebp),%eax
  800e77:	c1 e8 02             	shr    $0x2,%eax
  800e7a:	89 c1                	mov    %eax,%ecx
	if (n == 0)
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
		c &= 0xFF;
		c = (c<<24)|(c<<16)|(c<<8)|c;
		asm volatile("cld; rep stosl\n"
  800e7c:	8b 55 08             	mov    0x8(%ebp),%edx
  800e7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e82:	89 d7                	mov    %edx,%edi
  800e84:	fc                   	cld    
  800e85:	f3 ab                	rep stos %eax,%es:(%edi)
  800e87:	eb 0e                	jmp    800e97 <memset+0x68>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800e89:	8b 55 08             	mov    0x8(%ebp),%edx
  800e8c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800e8f:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800e92:	89 d7                	mov    %edx,%edi
  800e94:	fc                   	cld    
  800e95:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800e9a:	5f                   	pop    %edi
  800e9b:	5d                   	pop    %ebp
  800e9c:	c3                   	ret    

00800e9d <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800e9d:	55                   	push   %ebp
  800e9e:	89 e5                	mov    %esp,%ebp
  800ea0:	57                   	push   %edi
  800ea1:	56                   	push   %esi
  800ea2:	53                   	push   %ebx
  800ea3:	83 ec 10             	sub    $0x10,%esp
	const char *s;
	char *d;

	s = src;
  800ea6:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ea9:	89 45 f0             	mov    %eax,-0x10(%ebp)
	d = dst;
  800eac:	8b 45 08             	mov    0x8(%ebp),%eax
  800eaf:	89 45 ec             	mov    %eax,-0x14(%ebp)
	if (s < d && s + n > d) {
  800eb2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800eb5:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800eb8:	73 6d                	jae    800f27 <memmove+0x8a>
  800eba:	8b 45 10             	mov    0x10(%ebp),%eax
  800ebd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800ec0:	01 d0                	add    %edx,%eax
  800ec2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
  800ec5:	76 60                	jbe    800f27 <memmove+0x8a>
		s += n;
  800ec7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eca:	01 45 f0             	add    %eax,-0x10(%ebp)
		d += n;
  800ecd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ed0:	01 45 ec             	add    %eax,-0x14(%ebp)
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ed6:	83 e0 03             	and    $0x3,%eax
  800ed9:	85 c0                	test   %eax,%eax
  800edb:	75 2f                	jne    800f0c <memmove+0x6f>
  800edd:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ee0:	83 e0 03             	and    $0x3,%eax
  800ee3:	85 c0                	test   %eax,%eax
  800ee5:	75 25                	jne    800f0c <memmove+0x6f>
  800ee7:	8b 45 10             	mov    0x10(%ebp),%eax
  800eea:	83 e0 03             	and    $0x3,%eax
  800eed:	85 c0                	test   %eax,%eax
  800eef:	75 1b                	jne    800f0c <memmove+0x6f>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800ef1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800ef4:	83 e8 04             	sub    $0x4,%eax
  800ef7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800efa:	83 ea 04             	sub    $0x4,%edx
  800efd:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f00:	c1 e9 02             	shr    $0x2,%ecx
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
  800f03:	89 c7                	mov    %eax,%edi
  800f05:	89 d6                	mov    %edx,%esi
  800f07:	fd                   	std    
  800f08:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f0a:	eb 18                	jmp    800f24 <memmove+0x87>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f0c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f0f:	8d 50 ff             	lea    -0x1(%eax),%edx
  800f12:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f15:	8d 58 ff             	lea    -0x1(%eax),%ebx
		d += n;
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800f18:	8b 45 10             	mov    0x10(%ebp),%eax
  800f1b:	89 d7                	mov    %edx,%edi
  800f1d:	89 de                	mov    %ebx,%esi
  800f1f:	89 c1                	mov    %eax,%ecx
  800f21:	fd                   	std    
  800f22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f24:	fc                   	cld    
  800f25:	eb 45                	jmp    800f6c <memmove+0xcf>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f27:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800f2a:	83 e0 03             	and    $0x3,%eax
  800f2d:	85 c0                	test   %eax,%eax
  800f2f:	75 2b                	jne    800f5c <memmove+0xbf>
  800f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f34:	83 e0 03             	and    $0x3,%eax
  800f37:	85 c0                	test   %eax,%eax
  800f39:	75 21                	jne    800f5c <memmove+0xbf>
  800f3b:	8b 45 10             	mov    0x10(%ebp),%eax
  800f3e:	83 e0 03             	and    $0x3,%eax
  800f41:	85 c0                	test   %eax,%eax
  800f43:	75 17                	jne    800f5c <memmove+0xbf>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f45:	8b 45 10             	mov    0x10(%ebp),%eax
  800f48:	c1 e8 02             	shr    $0x2,%eax
  800f4b:	89 c1                	mov    %eax,%ecx
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
			asm volatile("cld; rep movsl\n"
  800f4d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f50:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f53:	89 c7                	mov    %eax,%edi
  800f55:	89 d6                	mov    %edx,%esi
  800f57:	fc                   	cld    
  800f58:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f5a:	eb 10                	jmp    800f6c <memmove+0xcf>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800f5c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800f5f:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800f62:	8b 4d 10             	mov    0x10(%ebp),%ecx
  800f65:	89 c7                	mov    %eax,%edi
  800f67:	89 d6                	mov    %edx,%esi
  800f69:	fc                   	cld    
  800f6a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
  800f6c:	8b 45 08             	mov    0x8(%ebp),%eax
}
  800f6f:	83 c4 10             	add    $0x10,%esp
  800f72:	5b                   	pop    %ebx
  800f73:	5e                   	pop    %esi
  800f74:	5f                   	pop    %edi
  800f75:	5d                   	pop    %ebp
  800f76:	c3                   	ret    

00800f77 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f77:	55                   	push   %ebp
  800f78:	89 e5                	mov    %esp,%ebp
  800f7a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f7d:	8b 45 10             	mov    0x10(%ebp),%eax
  800f80:	89 44 24 08          	mov    %eax,0x8(%esp)
  800f84:	8b 45 0c             	mov    0xc(%ebp),%eax
  800f87:	89 44 24 04          	mov    %eax,0x4(%esp)
  800f8b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8e:	89 04 24             	mov    %eax,(%esp)
  800f91:	e8 07 ff ff ff       	call   800e9d <memmove>
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    

00800f98 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f98:	55                   	push   %ebp
  800f99:	89 e5                	mov    %esp,%ebp
  800f9b:	83 ec 10             	sub    $0x10,%esp
	const uint8_t *s1 = (const uint8_t *) v1;
  800f9e:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa1:	89 45 fc             	mov    %eax,-0x4(%ebp)
	const uint8_t *s2 = (const uint8_t *) v2;
  800fa4:	8b 45 0c             	mov    0xc(%ebp),%eax
  800fa7:	89 45 f8             	mov    %eax,-0x8(%ebp)

	while (n-- > 0) {
  800faa:	eb 30                	jmp    800fdc <memcmp+0x44>
		if (*s1 != *s2)
  800fac:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800faf:	0f b6 10             	movzbl (%eax),%edx
  800fb2:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fb5:	0f b6 00             	movzbl (%eax),%eax
  800fb8:	38 c2                	cmp    %al,%dl
  800fba:	74 18                	je     800fd4 <memcmp+0x3c>
			return (int) *s1 - (int) *s2;
  800fbc:	8b 45 fc             	mov    -0x4(%ebp),%eax
  800fbf:	0f b6 00             	movzbl (%eax),%eax
  800fc2:	0f b6 d0             	movzbl %al,%edx
  800fc5:	8b 45 f8             	mov    -0x8(%ebp),%eax
  800fc8:	0f b6 00             	movzbl (%eax),%eax
  800fcb:	0f b6 c0             	movzbl %al,%eax
  800fce:	29 c2                	sub    %eax,%edx
  800fd0:	89 d0                	mov    %edx,%eax
  800fd2:	eb 1a                	jmp    800fee <memcmp+0x56>
		s1++, s2++;
  800fd4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  800fd8:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800fdc:	8b 45 10             	mov    0x10(%ebp),%eax
  800fdf:	8d 50 ff             	lea    -0x1(%eax),%edx
  800fe2:	89 55 10             	mov    %edx,0x10(%ebp)
  800fe5:	85 c0                	test   %eax,%eax
  800fe7:	75 c3                	jne    800fac <memcmp+0x14>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800fe9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fee:	c9                   	leave  
  800fef:	c3                   	ret    

00800ff0 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ff0:	55                   	push   %ebp
  800ff1:	89 e5                	mov    %esp,%ebp
  800ff3:	83 ec 10             	sub    $0x10,%esp
	const void *ends = (const char *) s + n;
  800ff6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ff9:	8b 55 08             	mov    0x8(%ebp),%edx
  800ffc:	01 d0                	add    %edx,%eax
  800ffe:	89 45 fc             	mov    %eax,-0x4(%ebp)
	for (; s < ends; s++)
  801001:	eb 13                	jmp    801016 <memfind+0x26>
		if (*(const unsigned char *) s == (unsigned char) c)
  801003:	8b 45 08             	mov    0x8(%ebp),%eax
  801006:	0f b6 10             	movzbl (%eax),%edx
  801009:	8b 45 0c             	mov    0xc(%ebp),%eax
  80100c:	38 c2                	cmp    %al,%dl
  80100e:	75 02                	jne    801012 <memfind+0x22>
			break;
  801010:	eb 0c                	jmp    80101e <memfind+0x2e>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801012:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  801016:	8b 45 08             	mov    0x8(%ebp),%eax
  801019:	3b 45 fc             	cmp    -0x4(%ebp),%eax
  80101c:	72 e5                	jb     801003 <memfind+0x13>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
  80101e:	8b 45 08             	mov    0x8(%ebp),%eax
}
  801021:	c9                   	leave  
  801022:	c3                   	ret    

00801023 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801023:	55                   	push   %ebp
  801024:	89 e5                	mov    %esp,%ebp
  801026:	83 ec 10             	sub    $0x10,%esp
	int neg = 0;
  801029:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
	long val = 0;
  801030:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801037:	eb 04                	jmp    80103d <strtol+0x1a>
		s++;
  801039:	83 45 08 01          	addl   $0x1,0x8(%ebp)
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80103d:	8b 45 08             	mov    0x8(%ebp),%eax
  801040:	0f b6 00             	movzbl (%eax),%eax
  801043:	3c 20                	cmp    $0x20,%al
  801045:	74 f2                	je     801039 <strtol+0x16>
  801047:	8b 45 08             	mov    0x8(%ebp),%eax
  80104a:	0f b6 00             	movzbl (%eax),%eax
  80104d:	3c 09                	cmp    $0x9,%al
  80104f:	74 e8                	je     801039 <strtol+0x16>
		s++;

	// plus/minus sign
	if (*s == '+')
  801051:	8b 45 08             	mov    0x8(%ebp),%eax
  801054:	0f b6 00             	movzbl (%eax),%eax
  801057:	3c 2b                	cmp    $0x2b,%al
  801059:	75 06                	jne    801061 <strtol+0x3e>
		s++;
  80105b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80105f:	eb 15                	jmp    801076 <strtol+0x53>
	else if (*s == '-')
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	0f b6 00             	movzbl (%eax),%eax
  801067:	3c 2d                	cmp    $0x2d,%al
  801069:	75 0b                	jne    801076 <strtol+0x53>
		s++, neg = 1;
  80106b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80106f:	c7 45 fc 01 00 00 00 	movl   $0x1,-0x4(%ebp)

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801076:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80107a:	74 06                	je     801082 <strtol+0x5f>
  80107c:	83 7d 10 10          	cmpl   $0x10,0x10(%ebp)
  801080:	75 24                	jne    8010a6 <strtol+0x83>
  801082:	8b 45 08             	mov    0x8(%ebp),%eax
  801085:	0f b6 00             	movzbl (%eax),%eax
  801088:	3c 30                	cmp    $0x30,%al
  80108a:	75 1a                	jne    8010a6 <strtol+0x83>
  80108c:	8b 45 08             	mov    0x8(%ebp),%eax
  80108f:	83 c0 01             	add    $0x1,%eax
  801092:	0f b6 00             	movzbl (%eax),%eax
  801095:	3c 78                	cmp    $0x78,%al
  801097:	75 0d                	jne    8010a6 <strtol+0x83>
		s += 2, base = 16;
  801099:	83 45 08 02          	addl   $0x2,0x8(%ebp)
  80109d:	c7 45 10 10 00 00 00 	movl   $0x10,0x10(%ebp)
  8010a4:	eb 2a                	jmp    8010d0 <strtol+0xad>
	else if (base == 0 && s[0] == '0')
  8010a6:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010aa:	75 17                	jne    8010c3 <strtol+0xa0>
  8010ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8010af:	0f b6 00             	movzbl (%eax),%eax
  8010b2:	3c 30                	cmp    $0x30,%al
  8010b4:	75 0d                	jne    8010c3 <strtol+0xa0>
		s++, base = 8;
  8010b6:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8010ba:	c7 45 10 08 00 00 00 	movl   $0x8,0x10(%ebp)
  8010c1:	eb 0d                	jmp    8010d0 <strtol+0xad>
	else if (base == 0)
  8010c3:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8010c7:	75 07                	jne    8010d0 <strtol+0xad>
		base = 10;
  8010c9:	c7 45 10 0a 00 00 00 	movl   $0xa,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8010d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8010d3:	0f b6 00             	movzbl (%eax),%eax
  8010d6:	3c 2f                	cmp    $0x2f,%al
  8010d8:	7e 1b                	jle    8010f5 <strtol+0xd2>
  8010da:	8b 45 08             	mov    0x8(%ebp),%eax
  8010dd:	0f b6 00             	movzbl (%eax),%eax
  8010e0:	3c 39                	cmp    $0x39,%al
  8010e2:	7f 11                	jg     8010f5 <strtol+0xd2>
			dig = *s - '0';
  8010e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8010e7:	0f b6 00             	movzbl (%eax),%eax
  8010ea:	0f be c0             	movsbl %al,%eax
  8010ed:	83 e8 30             	sub    $0x30,%eax
  8010f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  8010f3:	eb 48                	jmp    80113d <strtol+0x11a>
		else if (*s >= 'a' && *s <= 'z')
  8010f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8010f8:	0f b6 00             	movzbl (%eax),%eax
  8010fb:	3c 60                	cmp    $0x60,%al
  8010fd:	7e 1b                	jle    80111a <strtol+0xf7>
  8010ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801102:	0f b6 00             	movzbl (%eax),%eax
  801105:	3c 7a                	cmp    $0x7a,%al
  801107:	7f 11                	jg     80111a <strtol+0xf7>
			dig = *s - 'a' + 10;
  801109:	8b 45 08             	mov    0x8(%ebp),%eax
  80110c:	0f b6 00             	movzbl (%eax),%eax
  80110f:	0f be c0             	movsbl %al,%eax
  801112:	83 e8 57             	sub    $0x57,%eax
  801115:	89 45 f4             	mov    %eax,-0xc(%ebp)
  801118:	eb 23                	jmp    80113d <strtol+0x11a>
		else if (*s >= 'A' && *s <= 'Z')
  80111a:	8b 45 08             	mov    0x8(%ebp),%eax
  80111d:	0f b6 00             	movzbl (%eax),%eax
  801120:	3c 40                	cmp    $0x40,%al
  801122:	7e 3d                	jle    801161 <strtol+0x13e>
  801124:	8b 45 08             	mov    0x8(%ebp),%eax
  801127:	0f b6 00             	movzbl (%eax),%eax
  80112a:	3c 5a                	cmp    $0x5a,%al
  80112c:	7f 33                	jg     801161 <strtol+0x13e>
			dig = *s - 'A' + 10;
  80112e:	8b 45 08             	mov    0x8(%ebp),%eax
  801131:	0f b6 00             	movzbl (%eax),%eax
  801134:	0f be c0             	movsbl %al,%eax
  801137:	83 e8 37             	sub    $0x37,%eax
  80113a:	89 45 f4             	mov    %eax,-0xc(%ebp)
		else
			break;
		if (dig >= base)
  80113d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801140:	3b 45 10             	cmp    0x10(%ebp),%eax
  801143:	7c 02                	jl     801147 <strtol+0x124>
			break;
  801145:	eb 1a                	jmp    801161 <strtol+0x13e>
		s++, val = (val * base) + dig;
  801147:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  80114b:	8b 45 f8             	mov    -0x8(%ebp),%eax
  80114e:	0f af 45 10          	imul   0x10(%ebp),%eax
  801152:	89 c2                	mov    %eax,%edx
  801154:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801157:	01 d0                	add    %edx,%eax
  801159:	89 45 f8             	mov    %eax,-0x8(%ebp)
		// we don't properly detect overflow!
	}
  80115c:	e9 6f ff ff ff       	jmp    8010d0 <strtol+0xad>

	if (endptr)
  801161:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801165:	74 08                	je     80116f <strtol+0x14c>
		*endptr = (char *) s;
  801167:	8b 45 0c             	mov    0xc(%ebp),%eax
  80116a:	8b 55 08             	mov    0x8(%ebp),%edx
  80116d:	89 10                	mov    %edx,(%eax)
	return (neg ? -val : val);
  80116f:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
  801173:	74 07                	je     80117c <strtol+0x159>
  801175:	8b 45 f8             	mov    -0x8(%ebp),%eax
  801178:	f7 d8                	neg    %eax
  80117a:	eb 03                	jmp    80117f <strtol+0x15c>
  80117c:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
  80117f:	c9                   	leave  
  801180:	c3                   	ret    
  801181:	66 90                	xchg   %ax,%ax
  801183:	66 90                	xchg   %ax,%ax
  801185:	66 90                	xchg   %ax,%ax
  801187:	66 90                	xchg   %ax,%ax
  801189:	66 90                	xchg   %ax,%ax
  80118b:	66 90                	xchg   %ax,%ax
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
