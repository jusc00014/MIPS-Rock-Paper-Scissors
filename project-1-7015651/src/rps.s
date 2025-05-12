# vim:sw=2 syntax=asm
.data

.text
  .globl play_game_once

# Play the game once, that is
# (1) compute two moves (RPS) for the two computer players
# (2) Print (W)in (L)oss or (T)ie, whether the first player wins, looses or ties.
#
# Arguments:
#     $a0 : address of configuration in memory
#   0($a0): eca       (1 word)
#   4($a0): tape      (1 word)
#   8($a0): tape_len  (1 byte)
#   9($a0): rule      (1 byte)
#  10($a0): skip      (1 byte)
#  11($a0): column    (1 byte)
#
# Returns: Nothing, only print either character 'W', 'L', or 'T' to stdout

play_game_once:
  addiu $sp $sp -8	#Platz für zwei int im Stack
  sw $ra 0($sp)		#Speichere Return Address
  jal gen_byte
  sw $v0 4($sp)		#Speichere den ersten generierten Byte im Stack
  jal gen_byte
  lw $a1 4($sp)		#Speichert den ersten generierten Byte in $a1
  move $a2 $v0		#Speichert den zweiten generierten Byte in $a2
  li $t0 1
  beqz $a1 stone
  beq $t0 $a1 paper
  beqz $a2 lost
  beq $a2 $t0 won

tied:
  li $a0 'T'
  
end:
  li $v0 11
  syscall		#Gibt das Ergebnis aus
  lw $ra 0($sp)		#Stellt die Return Address wieder her
  addiu $sp $sp 8	#Gibt den Stack wieder frei

#Zu Testzwecken
#  
#  li $v0 1
#  move $a0 $a1
#  syscall		#Gibt dem ersten generierten Byte aus
#  li $v0 1
#  move $a0 $a2
#  syscall		#Gibt dem zweiten generierten Byte aus
#  li $v0 10
#  syscall		#Beendet das Programm
#  
  jr $ra

won:
  li $a0 'W'
  b end

lost:
  li $a0 'L'
  b end
  
stone:
  beqz $a2 tied
  beq $a2 $t0 lost
  b won
  
paper:
  beqz $a2 won
  beq $a2 $t0 tied
  b lost
