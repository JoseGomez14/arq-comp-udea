 .data
	Constantes: .word 16, 1, 25, 4
	Vector: .word 56, -12, -9, -34, 78, -90, 23, 45, -67, 89, -1, 2,
				  -3, 4, -5, 6, -7, 8, -9, 10, 11, -13, 14, -15, 16

 .text
 Main:	
	lw $s0, 0($zero)   		# Cargar la dirección base del vector en $s0
    lw $s1, 4($zero) 		# Cargar el valor en $s1 que será utilizado como contador
    lw $s2, 8($zero) 		# Cargar el valor del tamaño en $s2
    lw $s3, 12($zero)		# Cargar la constante 4
    sub $t0, $s2, $s1 		# Guarda en $t0 el límite del bucle

    jal Ordenar_vector
    jal Positivos_y_negativos
    
    add $s4, $v0, $zero
    add $s5, $v1, $zero
    
    j Fin_programa

Ordenar_vector:
	Loop1:
		slt $t1, $zero, $t0   	   			# Compara si 0 < $t0
        beq $t1, $zero, Fin_ordenar_vector  # Si 0 < $t0, salta a EndLoop1
	  	
        add $t2, $zero, $zero   	# Inicializa el contador del bucle exterior (recorrido)
        add $t3, $s0, $s1  			# Calcular en $t3 la dirección actual

        Loop2:
           	slt $t4, $t2, $t0 	  		# Calcular si $t2 < $t0
            beq $t4, $zero, EndLoop2  	# Sale del Loop2, si $t4 = 0

            sll $t5, $t2, 2   	  	# Calcular el desplazamiento
            add $t5, $s0, $t5  	  	# Calcular en $t5 la dirección actual
            lw $t6, 0($t5)		  	# Carga el elemento actual
            lw $t7, 4($t5)		  	# Carga el elemento siguiente	
          	slt $t1, $t7, $t6       # Calcular si $t7 < $t6
          	beq $t1, $zero, NoSwap  # Calcular si $t1 = $zero
          	beq $t7, $t6, NoSwap	# Calcular si $t7 = $t6 

            sw $t7, 0($t5)		  	# Guardar el valor del siguiente elemento, en la posicion actual
            sw $t6, 4($t5)		  	# Guardar el valor del siguiente elemento, en la siguiente posicion actual

        	NoSwap:
            	add $t2, $t2, $s1 	#Incrementa el contador de Loop2
            	j Loop2				# Salta a Loop2

        	EndLoop2:       			 
            	sub $t0, $t0, $s1   # Decrementa el contador de Loop
            	j Loop1				# Salta a Loop1
            			
	Fin_ordenar_vector:
		jr $ra
			
Positivos_y_negativos:
	add $t0, $zero, $zero   # Inicializar el contador de negativos
    add $t1, $s0, $zero    	# Calcular la dirección base del vector

    While:
    	lw $t2, 0($t1)        						# Cargar el elemento actual del vector
        slt $t3, $t2, $zero   						# Calcular si el elemento actual es menor que 0
        beq $t3, $zero, Fin_positivos_y_negativos   # Salir del while si no se cumple la condición
        add $t0, $t0, $s1     						# Incrementar el contador de negativos
        add $t1, $t1, $s3      						# Avanzar a la siguiente posición del vector
        j While
            
	Fin_positivos_y_negativos:
    	sub $v0, $s2, $t0     # Calcular la cantidad de números positivos
        add $v1, $t0, $zero   # Retornar la cantidad de números negativos
        jr $ra
	
Fin_programa:
	# Se termina el programa con instrucciones 0x00000000