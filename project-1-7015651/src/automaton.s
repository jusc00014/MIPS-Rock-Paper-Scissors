# vim:sw=2 syntax=asm

.text
  .globl simulate_automaton, print_tape

# Simulate one step of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, but updates the tape in memory location 4($a0)
simulate_automaton:
  addiu $sp $sp -8
  sw $ra 0($sp)		#Speichert Return Address im Stack
  sw $a0 4($sp)		#Sichere die Addresse der Konfiguration im Stack
 # jal print_tape
  lw $t0 4($sp)		#$t0 enthält die Adresse das Konfiguration
  lb $t7 9($t0)		#$t7 enthält die Regel
  li $t5 0		#in $t5 wird die nächste Überführung gespeichert
  
  move $t4 $ra
  lw $a1 4($t0)		#$a1 enthält das Tape
  lb $t1 8($t0)		#$t1 enthält einen Counter, der bei der Länge des Tapes beginnt
  move $t3 $t1		#$t3 enthält einen Counter, der bei der Länge des Tapes beginnt und nach oben zählt
  addiu $t2 $t1 -2
  srlv $a2 $a1 $t2	#Nur noch letzte zwei Bits z.B. 10100101 wird 00000010
  rem $a3 $a1 2		#Erster Bit
  mul $a3 $a3 4		#z.B. 10100101 wird 00000100  
  addu $a2 $a2 $a3	#$a2 enthält nun den letzten Block
  
hinzufügen:
  li $v0 1
  srlv $t6 $t7 $a2	#Signifikantes Bit der Regel
  remu $t6 $t6 2
  sll $t5 $t5 1
  addu $t5 $t5 $t6	#$t5 enthält das aktuallisierte Tape
  addiu $t1 $t1 -1
  bgt $t1 1 zellen
  bltz $t1 zurück
  
ende:
  move $a2 $a1
  move $a3 $a1
  lb $t1 8($t0)		#$t1 enthält einen Counter, der bei der Länge des Tapes beginnt
  addiu $t2 $t1 -1
  srlv $a3 $a1 $t2	#Nur noch das letzte Bit
  sll $a2 $a1 30
  srl $a2 $a2 29
  addu $a2 $a2 $a3	#$a2 enthält nun den ersten Block
  li $t1 -1
  b hinzufügen 

zellen:
  subiu $t3 $t1 2
  #(AI)->
  srlv $a2 $a1 $t3
  andi $a2 $a2 7
  #<-(AI)
  b hinzufügen
  
zurück:
  sw $t5 4($t0)
  lw $a0 4($sp)
 # jal print_tape
  lw $a0 4 ($sp)
  lw $ra 0($sp)
  addiu $sp $sp 8	#Wiederherstellen der return address
  jr $ra

# Print the tape of the cellular automaton
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return nothing, print the tape as follows:
#   Example:
#       tape: 42 (0b00101010)
#       tape_len: 8
#   Print:  
#       __X_X_X_
print_tape:
  move $t0 $a0
  move $t4 $ra
  lw $a1 4($t0)		#$a1 enthält das Tape
  lb $t1 8($t0)		#$t1 enthält einen Counter, der bei der Länge des Tapes beginnt
  move $a2 $a1		#$a2 enthält eine Kopie des Tapes
  li $v0 11
  li $t2 2
  
loop:
  beq $t1 $0 end	#Wenn Counter = 0 beende
  subiu $t1 $t1 1	#Verringere Counter
  srlv $a2 $a1 $t1	#Verschiebe das Tape um Counter Poritionen nach rechts
  rem $t3 $a2 $t2	#Letzter Bit = 0?
  beqz $t3 print_
  li $a0 'X'
  syscall
  b loop
  
print_:
  li $a0 '_'
  syscall
  b loop
 
end:
  #(AI)->
  li $v0 11
  li $a0 10
  syscall		#Gibt eine neue Zeile aus 
  #<-(AI)
  move $a0 $t0
  jr $ra
