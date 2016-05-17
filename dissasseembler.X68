* System equates
 
stack            EQU      $A000
example          EQU      %0000000001100001    * I made up bits 0 to 11      
shift            EQU     12                   * Shift 12 bits 
 
* Program starts here
 
                 ORG     $400
start          LEA     stack,SP        *Load the SP
                 LEA     jmp_table1,A0    *Index into the table
                 CLR.L   D2              *Zero it
                 MOVE.W  #example,D2     *We'll play with it here
                 MOVE.B  #shift,D3       *Shift 12 bits to the right  
                 LSR.W   D3,D2           *Move the bits
*
* Consider the next instruction. Why do we have to multiply the index 
* by 6? How many bytes does a single jump table entry require? 
 
               MULU        #6,D2       *Form offset     
               JSR          0(A0,D2)   *Jump indirect with index
                    
jmp_table1      JMP         code0000
               JMP         code0001
               JMP         code0010
               JMP         code0011
               JMP         code0100
               JMP         code0101
               JMP         code0110
               JMP         code0111
               JMP         code1000
               JMP         code1001
               JMP         code1010
               JMP         code1011
               JMP         code1100
               JMP         code1101
               JMP         code1110
               JMP         code1111
        
 
*The following subroutines will get filled in as you decode the instructions . For *now, just exit gracefully.
 
;DECODE LAYER 1 start
;first 4 bit decoding layer 1
;ORI,BCLR
code0000    CLR.L   D2              *Zero it
            MOVE.W  #example,D2     *We'll play with it here
            MOVE.B  #4,D3       *Shift 4 bits to the left to get rid of the first 4 bits we already decoded  
            LSL.W   D3,D2           *Move the bits
            MOVE.B  #12,D3      *shift 12 bits to the right to pick out the second 4 bits
            LSR.W   D3,D2           *Move the bits            
            MULU    #6,D2       *index into the table
            LEA     jmp_table0000,A0
            JSR     0(A0,D2)
;MOVE.B
code0001       STOP        #$2700
;MOVE.L, MOVEA.L
code0010       STOP        #$2700
;MOVE.W,MOVEA.W
code0011       STOP        #$2700
;NEG,MOVEM,LEA
code0100    CLR.L   D2              *Zero it
            MOVE.W  #example,D2     *We'll play with it here
            MOVE.B  #4,D3       *Shift 4 bits to the left to get rid of the first 4 bits we already decoded  
            LSL.W   D3,D2           *Move the bits
            MOVE.B  #12,D3      *shift 12 bits to the right to pick out the second 4 bits
            LSR.W   D3,D2           *Move the bits            
            MULU    #6,D2       *index into the table
            LEA     jmp_table0100,A0
            JSR     0(A0,D2)
*
       
    STOP        #$2700
code0101       STOP        #$2700
;Bcc
code0110       STOP        #$2700
code0111       STOP        #$2700
;DIVS.W ,OR
code1000       STOP        #$2700
;SUB
code1001       STOP        #$2700
code1010       STOP        #$2700
;EOR,CMP
code1011     BRA        code1011
;MULS
code1100       STOP        #$2700
;ADD,ADDX,ADDA
code1101    CLR.L   D2              *Zero it
            MOVE.W  #example,D2     *We'll play with it here
            MOVE.B  #4,D3       *Shift 4 bits to the left to get rid of the first 4 bits we already decoded  
            LSL.W   D3,D2           *Move the bits
            MOVE.B  #12,D3      *shift 12 bits to the right to pick out the second 4 bits
            LSR.W   D3,D2           *Move the bits            
            MULU    #6,D2       *index into the table
            LEA     jmp_table1101,A0
            JSR     0(A0,D2)
;ASd,LSd,ROd
code1110       STOP        #$2700
code1111       STOP        #$2700
 
 
;2ND LAYER
;2ndlayer jmp table for opcodes with the first 4 bits = 0000
jmp_table0000  JMP         code00000000
               JMP         code00000001
               JMP         code00000010
               JMP         code00000011
               JMP         code00000100
               JMP         code00000101
               JMP         code00000110
               JMP         code00000111
               JMP         code00001000
               JMP         code00001001
               JMP         code00001010
               JMP         code00001011
               JMP         code00001100
               JMP         code00001101
               JMP         code00001110
               JMP         code00001111

;first 8 bit decoding for first four bits starting with 0000
;ORI if the size field is 00 or 01 or 10
code00000000       STOP        #$2700
;BCLR   Dn = 000
code00000001       STOP        #$2700
code00000010       STOP        #$2700
;BCLR   DN = 001
code00000011       STOP        #$2700
code00000100       STOP        #$2700
;BCLR   DN = 010
code00000101       STOP        #$2700
code00000110       STOP        #$2700
;BCLR   DN = 011
code00000111       STOP        #$2700
code00001000       STOP        #$2700
;BCLR   DN = 100
code00001001       STOP        #$2700
code00001010       STOP        #$2700
;BCLR   DN = 101
code00001011     BRA        code1011
code00001100       STOP        #$2700
;BCLR   DN = 110
code00001101       STOP        #$2700
code00001110       STOP        #$2700
;BCLR   DN = 111
code00001111       STOP        #$2700
               
;2ndlayer jmp table for opcodes with the first 4 bits = 0100
jmp_table0100  JMP         code01000000
               JMP         code01000001
               JMP         code01000010
               JMP         code01000011
               JMP         code01000100
               JMP         code01000101
               JMP         code01000110
               JMP         code01000111
               JMP         code01001000
               JMP         code01001001
               JMP         code01001010
               JMP         code01001011
               JMP         code01001100
               JMP         code01001101
               JMP         code01001110
               JMP         code01001111

;first 8 bit decoding for first four bits starting with 0100
code01000000       STOP        #$2700
code01000001       STOP        #$2700
code01000010       STOP        #$2700
code01000011       STOP        #$2700
;NEG    CONFIRMED
code01000100       STOP        #$2700
code01000101       STOP        #$2700
code01000110       STOP        #$2700
code01000111       STOP        #$2700
;MOVEM  register to memory
code01001000       STOP        #$2700
code01001001       STOP        #$2700
code01001010       STOP        #$2700
code01001011     BRA        code1011
;MOVE M memory to register
code01001100       STOP        #$2700
code01001101       STOP        #$2700
code01001110       STOP        #$2700
code01001111       STOP        #$2700

;2ndlayer jmp table for opcodes with the first 4 bits = 1101
jmp_table1101  JMP         code11010000
               JMP         code11010001
               JMP         code11010010
               JMP         code11010011
               JMP         code11010100
               JMP         code11010101
               JMP         code11010110
               JMP         code11010111
               JMP         code11011000
               JMP         code11011001
               JMP         code11011010
               JMP         code11011011
               JMP         code11011100
               JMP         code11011101
               JMP         code11011110
               JMP         code11011111

;first 8 bit decoding for first four bits starting with 1101
code11010000       STOP        #$2700
code11010001       STOP        #$2700
code11010010       STOP        #$2700
code11010011       STOP        #$2700
code11010100       STOP        #$2700
code11010101       STOP        #$2700
code11010110       STOP        #$2700
code11010111       STOP        #$2700
code11011000       STOP        #$2700
code11011001       STOP        #$2700
code11011010       STOP        #$2700
code11011011     BRA        code1011
code11011100       STOP        #$2700
code11011101       STOP        #$2700
code11011110       STOP        #$2700
code11011111       STOP        #$2700
               END   $400 


*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
