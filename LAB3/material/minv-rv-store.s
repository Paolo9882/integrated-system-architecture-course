#################
# Basic VERSION	
# This program takes an array v and computes
# min{|v[i]|}, the minimum of the absolute value,
# where v[i] is the i-th element in the array
	.data
	.align	2
v:
	.word	10
	.word	-47
	.word	22
	.word	-3
	.word	15
	.word	27
	.word	-4
m:
	.word	0

	.text
	.align	2
	.globl	__start
__start:
	li x16,7          # put 7 in x16 
	la x4,v           # put in x4 the address of v
	la x5,m           # put in x5 the address of m
	li x13,0x3fffffff # init x13 with max pos
loop:	
	beq x16,x0,done   # check all elements have been tested
	lw x8,0(x4)       # load new element in x8
	srai x9,x8,31     # apply shift to get sign mask in x9
	xor x10,x8,x9     # x10 = sign(x8)^x8
	andi x9,x9,0x1    # x9 &= 0x1 (carry in)
	add x10,x10,x9    # x10 += x9 (add the carry in)
	addi x4,x4,0x4	  # point to next element
	addi x16,x16,-1   # decrease x16 by 1
	slt x11,x10,x13   # x11 = (x10 < x13) ? 1 : 0
	beq x11,x0,loop   # next element
	add x13,x10,x0    # update min
	jal loop          # next element
done:	
	sw x13,0(x5)      # store the result
	jal dump_regfile
	
dump_regfile:
	sw x0,4(x5)
	sw x1,8(x5)
	sw x4,20(x5)	
	sw x5,24(x5)
	sw x6,28(x5)
	sw x7,32(x5)
	sw x8,36(x5)
	sw x10,44(x5)
	sw x11,48(x5)
	sw x12,52(x5)
	sw x13,56(x5)
	sw x14,60(x5)
	sw x15,64(x5)
	sw x16,68(x5)
	sw x17,72(x5)
	sw x18,76(x5)
	sw x19,80(x5)
	sw x20,84(x5)
	sw x21,88(x5)
	sw x22,92(x5)
	sw x23,96(x5)
	sw x24,100(x5)
	sw x25,104(x5)
	sw x26,108(x5)
	sw x27,112(x5)
	sw x28,116(x5)
	sw x29,120(x5)
	sw x30,124(x5)
	sw x31,128(x5)
	jal endc
	
endc:	
	jal endc  	  # infinite loop
	addi x0,x0,0
	
