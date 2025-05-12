.data
newline: .asciiz "\n"

.text
li $v0 40
syscall
gen_bit:
  li $v0 41		#Generiert 32-bit signed int
  syscall
  sll $a0 $a0 31	#Verschiebt den generierten bitstring um 31 nach links
  srl $a0 $a0 31	#Verschiebt den generierten bitstring um 31 nach links (unsigned)
  move $v0 $a0		#Kopiert den generierten int nach $v0
  b gen_bit
