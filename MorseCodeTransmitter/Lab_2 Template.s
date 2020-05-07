# Start of the data section

.data

.align 4      # To make sure we start with 4 bytes aligned address (Not important for this one)

InputLUT:

 # Use the following line only with the board

 #.ascii "AVMAE"    # Put the 5 Letters here instead of ABCDE

 

 # Use the following 2 lines only on Venus simulator

 .asciiz "AVMAE"   # Put the 5 Letters here instead of ABCDE

 .asciiz "X"    # Leave it as it is. It's used to make sure we are 4 bytes aligned  (as Venus doesn't have the .align directive)

 

.align 4      # To make sure we start with 4 bytes aligned address (This one is Important)

MorseLUT:

 .word 0xE800

 .word 0xAB80

 .word 0xBAE0

 .word 0xAE00

 .word 0x8000

 .word 0xBA80

 .word 0xBB80

 .word 0xAA00

 .word 0xA000

 .word 0xEEE8

 .word 0xEB80

 .word 0xAE80

 .word 0xEE00

 .word 0xB800

 .word 0xEEE0

 .word 0xBBA0

 .word 0xEBB8

 .word 0xBA00

 .word 0xA800

 .word 0xE000

 .word 0xEA00

 .word 0xEA80

 .word 0xEE80

 .word 0xEAE0

 .word 0xEEB8

 .word 0xAEE0


# The main function must be initialized in that manner in order to compile properly on the board

.text

.globl main

main:

 # Put your initializations here

 li s1, 0x7ff60000    # assigns s1 with the LED base address (Could be replaced with lui s1, 0x7ff60)

 li s2, 0x01     # assigns s2 with the value 1 to be used to turn the LED on

 la s3, InputLUT    # assigns s3 with the InputLUT base address

 la s4, MorseLUT    # assigns s4 with the MorseLUT base address

 addi t5, zero, 1   # for conditional branches

 sw zero, 0(s1)    # Turn the LED off

 ResetLUT:

  mv s5, s3    # assigns s5 to the address of the first byte in the InputLUT

 NextChar:

  lbu a0, 0(s5)    # loads one byte from the InputLUT

  addi s5, s5, 1    # increases the index for the InputLUT (For future loads)

  bne a0, zero, ProcessChar # if char is not NULL, jumps to ProcessChar

  # If we reached the end of the 5 letters, we start again

  li a0, 4      # delay 4 extra spaces (7 total) between words to terminate

  jal DELAY

  j ResetLUT     # start again

 ProcessChar:

  jal CHAR2MORSE    # convert ASCII to Morse pattern in a0

 RemoveZeros:

  # Write your code here to remove trailing zeroes until you reach a one

  lw t6,0(a0) #load t6 to work on the a0 register instead of directly on a0

  check:

  and t3, t6, t5 #bit masking t6 with t5 = 1 to get the least significant bit of t6 - PROBLEM - don't change t6, use other register

  bne t3, t5, shift #check if LSB of t6 = t5 = 1, if not, go to 'shift' label; if yes, keep going

 

  j Shift_and_display #Going through the character to display for each bit

  

 shift: #right shifts t6 by 1 and jumps back to the 'check' label

  srli t6, t6, 1

  j check

 #and t3, t6, t5

 Shift_and_display:

  # Write your code here to peel off one bit at a time and turn the light on or off as necessary

bne t3, t5, off_call #if LSB is zero, goes to off_call label; else, proceed

    

    jal ra, LED_ON #LSB = 1, go to LED_ON - PROBLEM: goes to LED_ON, comes back, delays by one dot, and then, goes to off_call? - Is a flaw?

    j delay_dot #jump to delay_dot


    off_call:

     jal ra, LED_OFF

 

  # Delay after the LED has been turned on or off

  delay_dot: #delay by one dot as instructed

  

  #addi a0, x0, 0

  addi a0, x0, 1

  jal x1, DELAY


  # Test if all bits are shifted

  # If we're not done then loop back to Shift_and_display to shift the next bit

  

  srli t6, t6, 1 #bit shift by 1
and t3, t6, t5
  bne t6, zero, Shift_and_display

  

  # If we're done then branch back to get the next character

  #addi a0, x0, 0

  jal LED_OFF

  addi a0, x0, 3 #3 dots after displaying 1 char

  jal ra, DELAY

  j NextChar

# End of main function





# Subroutines

LED_OFF:

 # Insert your code here to turn LED off

 sw zero, 0(s1)

    

    #print statements

    

   addi a0,x0,1

   addi a1,x0,0

   ecall

    

 jr ra


LED_ON:

 # Insert your code here to turn LED on

 sw s2, 0(s1)
 

   addi a0,x0,1

   addi a1,x0,1

   ecall

 jr ra


DELAY:

 # Insert your code here to make a delay of a0 * 500ms

    #lui t0, 0x300

 #lui t0,0x640

 addi t0, t0,2

 mul t1, a0, t0

  wait:

   addi t1, t1, -1

   bne zero, t1, wait

            

#print statements

    #addi a0,x0,1

    #addi a1,x0, 8

    #ecall

    

 jr ra


CHAR2MORSE:

 # Insert your code here to convert the ASCII code to an index and lookup the Morse pattern in the Lookup Table

 addi a0,a0,-0x41 #contains the index for morse Lut

 slli t4,a0,2

 add  a0,t4,s4

 jr ra

 

