/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>

#include <kern/picirq.h>


###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num)						\
	.globl name;		/* define global symbol for 'name' */	\
	.type name, @function;	/* symbol type is function */		\
	.align 2;		/* align function definition */		\
	name:			/* function starts here */		\
	pushl $(num);							\
	jmp _alltraps

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num)					\
	.globl name;							\
	.type name, @function;						\
	.align 2;							\
	name:								\
	pushl $0;							\
	pushl $(num);							\
	jmp _alltraps

.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */

TRAPHANDLER_NOEC(traphandler0,0);
TRAPHANDLER_NOEC(traphandler1,1);
TRAPHANDLER_NOEC(traphandler2,2);
TRAPHANDLER_NOEC(traphandler3,3);
TRAPHANDLER_NOEC(traphandler4,4);
TRAPHANDLER_NOEC(traphandler5,5);
TRAPHANDLER_NOEC(traphandler6,6);
TRAPHANDLER_NOEC(traphandler7,7);
TRAPHANDLER(traphandler8,8);
# TRAPHANDLER_NOEC(traphandler9,9);
TRAPHANDLER(traphandler10,10);
TRAPHANDLER(traphandler11,11);
TRAPHANDLER(traphandler12,12);
TRAPHANDLER(traphandler13,13);
TRAPHANDLER(traphandler14,14);
# TRAPHANDLER_NOEC(traphandler15,15);
TRAPHANDLER_NOEC(traphandler16,16);
TRAPHANDLER(traphandler17,17);
TRAPHANDLER_NOEC(traphandler18,18);
TRAPHANDLER_NOEC(traphandler19,19);
# TRAPHANDLER_NOEC(traphandler33,33);

TRAPHANDLER_NOEC(traphandler48,48);

TRAPHANDLER_NOEC(traphandler32, 32);
TRAPHANDLER_NOEC(traphandler33, 33);
TRAPHANDLER_NOEC(traphandler36, 36);
TRAPHANDLER_NOEC(traphandler39, 39);
TRAPHANDLER_NOEC(traphandler46, 46);
TRAPHANDLER_NOEC(traphandler51, 51);

/*
 * Lab 3: Your code here for _alltraps
 */

_alltraps:
	pushl %ds
	pushl %es
	pushal 

	movl $(GD_KD) , %eax
	movl %eax , %ds 
	movl %eax , %es

	pushl %esp
	call trap 

.data
.globl traphandlerArr
traphandlerArr:
	.long traphandler0
	.long traphandler1
	.long traphandler2
	.long traphandler3
	.long traphandler4
	.long traphandler5
	.long traphandler6
	.long traphandler7
	.long traphandler8
	.zero 4
	.long traphandler10
	.long traphandler11
	.long traphandler12
	.long traphandler13
	.long traphandler14
	.zero 4
	.long traphandler16
	.long traphandler17
	.long traphandler18
	.long traphandler19
	.zero 48
	.long traphandler32
	.long traphandler33
	.zero 8
	.long traphandler36
	.zero 8
	.long traphandler39
	.zero 24
	.long traphandler46
	.zero 4
	.long traphandler48
	.zero 8
	.long traphandler51





