##################################################
## Name:    Lab3_Template.s  					##
## Purpose:	Reaction Time Measurement	 		##
## Author:	Mahmoud A. Elmohr 					##
##################################################

# Start of the data section
.data
.align 4						# To make sure we start with 4 bytes aligned address (Not important for this one)
SEED:
	.word 0x1234				# Put any non zero seed

# The main function must be initialized in that manner in order to compile properly on the board
.text
.globl	main
main:
	# Put your initializations here
	li s1, 0x7ff60000 			# assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)
	li s2, 0x7ff70000 			# assigns s2 with the push buttons base address (Could be replaced with lui s2, 0x7ff70)
	addi s3, x0, 0x01    		# 1 in lsb
	li a6, 0x186a0				# a6 = 100k


# Write your code here

#jal x1, Lab1
jal x1, Lab2

#####################################

Lab1:
	sw x0, 0(s1) # turns off leds
	add t4, x0, x0 #t4=0
	addi a4, x0, 0xff

   DISPLAY_BYTE: #counter 0 to 0xff
   loop:
   addi t4, t4, 1
   sw t4, 0(s1) #t4 contains 8 bits
   addi a0, x0, 1000 #1000*0.1= 100ms delay
   jal x1, DELAY

   bne t4, a4, loop

j Lab1 #loops infinitely


######################################
Lab2:
#OG
    #sw x0, 0(s1) # turns off leds
#OG

	#reflex_meter

    li a5, 0x4e20 #20k in hex
	jal x1, RANDOM_NUM  #calling pseudorandom

#EDIT
    srli s5, a0, 2 #Divide by 4
    add a0, a0, s5 #a0 = a0 + 0.25*a0 = 1.25*a0
#EDIT
#OG
    #addi t5, x0, 6		#scaling : mul
    #mul a0, a0, t5

    #addi t5, x0, 5		#scaling : div
    #div a0, a0, t5


    #li a5, 0x4e20 #20k in hex
#OG
	add a0, a0, a5		#scaling : adding offset
	jal x1, DELAY		#calling delay

	sw s3, 0(s1)        #turning ls led on  -- uneven comp -sw
#EDIT
    add t6, t6, zero      #t6 initialized -- is reaction time counter
#EDIT
#OG
    #addi t6, x0, 0      #t6 initialized -- is reaction time counter
#OG
	#jal x1, go_after


POLLING:
#EDIT
    li x7, 1250

    delay_between:#0.1ms delay - e)
        addi x7, x7, -1
        bne zero, x7, delay_between
#EDIT
#OG
    ##addi a0, x0, 1		#delay by 0.1ms
    #addi a0, x0, 1  	#delay by 0.1ms
    #jal x1, DELAY
#OG
	
    addi t6, t6, 1     #t6++

#EDIT
    lw s8, 0(s2)
#EDIT
#OG
    ##picking lsb of pushbutton
    #and s4, s2, s3 #bit masking s2 with s3 = 1 to get the least significant bit of s2
	
	
    ##andi s4, s2, 0x02  #led 1
#OG

    bne s8, zero, POLLING
#EDIT
jal DISPLAY_NUM
#EDIT
#OG
	
    #bgt t6, a6, resize
	
    #j DISPLAY_NUM
	
    #resize:
    #add t6, x0, a6

    #j DISPLAY_NUM

    #jr ra
#OG

# End of main function

#go_after:
#addi t6, t6, 0xf1

# Subroutines
DELAY:
	# Insert your code here to make a delay of a0 * 0.1 ms
#EDIT
li t1, 1250
#EDIT
#OG
    #addi t0, x0, 0x51E #delay counter
    #mul t1, a0, t0 	# no of delays * delay counter
#OG
 wait:

   addi t1, t1, -1 #decrementing counter

   bne zero, t1, wait
#EDIT
    addi a0, a0, -1
    bne a0, zero, DELAY
#EDIT

 jr ra

#print statements

    #addi a0,x0,1

    #addi a1,x0, 8

    #ecall



DISPLAY_NUM:
	# Insert your code here to display the 32 bits in a0 on the LEDs byte by byte (Least significant byte first) with 2 seconds delay for each byte and 5 seconds for the last
#EDIT
    add a7, a7, t6
    li a4, 0xFF
    li x23, 0
#EDIT
#OG
    #addi a7, t6, 0 # storing t6 in a register to preserve for later use
#OG

DISPLAY_EIGHT_BITS:
#EDIT
    and x20, a7, a4
    sw x20, 0(s1)
    li x8, 4
#EDIT
#OG
    ##SEND TO LEDs
    #sb a7, 0(s1)
    ##sb t6, 0(s1)
    ##2s delay
    #add a0, x0, x0
#OG

    li a0, 0x4e20 #20k in hex
    jal x1, DELAY

#EDIT
    addi x23, x23, 1
    srli a7, a7, 8
    blt x23, x8, DISPLAY_EIGHT_BITS
#EDIT
#OG
    #srli a7, a7, 3
    #bne a7, zero, DISPLAY_EIGHT_BITS
#OG
#EDIT
    li x20, 0
    sw zero, 0(s1)
#EDIT

# 5s delay
add a0, x0, x0
li a0, 0xc350 #50k in hex
jal x1, DELAY

#EDIT
    jal DISPLAY_NUM
#EDIT
#OG
    #beq x0, x0, DISPLAY_NUM
#OG
#OG
    #jr ra
#OG




RANDOM_NUM:
	# This is a provided pseudorandom number generator no need to modify it, just call it using JAL (the random number is saved at a0)
	addi sp, sp, -4				# push ra to the stack
	sw ra, 0(sp)

	lw t0, 0(gp)				# load the seed or the last previously generated number from the data memory to t0
	li t1, 0x8000
	and t2, t0, t1				# mask bit 16 from the seed
	li t1, 0x2000
	and t3, t0, t1				# mask bit 14 from the seed
	slli t3, t3, 2				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 14 with bit 16
	li t1, 0x1000
	and t3, t0, t1				# mask bit 13 from the seed
	slli t3, t3, 3				# allign bit 13 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 13 with bit 14 and bit 16
	li t1, 0x400
	and t3, t0, t1				# mask bit 11 from the seed
	slli t3, t3, 5				# allign bit 14 to be at the position of bit 16
	xor t2, t2, t3				# xor bit 11 with bit 13, bit 14 and bit 16
	srli t2, t2, 15				# shift the xoe result to the right to be the LSB
	slli t0, t0, 1				# shift the seed to the left by 1
	or t0, t0, t2				# add the XOR result to the shifted seed
	li t1, 0xFFFF
	and t0, t0, t1				# clean the upper 16 bits to stay 0
	sw t0, 0(gp)				# store the generated number to the data memory to be the new seed
	mv a0, t0					# copy t0 to a0 as a0 is always the return value of any function

	lw ra, 0(sp)				# pop ra from the stack
	addi sp, sp, 4
	jr ra
