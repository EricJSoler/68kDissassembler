 * System equates
 
stack            EQU      $A000
inst             EQU      $5000
operand          EQU      $6000
example          EQU      %1100010111010000
nextword         EQU      1 
shift            EQU     12                   * Shift 12 bits 
 
* Program starts here
 
                 ORG     $400
start            LEA     stack,SP        *Load the SP
                 LEA    inst,A6
                 LEA     jmp_table1,A0    *Index into the table
                 CLR.L   D2              *Zero it
                 MOVE.W  #example,D2     *We'll play with it here
                 MOVE.B  #shift,D3       *Shift 12 bits to the right  
                 LSR.W   D3,D2           *Move the bits
                 MULU        #6,D2       *Form offset     
                 JSR          0(A0,D2)   *Jump indirect with index
finishedoneinst  STOP    #$2700
                    
                    
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
 
 
;DECODE LAYER 1 start
;first 4 bit decoding layer 1
;ORI,BCLR
code0000        CLR.L   D2              *Zero it
                MOVE.W  #example,D2     *We'll play with it here
                MOVE.B  #4,D3       *Shift 4 bits to the left to get rid of the first 4 bits we already decoded  
                LSL.W   D3,D2           *Move the bits
                MOVE.B  #12,D3      *shift 12 bits to the right to pick out the second 4 bits
                LSR.W   D3,D2           *Move the bits            
                MULU    #6,D2       *index into the table
                LEA     jmp_table0000,A0
                JSR     0(A0,D2)
                JMP finishedoneinst
;MOVE.B; MOVEA.B
code0001        BSR decodeMOVEBMOVEA
                JMP finishedoneinst
;MOVE.L, MOVEA.L
code0010        STOP        #$2700
;MOVE.W,MOVEA.W
code0011        STOP        #$2700
;NEG,MOVEM,LEA
code0100        CLR.L   D2              *Zero it
                MOVE.W  #example,D2     *We'll play with it here
                MOVE.B  #4,D3       *Shift 4 bits to the left to get rid of the first 4 bits we already decoded  
                LSL.W   D3,D2           *Move the bits
                MOVE.B  #12,D3      *shift 12 bits to the right to pick out the second 4 bits
                LSR.W   D3,D2           *Move the bits            
                MULU    #6,D2       *index into the table
                LEA     jmp_table0100,A0
                JSR     0(A0,D2)
                JMP finishedoneinst
code0101        STOP        #$2700
;Bcc
code0110        STOP        #$2700
code0111        STOP        #$2700
;DIVS.W ,OR
code1000        STOP        #$2700
;SUB
code1001        STOP        #$2700
code1010        STOP        #$2700
;EOR,CMP
code1011        BRA        code1011
;MULS
code1100        BSR decodeMULS
                JMP finishedoneinst
;ADD,ADDX,ADDA
code1101    
                MOVE.B  #65,(A6)+
                MOVE.B  #68,(A6)+
                MOVE.B  #68,(A6)+
                CLR.L   D2              *Zero it
                MOVE.W  #example,D2     *We'll play with it here
            ;check the 9th and 10th bit to see if its ADDA or just ADD
                MOVE.B  #8,D3       *Shift 8 bits to the left to isolate 
            ;check the 9th and 10th bit to see if its ADDA or just ADD
                LSL.W   D3,D2           *Move the bits
                MOVE.B  #14,D3      *shift 14 bits to the right to pick out the 9th and 10th bits
                LSR.W   D3,D2           *Move the bits            
                CMP #%11,D2 ; if they are equal then we know that it is an ADDa
                BEQ choseAdda
                BSR decodeADDx
                BRA choseADDx
choseAddA       BSR decodeADDA
choseADDx       NOP            
                RTS
;ASd,LSd,ROd
code1110        STOP        #$2700
code1111        STOP        #$2700


;decode subroutine for MULS it must be muls.w
decodeMULS          NOP
                    ;check if the hardcoded bits from the instrsuction are set correctly
                    CLR.L   D2
                    MOVE.W  #example,D2
                    MOVE.B  #7,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    CMP.B   #%111,D2
                    BNE     mulswasdata
                    ;check to make sure we arent usnig An addressing mode because thats the only invalid one for the soource
                    MOVE.W  #example,D2
                    MOVE.B  #10,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    CMP.B   #%001,D2    ;check the addressing mode
                    BEQ     mulswasdata
                    
                    ;spell out instruction in memory
                    MOVE.B  #77,(A6)+
                    MOVE.B  #85,(A6)+
                    MOVE.B  #76,(A6)+
                    MOVE.B  #83,(A6)+
                    MOVE.B  #46,(A6)+
                    MOVE.B  #87,(A6)+
                    MOVE.B  #32,(A6)+

                    ;decode source address and mode
                    MOVE.W  #example,D2                    
                    MOVE.B  #10,D3
                    LSL.W   D3,D2
                    MOVE.B  #10,D3
                    LSR.W   D3,D2
                    MOVE.B  D2,D6
                    BSR decodeModeAndAddress
                    CMP.B   #0,D6
                    BEQ mulswasdata
                    ;write destination data register to memory
                    MOVE.W #example,D2
                    MOVE.B  #4,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    MOVE.B  #44,(A6)+
                    MOVE.B  #68,(A6)+
                    ADD.B   #48,D2
                    MOVE.B  D2,(A6)+
                    
                    BRA mulsdone

mulswasdata         LEA data,A6
mulsdone            MOVE.B  #0,(A6)+
                    MOVE.L  #14,D0
                    LEA inst,A1
                    TRAP    #15               
                    RTS

;decode subrouting for MOVE.B and MOVEA.B
decodeMOVEBMOVEA    NOP
            ;write move
                    MOVE.B  #77,(A6)+
                    MOVE.B  #79,(A6)+
                    MOVE.B  #86,(A6)+
                    MOVE.B  #69,(A6)+
            ;check if it is MOVEA
                    CLR.L   D2
                    MOVE.W  #example,D2
                    MOVE.B  #7,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    CMP.W   D3,D2
                    BNE     notMOVEAB
                    MOVE.B  #65,(A6)+

notMOVEAB           MOVE.B  #46,(A6)+
                    MOVE.B  #66,(A6)+
                    MOVE.B  #32,(A6)+            
       
            ;decode source
                    CLR.L   D2
                    MOVE.W  #example,D2
                    MOVE.B  #10,D3
                    LSL.W   D3,D2
                    LSR.W   D3,D2
                    MOVE.B  D2,D6
                    BSR decodeModeAndAddress
            ;check mode
                    CMP.B   #0,D6
                    BEQ MOVEBWasData
                    MOVE.B  #44,(A6)+
;flip the destination orginization of Xn and M so we can use our function
                    CLR.L D2
                    MOVE.W  #example,D2
                    MOVE.B  #4,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    MOVE.W  D2,D6
                    MOVE.W  #example,D2
                    MOVE.B  #7,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    MOVE.B  #3,D3
                    LSL.W   D3,D2
                    OR.W    D2,D6
                    BSR decodeModeAndAddress
                    ;check mode
                    CMP.B   #0,D6
                    BEQ MOVEBWasData

                    BRA MOVEBDone
                    
MOVEBWasData        LEA data,A6
MOVEBDone           MOVE.B  #0,(A6)+
                    MOVE.L  #14,D0
                    LEA inst,A1
                    TRAP    #15               
                    RTS
                    
                    
;decode subroutine for ADDx.... 
decodeADDx          NOP
                    CLR.L   D2
                    MOVE.W  #example,D2
        ;Decode the size
                    MOVE.B  #8,D3
                    LSL.W   D3,D2
                    MOVE.B  #14,D3
                    LSR.W   D3,D2
                    MOVE.W  D2,D3
    ;check if decoded valid size
                    SUB.B   #%10,D2
                    BGT     ADDwasData
            ;write the .x to the instruction depending on size
                    MOVE.B  #46,(A6)+
                    MOVE.B  D3,D2
                    BSR addlpsize ; jump to the sub routine that will add the .x to the isntruction
     ;assuming we decoded a valid size we need to check if the addressing mode is also valid for the given size
            
     ;check which direction we are moving the data 
                    MOVE.W  #example,D2
                    MOVE.B  #7,D3
                    LSL.W   D3,D2
                    MOVE.B  #15,D3
                    LSR.W   D3,D2
                    BEQ     addeatodn
            
            
                    BRA AddeaDone
Addeatodn           MOVE.W  #example,D2
                    MOVE.B  #12,D3
                    LSL.W   D3,D2
                    MOVE.B  #12,D3
                    LSR.W   D3,D2
                    MOVE.B  D2,D6
                    BSR decodeModeAndAddress
                    ;check mode
                    CMP.B   #0,D6
                    BEQ ADDwasData
                    MOVE.B  #44,(A6)+ ;add comma
                    ;decode Dn and add it to the isntruction
                    MOVE.W  #example,D2
                    MOVE.B  #4,D3
                    LSL.W   D3,D2
                    MOVE.B  #13,D3
                    LSR.W   D3,D2
                    MOVE.B  #68,(A6)+
                    ADD.B   #48,D2
                    MOVE.B  D2,(A6)+
            
AddeaDone           NOP

                    BRA Adddone
ADDwasData          LEA data,A6
AddDone             MOVE.B  #0,(A6)+
                    MOVE.L  #14,D0
                    LEA inst,A1
                    TRAP    #15           
                    RTS
    
;Decode subroutine for ADDA
decodeADDA          MOVE.B  #65,(A6)+
                    CLR.L   D2
                    MOVE.W  #example,D2
    
    ;decode the size in the 8th bit
                    MOVE.B #7,D3
                    LSL.W   D3,D2
                    MOVE.B  #15,D3
                    LSR.W   D3,D2   *isolate the size bit
                    BSR     addmedpsize
                    MOVE.B #32,(A6)+ ;addspace after size
    ;decode the destination and its mode
                    MOVE.W  #example,D2
                    MOVE.B  #10,D3
                    LSL.W   D3,D2
                    MOVE.B  #10,D3
                    LSR.W   D3,D2
                    MOVE.B  D2,D6
                    BSR decodeModeAndAddress
    ;check mode
                    CMP.B   #0,D6
                    BEQ addAwasData
                    MOVE.B  #44,(A6)+ ;add comma
    ;check mode
                    CMP.B   #0,D6
                    BEQ addAwasData    
    ;Decode the destination address register 
                    MOVE.W  #example,D2
                    MOVE.B  #4,D3
                    LSL.W   D3,D2 ;isolate the address register bits
                    MOVE.B  #13,D3
                    LSR.W   D3,D2   ;move the address register bits into their column
                    ADD.B   #48,D2  ;get the address register   in ascii
                    MOVE.B  #65,(A6)+
                    MOVE.B  D2,(A6)+
  
                    BRA addAdone
addAwasData         LEA data,A6
addAdone            MOVE.B  #0,(A6)+
                    MOVE.L  #14,D0
                    LEA inst,A1
                    TRAP    #15           
                    RTS           

 
;2ND LAYER
;2ndlayer jmp table for opcodes with the first 4 bits = 0000
jmp_table0000       JMP         code00000000
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
;ORI
code00000000       
    ;Write ORI into current instruction string
                    MOVE.B  #79,(A6)+
                    MOVE.B  #82,(A6)+
                    MOVE.B  #73,(A6)+
    
     ;decode size
                    CLR.L   D2              *Zero it
                    MOVE.W  #example,D2     *We'll play with it here
                    MOVE.B  #8,D3       *Shift 8 bits to the left to get rid of the first 8 bits we already decoded  
                    LSL.W   D3,D2           *Move the bits
                    MOVE.B  #14,D3      *shift 14 bits to the right to pick out the next 2 after the 8 bits already decoded
                    LSR.W   D3,D2           *Move the bits            
                    MOVE.B  D2,D3 ;make a copy of D2 in D3
            ;check if decoded valid size
                    SUB.B   #%10,D2
                    BGT     oriwasData
            ;write the .x to the instruction depending on size
                    MOVE.B  #46,(A6)+
                    MOVE.B  D3,D2
                    BSR addlpsize ; jump to the sub routine that will add the .x to the isntruction

            ;if valid size and valid size != Long the next word contains the immediate value for the source
                    SUB.B   #%01,D2 ;check if we are gonna pull the next word or next long
                    BGT     oritakelong
                    BRA     oritakeword                    
oritakelong         NOP ;take next long and add it to the string as the source
                    BRA oritookim
oritakeword         NOP ;take next word and add it to the string as the source
oritookim           NOP ;branch to skip taking a word           
            ;decode mode and load this operands string
                    MOVE.W  #example,D2     *We'll play with it here
                    MOVE.B  #10,D3       *Shift 10 bits to the left to get rid of the first 10 bits we already decoded  
                    LSL.W   D3,D2           *Move the bits
                    MOVE.B  #10,D3      *shift 10 bits to the right to pick out the next 6 bits for the mode and destination
                    LSR.W   D3,D2           *Move the bits            

            ;the sub rountine in the mode table will build a string and store it in A5 when passed 6 bits int D6that is (M)(XN) will set D6 to 1 if valid and D6 to 0 if invalid
                    MOVE.B D2,D6
                    BSR decodeModeAndAddress
            ;check mode
                    CMP.B   #0,D6
                    BEQ oriwasData
            
            ;and xn
            ;if mode is immediate and size != long the next word contains the immediate address for the destination
                    BRA oridone
oriwasData          LEA data,A6
oridone             MOVE.B  #0,(A6)+
                    MOVE.L  #14,D0
                    LEA inst,A1
                    TRAP    #15           
                    RTS
            
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
code00001011        BRA        code1011
code00001100        STOP        #$2700
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


;Mode Decoding expects to be indexed into from decodeModeAndAddress subroutine and D6 = to the (mode)(xn)
jmp_tableMode  JMP         mode000
               JMP         mode001
               JMP         mode010
               JMP         mode011
               JMP         mode100
               JMP         mode101
               JMP         mode110
               JMP         mode111                
;Mode Routines 
;Data register
mode000 
    AND.B   #%00000111,D6
    MOVE.B  #68,(A6)+
    ADD.B   #48,D6
    MOVE.B  D6,(A6)+
    MOVE.B  #1,D6
    RTS
;address register
mode001
    AND.B   #%00000111,D6
    MOVE.B  #65,(A6)+
    ADD.B   #48,D6
    MOVE.B  D6,(A6)+
    MOVE.B  #1,D6
    RTS
; address (An)
mode010
    AND.B   #%00000111,D6
    MOVE.B  #40,(A6)+
    MOVE.B  #65,(A6)+
    ADD.B   #48,D6
    MOVE.B  D6,(A6)+
    MOVE.B  #41,(A6)+
    MOVE.B  #1,D6
    RTS

; Address with postincrement (An)+
mode011 
    AND.B   #%00000111,D6
    MOVE.B  #40,(A6)+
    MOVE.B  #65,(A6)+
    ADD.B   #48,D6
    MOVE.B  D6,(A6)+
    MOVE.B  #41,(A6)+
    MOVE.B  #43,(A6)+
    MOVE.B  #1,D6
    RTS

;Address with predecrement -(An)
mode100
    AND.B   #%00000111,D6
    MOVE.B  #45,(A6)+
    MOVE.B  #40,(A6)+
    MOVE.B  #65,(A6)+
    ADD.B   #48,D6
    MOVE.B  D6,(A6)+
    MOVE.B  #41,(A6)+
    MOVE.B  #1,D6
    
    RTS
;Address with displaceemnt (d16,An)
mode101 STOP        #$2700
;Address with index (d8,An,Xn)
mode110 STOP        #$2700
; the rest
mode111 STOP        #$2700

jmp_tablem111xn   JMP         reg000
               JMP         reg001
               JMP         reg010
               JMP         reg011
               JMP         reg100
               JMP         reg101
               JMP         reg110
               JMP         reg111                
;absolute short xxx.W
reg000 STOP        #$2700
;absolute long xxx.L
reg001 STOP        #$2700
;program counter with displacement
reg010 STOP        #$2700
;program couter with index
reg011 STOP        #$2700
;immediate
reg100 STOP        #$2700
;invalid
reg101 STOP        #$2700
;invalid
reg110 STOP        #$2700
;invalid
reg111 STOP        #$2700
               
;requires d6 to cointain the 6 bits that will be used to do the addressing mode in the order of (mode)(xn) and store the resulting operand string in A5 sets d6 to 1 if valid and d6 to 0 if invalid
decodeModeAndAddress    NOP
              CLR.L     D2
              MOVE.B    D6,D2
              LSR.W     #3,D2 *shift d2 over so its upper most bits are the addressing mode
              MULU    #6,D2       *index into the table
              LEA     jmp_tableMode,A0
              JSR     0(A0,D2)    
              RTS
;requires d2 to conatin the 2 bits for the size will add the .x to the instruction string  doesnt make changes to d2
addlpsize   NOP
            CMP.B   #%01,D2
            BEQ     lpW
            CMP.B   #%10,D2
            BEQ lpL
            MOVE.B  #66,(A6)+
            BRA lpDone
lpW        MOVE.B  #87,(A6)+
            BRA lpDone
lpL        MOVE.B  #76,(A6)+
lpDone  MOVE.B  #32,(A6)+
    RTS

;requires d2 to contain the 1 bit that will be the dark purple size will not make changes to d2 will add the .x to the instruction string in A6
addmedpsize NOP              
    MOVE.B  #46,(A6)+
    CMP #0,D2
    BEQ dpsizew
    MOVE.B  #76,(A6)+
    BRA dpsizedone
dpsizeW MOVE.B  #87,(A6)+
dpsizedone RTS


byte    DC.B    '.B',0
DR      DC.B    'DR',0
AR      DC.B    'AR',0
data    DC.B    'DATA',0
               END   $400 







*~Font name~Courier New~
*~Font size~10~
*~Tab type~1~
*~Tab size~4~
