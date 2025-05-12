# vim:sw=2 syntax=asm
.data

.text
  .globl gen_byte, gen_bit

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Compute the next valid byte (00, 01, 10) and put into $v0
#  If 11 would be returned, produce two new bits until valid
#


gen_byte:
  addiu $sp $sp -12
  sw $ra 0($sp)		#Speichere die Return Address im Stack
  sw $a0 4($sp)		#Speichere die Adresse der Configuration im Stack
  move $t0 $ra		#Speichere Return Address für später in in t0
  
loop:
  lw $a0 4($sp)
  jal gen_bit		#Springt zu gen_bit; bei Rückkehr ist ein random Bit in $v0
  sw $v0 8($sp)		#Speichert den ersten Bit im Stack
  lw $a0 4($sp)
  jal gen_bit		#Springt zu gen_bit; bei Rückkehr ist ein random Bit in $v0
  lw $a1 8($sp)
  move $a2 $v0
  beqz $a1 ist0		#Springt zu ist0, wenn der erste Bit 0 ist
  beqz $a2 ist10	#Springt zu ist10, wenn der erste Bit 1 und der zweite Bit 0 ist
  b loop		#Wenn keine der vorherigen Bedingungen erfüllt ist, wiederhole loop

ist0:
  beqz $a2 ist00
  li $v0 1
  b goback
  
ist00:
  li $v0 0
  b goback

ist10:
  li $v0 2
  
goback:
  lw $ra 0($sp)
  lw $a0 4($sp)
  addiu $sp $sp 12
  jr $ra

# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Return value:
#  Look at the field {eca} and use the associated random number generator to generate one bit.
#  Put the computed bit into $v0
#

#Altes gen_bit
gen_bit:
  lw $t2 0($a0)		#Läd den Wert von eca in $t2
  bnez $t2 gen_bit_neu
 # li $a0 0
  move $a0 $t2
  li $v0 41
  syscall
  andi $v0 $a0 1
  lw $a0 4($sp)
  jr $ra

gen_bit_neu:
  lb $t3 10($a0)	#Skips
  #(AI)->
  andi $t3 $t3 0xFFFF	#Macht die Länge von $t3 zu einem Word
  #<-(AI)
  addiu $sp $sp -12
  sw $a0 0($sp)
  sw $t3 4($sp)		#Speichert die Skips im Stack
  sw $ra 8($sp)
  
loo:
  lw $t3 4($sp)		#Läd Anzahl der Skips
  blez $t3 finish
  lw $a0 0($sp)
  jal simulate_automaton
  lw  $t3 4($sp)
  addiu $t3 $t3 -1
  sw $t3 4($sp)
  b loo
  
finish:
  sw $a0 0($sp)
  lw $ra 8($sp)
  addiu $sp $sp 12
  lb $t3 11($a0)	#Column
  lw $a1 4($a0)		#Lade das Tape in $a1
  lb $t4 8($a0)
  subu $t3 $t4 $t3
  subiu $t3 $t3 1
  srlv $a1 $a1 $t3	#Verschiebt den generierten bitstring um Length-Column+1 nach rechts (unsigned)
  andi $a1 $a1 1
  move $v0 $a1		#Kopiert den generierten int nach $v0
  jr $ra
