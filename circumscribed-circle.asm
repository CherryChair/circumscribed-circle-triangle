	.data
endl:	.asciiz "\n"
	.align 2
prompt_circle: .asciiz "____________________________________________________________"
prompt: .asciiz "Enter triangle coordinates:\n"
c_prompts:
	.asciiz "x1: "
	.asciiz "y1: "
	.asciiz "x2: "
	.asciiz "y2: "
	.asciiz "x3: "
	.asciiz "y3: "
	
	.align 2
x1:	.word 0
y1:	.word 0
x2:	.word 0
y2:	.word 0
x3:	.word 0
y3:	.word 0

x_c:	.word 0
y_c:	.word 0
r_sqrd:	.word 0

a1:	.word 0
b1:	.word 0
c1:	.word 0
a2:	.word 0
b2:	.word 0
c2:	.word 0

current_point:
c_x:	.word 0
c_y:	.word 0

ending_point:
e_x:	.word 0
e_y:	.word 0


filename:	.asciiz "in.bmp"
filename_w:	.asciiz "out.bmp"
file_size:	.word 0
file_h:	.word 1024
file_w: .word 1024
width_msg: .asciiz "Width of in.bmp is: "
height_msg: .asciiz "Height of in.bmp is: "
res_h:	.word 1024
res_w: 	.word 1024
file_start: .word 0
	.align 2
file_header:	.space 62
error_input:	.asciiz "One of given point is out of bounds of in.bmp. Retaking the input.\n"
error_circle:	.asciiz "!!!Circle point out of bounds of bmp file!!! Exiting program..."
error_line:	.asciiz "Given points are on one line!!! Retaking the input.\n"
	.text
	.globl main
	
main:





	#otwieramy plik
	li $v0, 13
	la $a0, filename
	li $a1, 0
	li $a2, 0
	syscall
	move $s0, $v0
	
	########
	#czytamy nag³owek pliku
	
	move $t0, $zero
	addi $t0, $t0, 62
	li $v0, 14
	move $a0, $s0
	la $a1, file_header
	move $a2, $t0
	syscall
	
	
#wyliczamy "szerokoœæ" pliku w bitach i jego szerokoœæ w pikselach
	la $t0, file_header
	addiu $t0, $t0, 18
	lbu $t1, ($t0)
	move $a0, $t1
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 8
	or $a0, $t1, $a0
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 16
	or $a0, $t1, $a0
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 24
	or $a0, $t1, $a0
	sw $a0, res_w
	div $a0, $a0, 32
	mfhi $t0
	mul $a0, $a0, 32
	beqz $t0, dont_pad_file
	addiu $a0, $a0, 32
dont_pad_file:
	sw $a0, file_w
	
	
	li $v0, 4
	la $a0, width_msg
	syscall
	
	lw $a0, res_w
	li $v0, 1
	syscall
	li $v0, 4
	la $a0, endl
	syscall
	
	
#pobieramy wysokoœæ pliku
	la $t0, file_header
	addiu $t0, $t0, 22
	lbu $t1, ($t0)
	move $a0, $t1
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 8
	or $a0, $t1, $a0
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 16
	or $a0, $t1, $a0
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 24
	or $a0, $t1, $a0
	sw $a0, file_h
	sw $a0, res_h

	li $v0, 4
	la $a0, height_msg
	syscall
	
	lw $a0, res_h
	li $v0, 1
	syscall	
	li $v0, 4
	la $a0, endl
	syscall
	
	
	#szukamy wielkoœci pliku
	la $t0, file_header
	addiu $t0, $t0, 2
	lbu $t1, ($t0)
	move $a0, $t1
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 8
	or $a0, $t1, $a0
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 16
	or $a0, $t1, $a0
	addiu $t0, $t0, 1
	lbu $t1, ($t0)
	sll $t1, $t1, 24
	or $a0, $t1, $a0
	sw $a0, file_size
	
	#alokujemy bajty
	li $v0, 9
	lw $a0, file_size
	syscall
	move $s7, $v0
	
	#kopiujemy nag³owek do pamiêci
	li $t0, 16
	la $t1, file_header
	move $t3, $s7
copy_header:
	lw $t2, ($t1)
	sw $t2, ($t3)
	subiu $t0, $t0, 1
	addiu $t1, $t1, 4
	addiu $t3, $t3, 4
	bnez $t0, copy_header
	
	
	#znajdujemy iloœæ znaków do przeczytania
	lw $t1, file_h
	lw $t2, file_w
	mul $t0, $t1, $t2
	div $t0, $t0, 8
	
	
	#czytamy tyle bajtów ile trzeba
	li $v0, 14
	move $a0, $s0
	la $a1, ($s7)
	addiu $a1, $a1, 62
	move $a2, $t0
	syscall
	move $s1, $v0


input_taking:
	li $v0, 4
	la $a0, prompt
	syscall
	
	la $a0, c_prompts
	li $t0, 6
	la $t1, x1

input_loop:	
	li $v0, 4
	syscall

	li $v0, 5
	syscall
	
	subiu $t0, $t0, 1
	addi $a0, $a0, 5
	sw $v0, ($t1)
	addiu $t1, $t1, 4
	bnez $t0, input_loop


#sprawdzamy poprawnoœæ wpisanych punktów, jeœli jeden z nich nie jest poprawny
#wyœwietlamy komunikat i ponownie pobieramy dane
	li $t0, 3
	la $t1, x1
	lw $t3, res_w
	
loop_correct_points_x:
	lw $t2, ($t1)
	bgt $t3, $t2, point_correct_x
	
	li $v0, 4
	la $a0, error_input
	syscall
	
	b input_taking
	
point_correct_x:
	addiu $t1, $t1, 8
	subiu $t0, $t0, 1
	bnez $t0, loop_correct_points_x
	
	li $t0, 3
	la $t1, y1
	lw $t3, res_h
	
loop_correct_points_y:
	lw $t2, ($t1)
	bgt $t3, $t2, point_correct_y
	
	li $v0, 4
	la $a0, error_input
	syscall
	
	b input_taking
	
	
point_correct_y:
	addiu $t1, $t1, 8
	subiu $t0, $t0, 1
	bnez $t0, loop_correct_points_y


#liczymy równania dwóch symetalnych trójk¹ta
sym_triangle:

	lw $t0, x1
	lw $t1, y1
	lw $t2, x2
	lw $t3, y2
	subu $t4, $t0, $t2	#x1-x2
	subu $t5, $t1, $t3	#y1-y2
	addu $t6, $t0, $t2	#x1+x2
	addu $t7, $t1, $t3	#y1+y2
	mul $t0, $t4, $t6	#x1^2-x2^2
	mul $t1, $t5, $t7	#y1^2-y2^2
	addu $t0, $t0, $t1	
	sw $t0, c1
	#mul $t4, $t4, -2
	sll $t4, $t4, 1
	subu $t4, $zero, $t4
	sw $t4, a1
	#mul $t5, $t5, -2
	sll $t5, $t5, 1
	subu $t5, $zero, $t5
	sw $t5, b1

	lw $t0, x1
	lw $t1, y1
	lw $t2, x3
	lw $t3, y3
	subu $t4, $t0, $t2	#x1-x2
	subu $t5, $t1, $t3	#y1-y2
	addu $t6, $t0, $t2	#x1+x2
	addu $t7, $t1, $t3	#y1+y2
	mul $t0, $t4, $t6	#x1^2-x2^2
	mul $t1, $t5, $t7	#y1^2-y2^2
	addu $t0, $t0, $t1	
	sw $t0, c2
	#mul $t4, $t4, -2
	sll $t4, $t4, 1
	subu $t4, $zero, $t4
	sw $t4, a2
	#mul $t5, $t5, -2
	sll $t5, $t5, 1
	subu $t5, $zero, $t5
	sw $t5, b2

#ze znalezionych wczeœniej równañ symetralnych trójk¹ta obliczamy œrodek ko³a opisanego
find_center:
	lw $t0, a1
	lw $t1, b1
	lw $t2, c1
	lw $t3, a2
	lw $t4, b2
	lw $t5, c2
	mul $t6, $t0, $t4	#a1b2
	mul $t7, $t1, $t3	#a2b1
	subu $t6, $t6, $t7	#a1b2-a2b1
	bnez $t6, not_on_line
	
	li $v0, 4
	la $a0, error_line
	syscall
	
	b input_taking
	
not_on_line:

	
	mul $t7, $t2, $t3	#c1a2
	mul $t8, $t0, $t5	#c2a1
	subu $t7, $t7, $t8	#c1a2-c2a1
	mul $t8, $t2, $t4	#c1b2
	mul $t9, $t1, $t5	#c2b1
	subu $t8, $t9, $t8	#c2b1-c1b2
	#mul $t8, $t8, 2
	sll $t8, $t8, 1
	#mul $t7, $t7, 2
	sll $t7, $t7, 1
	div $t0, $t8, $t6	#x_c
	div $t1, $t7, $t6	#y_c
	andi $t2, $t0, 1
	beqz $t2, round_down_x
	addiu $t0, $t0, 1
round_down_x:
	sra $t0, $t0, 1
	sw $t0, x_c
	andi $t3, $t1, 1
	beqz $t3, round_down_y
	addiu $t1, $t1, 1
round_down_y:
	sra $t1, $t1, 1
	sw $t1, y_c

#liczymy kwadrat promienia, przy czym wybieramy najwy¿szy wynik spoœród punktów trójk¹ta,
#¿eby nasze ko³o nie przeciê³o trójk¹ta w pewnym miejscu 
find_radius:
	lw $t0, x_c
	lw $t1, y_c
	
	lw $t2, x1
	lw $t3, y1
	subu $t4, $t0, $t2
	subu $t5, $t1, $t3
	mul $t4, $t4, $t4
	mul $t5, $t5, $t5
	addu $t6, $t4, $t5
 
	lw $t2, x2
	lw $t3, y2
	subu $t4, $t0, $t2
	subu $t5, $t1, $t3
	mul $t4, $t4, $t4
	mul $t5, $t5, $t5
	addu $t7, $t4, $t5
	
	lw $t2, x3
	lw $t3, y3
	subu $t4, $t0, $t2
	subu $t5, $t1, $t3
	mul $t4, $t4, $t4
	mul $t5, $t5, $t5
	addu $t8, $t4, $t5
	
	move $t0, $t6
	bge $t6, $t7, t6_grater
	move $t0, $t7
	bge $t7, $t8, end
	move $t0, $t8
	b end
t6_grater:
	bge $t6, $t8, end
	move $t0, $t8
end:
	sw $t0, r_sqrd
	
	
	
draw_triangle:
	lw $a0, x1
	lw $a1, y1
	lw $a2, x2
	lw $a3, y2
	jal draw_line
	
	lw $a0, x2
	lw $a1, y2
	lw $a2, x3
	lw $a3, y3
	jal draw_line
	
	lw $a0, x3
	lw $a1, y3
	lw $a2, x1
	lw $a3, y1
	jal draw_line
	
draw_circle:
	lw $s6, r_sqrd
	move $t0, $zero


#szukamy wektora w postaci [x,0], dla którego x^2 jest najbli¿ej r^2 
starting_point_loop:
	addiu $t0, $t0, 1
	mul $t1, $t0, $t0
	blt $t1, $s6, starting_point_loop
	subu $t2, $t1, $s6
	subiu $t0, $t0, 1
	mul $t1, $t0, $t0
	subu $t3, $s6, $t1
	blt $t3, $t2, start_drawing
	addiu $t0, $t0, 1
	
start_drawing:
	sw $t0, c_x
	sw $zero, c_y

loop_drawing:
	#rysujemy punkty
	li $a0, 1
	li $a1, 1
	li $a2, 1
	jal draw_q
	
	li $a0, -1
	li $a1, 1
	li $a2, 1
	jal draw_q
	
	li $a0, 1
	li $a1, -1
	li $a2, 1
	jal draw_q
	
	li $a0, -1
	li $a1, -1
	li $a2, 1
	jal draw_q
	
	li $a0, 1
	li $a1, 1
	li $a2, -1
	jal draw_q
	
	li $a0, -1
	li $a1, 1
	li $a2, -1
	jal draw_q
	
	li $a0, 1
	li $a1, -1
	li $a2, -1
	jal draw_q
	
	li $a0, -1
	li $a1, -1
	li $a2, -1
	jal draw_q
	
	
	#znajdujemy kolejne punkty, podobna zasada jak w rysowaniu prostej
	#mo¿emy zastosowaæ nasz¹ funkcjê evaluate_point, wstawiaj¹c 
	#argumenty w postaci x x y y -r^2
	lw $a0, c_x
	lw $a1, c_x
	lw $a2, c_y
	lw $a3, c_y
	subu $t0, $zero, $s6
	addiu $a2, $a2, 1
	addiu $a3, $a3, 1
	#jal evaluate_point
	mul $t1, $a0, $a1	# a*x
	mul $t2, $a2, $a3	# b*y
	addu $t1, $t1, $t2	# a*x+b*y
	addu $t1, $t1, $t0	# a*x+b*y+c
	move $v0, $t1
	
	abs $s5, $v0
	
	addiu $a0, $a0, -1
	addiu $a1, $a1, -1
	#jal evaluate_point
	mul $t1, $a0, $a1	# a*x
	mul $t2, $a2, $a3	# b*y
	addu $t1, $t1, $t2	# a*x+b*y
	addu $t1, $t1, $t0	# a*x+b*y+c
	move $v0, $t1
	
	abs $s4, $v0
	
	
	sw $a2, c_y
	blt $s5, $s4, move_up
	b move_diag

move_up:
	addu $a0, $a0, 1
	sw $a0, c_x
	ble $a2, $a0, loop_drawing
	
move_diag:
	sw $a0, c_x
	ble $a2, $a0, loop_drawing




end_program:
	
	
	
	#tworzymy nowy plik do zapisu
	li $v0, 13
	la $a0, filename_w
	li $a1, 1
	li $a2, 0
	syscall
	move $s2, $v0
	
	#zapisujemy dane
	li $v0, 15
	move $a0, $s2
	la $a1, ($s7)
	lw $a2, file_size
	syscall
	move $s3, $v0
	
	
	
	
	
	li   $v0, 16      
  	move $a0, $s0      
  	syscall          
  	
  	li   $v0, 16
  	move $a0, $s2      
  	syscall

	li $v0, 10
	syscall
	





#rysuje liniê od punktu x1,y1 do punktu	x2,y2
#rejestry argumentów $a0 x1, $a1 y1, $a2 x2, $a3 y2	
draw_line:
	subu $t0, $a2, $a0	#x wektora
	subu $t1, $a3, $a1	#y wektora
	
	sw $a0, c_x
	sw $a1, c_y
	sw $a2, e_x
	sw $a3, e_y

#poruszamy siê po s¹siednich pikselach, poni¿ej liczymy dwa mo¿liwe kierunki ruchu,
#jeœli chcemy poruszaæ siê od punktu x1,y1 do punktu x2,y2 jak nabli¿ej prostej, która je ³¹czy
#punkt, który jest bli¿ej bêdziemy wybieraæ przez wstawienie dwóch mo¿liwych nastêpnych do równania prostej
#i porównuj¹c otrzymane wyniki, wynik o mniejszej wartoœci bezwzglêdnej jest punktem, gdzie chcemy siê znaleŸæ
	blez $t0, x_negative
	
x_positive:
	li $t4, 1
	blez $t1, y_negative 
	b y_positive	
x_negative:
	li $t4, -1
	blez $t1, y_negative
	
y_positive:
	li $t5, 1
	b find_other_vector
y_negative:	
	li $t5, -1
	
find_other_vector:
	abs $t6, $t0
	abs $t7, $t1
	ble $t6, $t7, y_grater
	
x_grater:
	div $t6, $t0, $t6
	move $t7, $zero
	b find_line
y_grater:
	div $t7, $t1, $t7
	move $t6, $zero

find_line:
#wrzucamy do odpowiednich rejestrów a i b prostej, po której siê ruszamy
	mul $a0, $t1, -1
	move $a2, $t0
	
#liczymy c prostej, po której siê poruszamy
	lw $t0, c_x
	lw $t1, e_y
	mul $t2, $t0, $t1
	lw $t0, e_x
	lw $t1, c_y
	mul $t3, $t0, $t1
	subu $t0, $t2, $t3	#c
	move $t9, $ra

loop_line:
	lw $a1, c_x
	lw $a3, c_y
	jal colour_point


	addu $a1, $a1, $t4
	addu $a3, $a3, $t5
	
	#jal evaluate_point
	mul $t1, $a0, $a1	# a*x
	mul $t2, $a2, $a3	# b*y
	addu $t1, $t1, $t2	# a*x+b*y
	addu $t1, $t1, $t0	# a*x+b*y+c
	move $v0, $t1
	
	abs $t8, $v0
	subu $a1, $a1, $t4
	subu $a3, $a3, $t5
	
	
	addu $a1, $a1, $t6
	addu $a3, $a3, $t7
	
	#jal evaluate_point
	mul $t1, $a0, $a1	# a*x
	mul $t2, $a2, $a3	# b*y
	addu $t1, $t1, $t2	# a*x+b*y
	addu $t1, $t1, $t0	# a*x+b*y+c
	move $v0, $t1
	
	subu $a1, $a1, $t6
	subu $a3, $a3, $t7

	abs $v0, $v0
	blt $t8, $v0 go_diag
	
go_vh:
	addu $a1, $a1, $t6
	addu $a3, $a3, $t7
	sw $a1, c_x
	sw $a3, c_y
	
	
	lw $t1, e_x
	lw $t2, e_y
	bne $a1, $t1, loop_line
	bne $a3, $t2, loop_line
	b end_line
	
go_diag:
	addu $a1, $a1, $t4
	addu $a3, $a3, $t5
	sw $a1, c_x
	sw $a3, c_y
	

	lw $t1, e_x
	lw $t2, e_y
	bne $a1, $t1, loop_line
	bne $a3, $t2, loop_line

	
end_line:
	jr $t9
	
	
	


	
#rejestry argumentów $a0 a, $a1 x, $a2 b, $a3 y, $t0 c
#rejestr wynikowy $ra
evaluate_point: 
	mul $t1, $a0, $a1	# a*x
	mul $t2, $a2, $a3	# b*y
	addu $t1, $t1, $t2	# a*x+b*y
	addu $t1, $t1, $t0	# a*x+b*y+c
	move $v0, $t1
	jr $ra
	
	
	
	
#w etykietach x_c, y_c s¹ wspó³rzêdne œrodka okrêgu, w etykietach c_x, c_y s¹ wspó³rzêdne wektora
#w $a0 jest znak pierwszej wspó³rzêdnej wektora, w $a1 jest znak pierwszej drugiej wektora
#jeœli w $a2 jest -1, to zamieniamy wspó³rzêdne wektora kolejnoœci¹
draw_q:
	lw $t0, x_c
	lw $t1, y_c
	lw $t2, c_x
	lw $t3, c_y
	bne $a2, -1, no_switcheroo
	move $t4, $t2
	move $t2, $t3
	move $t3, $t4

no_switcheroo:
	mul $t2, $t2, $a0
	mul $t3, $t3, $a1
	addu $t0, $t0, $t2
	addu $t1, $t1, $t3
	move $t9, $ra
	
	

	
	

	move $a1, $t0
	move $a3, $t1
	
	lw $t2, res_w
	lw $t3, res_h
	bgt $a3, $t3, dont_colour
	bgt $a1, $t2, dont_colour
	bltz $a3, dont_colour
	bltz $a1, dont_colour
	jal colour_point

dont_colour:	
	jr $t9
	
	
#W rejestrze $a1 znajduje siê wspó³rzêdna x punktu do pokolorowania
#W rejestrze $a3 znajduje siê wspó³rzêdna y punktu do pokolorowania
#W rejestrze $s7 znajduje siê pocz¹tek naszego pliku bmp
#dostêpne rejestry tymczasowe $a1, $a3, $t1, $t2, $t3
colour_point:
	#liczymy, który bit pliku musimy zmieniæ
	lw $t1, file_h
	subu $t1, $t1, $a3
	subu $t1, $t1, 1
	lw $t2, file_w
	div $t2, $t2, 8
	mul $t1, $t1, $t2
	div $v0, $a1, 8
	addu $t1, $t1, $v0
	addiu $t1, $t1, 62
	#dodajemy do adresu wyliczon¹ pozycjê bajta, w którym znajduje siê nasz punkt
	addu $t1, $t1, $s7
	lb $t3, ($t1)
	mfhi $t2
	beq $t2, 0, rest_0
	beq $t2, 1, rest_1
	beq $t2, 2, rest_2
	beq $t2, 3, rest_3
	beq $t2, 4, rest_4
	beq $t2, 5, rest_5
	beq $t2, 6, rest_6
	beq $t2, 7, rest_7

rest_0:
	and $t3, $t3, 0x7F
	b color
rest_1:
	and $t3, $t3, 0xBF
	b color
rest_2:
	and $t3, $t3, 0xDF
	b color
rest_3:
	and $t3, $t3, 0xEF
	b color
rest_4:
	and $t3, $t3, 0xF7
	b color
rest_5:
	and $t3, $t3, 0xFB
	b color
rest_6:
	and $t3, $t3, 0xFD
	b color
rest_7:
	and $t3, $t3, 0xFE
color:
	sb $t3, ($t1)
	jr $ra

