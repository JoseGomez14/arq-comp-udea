#################################################################################
# Práctica de Laboratorio #2 - AcyLab 2023-1
# Sopa de letras en MIPS
# Autor: Jose David Gómez Muñetón
# Autor: Maritza Tabarez Cárdenas
#################################################################################
.data
	fileSrc: .asciiz "wordsearch.txt"
	inputMessage: .asciiz "Ingrese la palabra que desea buscar"
	wordFoundMessage: .asciiz "\nLa palabra fue encontrada en "
	wordNoFoundMessage: .asciiz "\nLa palabra no fue encontrada :("
	continueSearchMessage: .asciiz "¿Desea buscar otra palabra?"
	badInputMessage: .asciiz "\nEl valor ingresado no es correcto :(, intentelo nuevamente!"
	separator: .asciiz ", "
	horizontal: .asciiz " en sentido horizontal, leida de izquierda a derecha :)"
	horizontalInv: .asciiz " en sentido horizontal, leida de derecha a izquierda :)"
	vertical: .asciiz " en sentido vertical, leida de arriba a abajo :)"
	verticalInv: .asciiz " en sentido vertical, leida de abajo a arriba :)"
	
	.align 2
	fileWords: .space 5050
	.align 2
	inputWord: .space 52

#################################################################################
# Método encargado de inciar la ejecución del programa, leyendo el archivo y dando inicio a la búsqueda de palabras
.text
	la $s4, fileWords				# Punto de inicio de la sopa de letras en memoria
	addi $s5, $s4, 5050				# Punto de finalización de la sopa de letras en memoria
	li $s6, 101 					# Separación entre letras de la misma columna en diferente fila hacia abajo
	li $s7, -101					# Separación entre letras de la misma columna en diferente fila hacia arriba
	jal ReadFile

Main:
	jal ReadWord
	jal GetSizeWord
	add $s0, $v0, $zero  		# Guardar el tamaño de la palabra ingresada en el registro v0
	jal SoupMap


#################################################################################
# Método para finalizar la ejecución del programa
Exit:
	li $v0, 10
	syscall
	

#################################################################################
# Método para abrir, leer y cerrar el archivo de la sopa de letras
ReadFile:
	li $v0, 13
 	la $a0, fileSrc
 	li $a1, 0
 	syscall
 	move $s0, $v0
 			
	li $v0, 14
	move $a0, $s0
	la $a1, fileWords
	li $a2, 5050      	# Espacio reservado para la sopa de letras
	syscall

 	li $v0, 16 
 	move $a0, $s0
 	syscall
 	jr $ra


#################################################################################
# Método para solicitar al usuario que ingrese una palabra
ReadWord:
	la $a0, inputMessage
	li $v0, 54				 # Instrucción del sistema InputDialogString
	la $a1, inputWord
	li $a2, 52				 # Espacio reservado para la palabra
	syscall
	
	beq $a1, -2, Exit
	beq $a1, -3, BadInputValue
	beq $a1, -4, BadInputValue
	jr $ra		


#################################################################################
# Método para informar al usuario que la palabra ingresada no es válida 
BadInputValue:
	la $a0, badInputMessage
	li $a1, 0
	li $v0, 55
	syscall
	jal Main


#################################################################################	
# Método para obtener el tamaño de la palabra ingresada
# valor de retorno $v0: el valor total de letras de la palabra 
GetSizeWord:
	la  $t2, inputWord
	lbu $t3, ($t2)
	loop:	
		addi $t2, $t2, 1
		lbu $t3, ($t2)
	 	bne $t3, 0x0a, loop
	 la  $t3, inputWord
	 sub $v0, $t2, $t3	
	 jr $ra


#################################################################################	
# Método para recorrer el vector(letra por letra), omitiendo los espacios y caracteres de control
# Este método tambien se encarga de verificar si la letra leída coincide con la letra inicial de la 
# palabra ingresada 
SoupMap:
	addi 	$sp, $sp, -4
	sw   	$ra, 0($sp)		# $ra al stack

	la $t0, fileWords 		# Dirección de memoria de la sopa
	la $t1, inputWord		# Dirección de memoria de la palabra a buscar
	li $s1, 1				# Número de fila inicial
	li $s2, 1				# Número de columna inicial
	lbu $t2, ($t1) 			# Primera letra de la plabra
	j BreakCol
	
	BreakRow:
		addi $t0, $t0, 1
		addi $s1, $s1, 1
		addi $s2, $zero, 1
		
		BreakCol:
			lbu $t3, ($t0)
			beq $t2, $t3, FindWord
		Continue:
			beq $t3, 0x0a, BreakRow  
			addi $t0, $t0, 2
			add $s2, $s2, 1
			bne $t3, $zero, BreakCol	
			j EndSoupMap
	
	FindWord:
		add $a0, $t1, $zero   	# Dirección de la palabra
		add $a1, $t0, $zero		# Dirección en la sopa a partir de la cual se va a buscar
		
		li $a2, 2				# Preparar el atributo a2 para recorrer la sopa de letras horizontalmente hacia la derecha
		jal Find
		la $s3, horizontal
		bne $v0, $zero, PrintWordFound
		
		li $a2, -2			# Preparar el atributo a2 para recorrer la sopa de letras horizontalmente en sentido opuesto
		jal Find
		la $s3, horizontalInv
		bne $v0, $zero, PrintWordFound
		
		add $a2, $zero, $s6			# Preparar el atributo a2 para recorrer la sopa de letras verticalmente hacia abajo
		jal Find
		la $s3, vertical
		bne $v0, $zero, PrintWordFound
		
		add $a2, $zero, $s7			# Preparar el atributo a2 para recorrer la sopa de letras verticalmente hacia arriba
		jal Find
		la $s3, verticalInv
		bne $v0, $zero, PrintWordFound
		j Continue
	
EndSoupMap:
	lw   	$ra, 0($sp)			# Recupera $ra del stack
	addi 	$sp, $sp, 4			# Restaura el $sp
	jal PrintNoFoundWord
	jr $ra


#################################################################################
# Método para validar que la palbra existe en la sopa de letras en diferentes direcciones
# $a0 - Dirección de la palabra a buscar
# $a1 - Dirección en la sopa a partir de la cual se va a buscar
# $a2 - Cantidad y dirección del desplazamiento (2: Una letra a la derecha, -2: Una letra a la izquierda,
# $s6: Una letra hacia abajo, $s7: Una letra hacia arriba)
# Valor de retorno de $v0: 0:La palabra no fue encontrada o 1:La palabra fue encontrada
 Find:
	add $v0, $zero, $zero
	add $t4, $a0, $zero
	add $t5, $a1, $zero
	
	WordMap:	
		lb $t6, 0($t4)
		lb $t7, 0($t5)
		beq $t6, 0x0a, WordFound		# Se terminó de leer toda la palabra (Es decir, se encontró)
		blt $t5, $s4, EndFind			# Se excede el limite de inicio de la sopa en memoria
		bgt $t5, $s5, EndFind			# Se excede el limite del fin de la sopa en memoria
		beq $t7, 0x0a, EndFind 			# Se terminó de leer la fila de la sopa (No se encontró la palabra)
		bne $t6, $t7, EndFind    		# La palabra deja de coincidir letra a letra
		add $t4, $t4, 1					
		add $t5, $t5, $a2				
		j WordMap
	
	WordFound:
		addi $v0, $zero, 1				

 EndFind:	
	jr $ra


#################################################################################
# Método para mostrar el mensaje cuando la palabra fue encontrada y la información relacionada a este evento 
PrintWordFound:
	la $a0, wordFoundMessage
	li $v0, 4
	syscall
	
	add $a0, $s1, $zero
	li $v0, 1
	syscall
	
	la $a0, separator
	li $v0, 4
	syscall
	
	add $a0, $s2, $zero
	li $v0, 1
	syscall
	
	add $a0, $s3, $zero
	li $v0, 4
	syscall
	
	jal NextQuery


#################################################################################
# Método para mostrar un mensaje cuando la palabra no fue encontrada 
PrintNoFoundWord:
	la $a0, wordNoFoundMessage
	li $v0, 4
	syscall
	jal NextQuery


#################################################################################
# Método para saber si se desea generar una nueva consulta al programa 
NextQuery:
	la $a0, continueSearchMessage
	li $v0, 50
	syscall
	beq $a0, 0, Main
	jal Exit
