.data
one: .asciiz "one "
two: .asciiz "two "
three: .asciiz "three "
four: .asciiz "four "
five: .asciiz "five "
six: .asciiz "six "
seven: .asciiz "seven "
eight: .asciiz "eight "
nine: .asciiz "nine "
ten: .asciiz "ten "
eleven: .asciiz "eleven "
twelve: .asciiz "twelve "
thirteen: .asciiz "thirteen "
fourteen: .asciiz "fourteen "
fifteen: .asciiz "fifteen "
sixteen: .asciiz "sixteen "
seventeen: .asciiz "seventeen "
eighteen: .asciiz "eightteen "
nineteen: .asciiz "nineteen "
twenty: .asciiz "twenty "
thirty: .asciiz "thirty "
forty: .asciiz "forty "
fifty: .asciiz "fifty "
sixty: .asciiz "sixty "
seventy: .asciiz "seventy "
eighty: .asciiz "eighty "
ninety: .asciiz "ninety "
prompt: .asciiz "Enter a number (0 to 999999)"
output: .asciiz "Output: "
nothing: .asciiz ""
ones: .word nothing, one, two, three, four, five, six, seven, eight, nine
teens: .word ten, eleven, twelve, thirteen, fourteen, fifteen, sixteen, seventeen, eighteen, nineteen
tens: .word nothing, nothing, twenty, thirty, forty, fifty, sixty, seventy, eighty, ninety
zero: .asciiz "Zero"
hundred: .asciiz "hundred "
million: .asciiz "million "
thousand: .asciiz "thousand "
and: .asciiz "and "
space: .asciiz " "
newline: .asciiz "\n"
invalid: .asciiz "Invalid input"
.text
main:
#print prompt 
li $v0, 4
la $a0, prompt
syscall
#load address of ones, teens, tens
	la $t2, ones # $t2 la array ones
	la $t3, teens # $t3 la array teens
	la $t4, tens # $t4 la array tens
#read integer 
li $v0,5
syscall
move $t0, $v0 #store input number in $t0
#check in the range 
li $t7, 999999999 
li $t6, 0
bgt $t0, $t7, invalid_input
blt $t0, $t6 , invalid_input
#print ouput
li $v0, 4
la $a0, output
syscall
#call convertToText
move $a1, $t0 #store input number in $a1
jal convertToText
#Exit:
li $v0,10
syscall
convertToText:
	#case: zero
	beq $a1, $zero, print_zero
	#check if number >= 1000000
	li $t6, 1000000
	bge $a1, $t6, handle_millions
	#check if number >= 1000
	li $t6, 1000
	bge $a1, $t6, handle_thousands
	#otherwise , number >= 100
	li $t6, 20
	blt $a1, $t6, print_ones_and_teens
	jal convertThreeDigitsnotdividea1
	jal convertThreeDigitsa1
	#Exit
	li $v0, 10
	syscall

print_ones_and_teens:
	jal convertThreeDigitsa1
	#Exit
	li $v0, 10
	syscall
handle_millions: 
	#num/1000000 $a1/1000000
	div $a1,$t6
	mflo $t7 # num/1000000 store in $t7
	mfhi $a1 # num %= 1000000
	#call convertthreedigits
	jal convertThreeDigits
	#print million
	li $v0, 4
	la $a0, million
	syscall
	li $t5, 1000 # dat $t5 = 1000
	blt $a1, $t5, L1
	jal handle_thousands
	#jal convertThreeDigitsa1
	#Exit:
	li $v0,10
	syscall
L1: jal convertThreeDigitsa1
	#Exit:
	li $v0, 10
	syscall
handle_thousands:
	#num/1000 $a1/1000
	li $t5, 1000
	div $a1,$t5
	mflo $t7 # num/1000 store in $t7
	mfhi $a1 # num %= 1000
	#call convertthreedigits
	jal convertThreeDigits
	
	#print thousands
	li $v0, 4
	la $a0, thousand
	syscall
	
	jal convertThreeDigitsa1
	#jr $ra
	#Exit:
	li $v0,10
	syscall
convertThreeDigits:
	#check if number >= 100
	li $t5, 100
	bge $t7, $t5, handle_hundreds
	#check if number >= 20
	li $t5, 20
	bge $t7, $t5, handle_tens
	#check if number >= 10
	li $t5, 10
	bge $t7, $t5, handle_teens
	#case number >0
	sll $s5, $t7, 2 # $s5 = 4*nums
	add $s5, $t2, $s5 #s5 = dia chi cua ones[i]
	lw $t9 , 0($s5)
	li $v0,4
	move $a0, $t9
	syscall
	jr $ra
convertThreeDigitsa1:
	
	#check if number >= 100
	li $t5, 100
	bge $a1, $t5, handle_hundredsa1
	#check if number >= 20
	li $t5, 20
	bge $a1, $t5, handle_tensa1
	#check if number >= 10
	li $t5, 10
	bge $a1, $t5, handle_teensa1
	#case number > 0
	sll $s5, $a1, 2 #$s5 = 4*nums [nums = $a1]
	add $s5, $t2, $s5 #s5 = dia chi cua ones[i]
	lw $t8, 0($s5)
	li $v0,4
	move $a0, $t8
	syscall
	jr $ra

handle_hundreds:
	li $t5, 100
	div $t7, $t5 # nums/100
	mflo $a3 # $a3 = num/100
	mfhi $t7 # nums = nums%100
	#print ones[nums/100]
	sll $s5, $a3, 2
	add $s5, $t2, $s5
	lw $t9, 0($s5)
	li $v0,4
	move $a0, $t9
	syscall
	#print hundreds
	li $v0, 4
	la $a0, hundred
	syscall
	li $t5, 20
	blt $t7, $t5, print
	jal convertThreeDigits
	jal convertThreeDigits
	li $t5, 100000
	bge $a1, $t5, print_million
	jal handle_thousands

	#Exit:
	li $v0,10
	syscall
print:	
	jal convertThreeDigits
	li $t5, 100000
	bge $a1, $t5, print_million
	jal handle_thousands
	#exit
	li $v0, 10
	syscall
print_million:
	jal handle_millions
	#exit:
	li $v0,10
	syscall
	
handle_hundredsa1: 
	li $t5, 100
	div $a1, $t5 # nums/100
	mflo $a3 # $a3 = num/100
	mfhi $a1 # nums = nums%100
	#print ones[nums/100]
	sll $s5, $a3, 2
	add $s5, $t2, $s5
	lw $t8, 0($s5)
	li $v0,4
	move $a0, $t8
	syscall
	#print hundreds
	li $v0, 4
	la $a0, hundred
	syscall
	li $t5, 20
	blt $a1, $t5, print_only_one
	jal convertThreeDigitsa1
	jal convertThreeDigitsa1
	#Exit
	li $v0, 10
	syscall
print_only_one:
	jal convertThreeDigitsa1
	#exit
	li $v0, 10
	syscall

handle_tens:
	li $s6, 10
	div $t7, $s6 #chia nums trong th 
	mflo $a3 # $a3 = nums/10
	mfhi $t7 # nums %= 10
	#print_tens
	sll $s5, $a3, 2 #$s5 = 4*i [i = nums/10]
	add $s5, $t4, $s5 # $s5 = dia chi cua tens[i]
	lw $t8, 0($s5)
	li $v0,4
	move $a0, $t8
	syscall 
	jr $ra
handle_tensa1: 
	li $s6, 10
	div $a1, $s6 #chia nums trong th 
	mflo $a3 # $a3 = nums/10
	mfhi $a1 # nums %= 10
	#print_tens
	sll $s5, $a3, 2 #$s5 = 4*i [i = nums/10]
	add $s5, $t4, $s5 # $s5 = dia chi cua tens[i]
	lw $t8, 0($s5)
	li $v0,4
	move $a0, $t8
	syscall 
	jr $ra
handle_teens:
	addi $a3, $t7,-10 # nums -10
	#print teens
	sll $s5, $a3, 2 #$s5 = 4*i [i = nums -10]
	add $s5, $t3, $s5
	lw $t8, 0($s5)
	li $v0,4
	move $a0, $t8
	syscall
	jr $ra	
handle_teensa1:
	addi $a3, $a1,-10 # nums -10
	#print teens
	sll $s5, $a3, 2 #$s5 = 4*i [i = nums -10]
	add $s5, $t3, $s5
	lw $t8, 0($s5)
	li $v0,4
	move $a0, $t8
	syscall
	jr $ra	
convertThreeDigitsnotdividea1:
	#check if number >= 100
	li $t5, 100
	bge $a1, $t5, handle_hundredsa1
	#check if number >= 20
	li $t5, 20
	bge $a1, $t5, handle_tensa1
	#check if number >= 10
	li $t5, 10
	bge $a1, $t5, handle_teensa1
	#case number >0
	sll $s5, $a1, 2 # $s5 = 4*nums
	add $s5, $t2, $s5 #s5 = dia chi cua ones[i]
	lw $t9 , 0($s5)
	li $v0,4
	move $a0, $t9
	syscall
	jr $ra
print_zero:
#print zero
li $v0, 4
la $a0, zero
syscall
#Exit
li $v0, 10
syscall
invalid_input:
#print invalid
li $v0, 4
la $a0, invalid
syscall
#exit
li $v0,10
syscall