	.data
	.align	2
A:
	.word 15
X:
	.word 34
P:
	.word 0

	.text
	.align	2
	.globl	__start
	
__start:
	li x16,16         # put 16 in x16 (number of bits = number of iterations)
	la x4,A           # put in x4 the address of A (x4 <= A)
	lw x4,0(x4)       # load in x4 the value of A
	la x5,X		  # put in x5 the address of X (x5 <= X)
	lw x5,0(x5)	  # load in x4 the value of X
	li x6, 0	  # reset the register where P = A * X will be saved
	la x30,P	  # save in x30 the memory address where the product will be saved
	li x7,0		  # use x7 to store the dummy bit and set to zero
	li x18,1	  # use x18 to store 1 (useful when need to compare something with 1)
	li x19,0xffffffff # load x19 to store all 1s (to invert and compute CA2)

loop:
	beq x16,x0,done   	# check if all 32 iterations have been done otherwise go to the algorithm
	andi x8,x5,0x1    	# obtain last bit from X (masking it with 0x1)
	slli x9,x4,16     	# x9 <= x4 shifted by 16 (A << 16)
	beq x8,x18,sub_check	# if last bit from X = 1 go to sub_check...
	jal sum_check        	# otherwise go to sum check
	
sub_check:
	beq x7,x0,subt		# if x7 (dummy bit) is equal to zero... then you need to subtract (P = P-(A<<16))
	jal sum_check		# otherwise go to sum check

subt:
	xor x9,x9,x19
	addi x9,x9,0x1
	add x6,x6,x9		# compute P = P - (A << 16)
	jal finish_iteration	# go to the routine for the end of one iteration
	
sum_check:
	beq x8,x0,sum_check2	# if the last bit of X (x8) is zero go to the second check...
	jal finish_iteration 	# otherwise you don't have to do anything, go to finish_iteration
	
sum_check2:
	beq x7,x18,sum		# if also the dummy bit is one (x7: dummy bit; x8: 1)
	jal finish_iteration	# otherwise you don't have to do anything for this iteration
	
sum:
	add x6,x6,x9		# if sum_check and sum_check2 are true... P = P + (A << N)
	jal finish_iteration	# go to the finish_iteration
	
finish_iteration:
	add x7,x8,x0		# move the last bit of X to the dummy bit (update dummy bit for next iteration)
	srai x5,x5,1		# shift X by 1
	srai x6,x6,1		# shift P by 1
	addi x16,x16,-1		# subtract one from the remaining iterations
	jal loop		# go to loop
	
done:
	sw x6,0(x30)		# when iterations are over, store the product 
	
endc:	
	jal endc  	 	# infinite loop
	addi x0,x0,0
	
