;*********************************
; FILE TABLE.ASM
;*********************************
;
;        DISASSEMBLER128
;    SYMBOLIC DISASSEMBLER
;       BY DENTON MARLOWE
;
;  (C)1986 BY DENTON MARLOWE
;
;*********************************
;       PRINT MNEMONIC
;
; OPCODE IN A
;
; BUG ILLEGAL OPCODE WOULD PRINT OUT AS
;
; ZZZZ XX                 ...  .BYTE $XX ;??? ILLEGAL OPCODE
; WHERE THE "..." WERE THREE NULLS
; BECAUSE ILLEGAL OPCODE MNEMONIC IS CODES AS 0,0,0
;
;*********************************
MNEMON LDX #3       ;3 CHARACTERS
       STX TEMP     ;COUNTER
       TAX          ;CODE IS INDEX
       LDA MCODES,X ;GET OFFSET
       TAX          ;INDEX OFFSET
MNLOOP LDA MNAMES,X ;GET CHARACTER
;BEGIN REV 2017-0
       BEQ ILLOP    ;ILLEGAL OPCODE MNEMONIC CHAR IS A NULL
;END REV 2017-0
       STX SAVX     ;SAVE INDEX
       JSR PCHAR    ;PRINT CHAR
       LDX SAVX     ;GET INDEX
;BEGIN REV 2017-1
ILLOP = *
;END REV 2017-0
       INX          ;NEXT CHAR
       DEC TEMP     ;DEC COUNT
       BNE MNLOOP   ;LOOP TILL 0
       RTS          ;RETURN
;*********************************
;        PRINT OPERAND
;*********************************
PRTASS PHA ;STACK INDEX
 JSR PRTDAT ;PRINT LINE DATA
 PLA ;PULL INDEX
 TAY ;SAVE INDEX
 LDA #<SUBP
 LDX #>SUBP
 JMP GETOPE ;LOOK UP ROUTINE
;*********************************
OPERN1 TAY ;SAVE INDEX
 LDA #<SUBS1
 LDX #>SUBS1
 JMP GETOPE ;LOOK UP ROUTINE
;*********************************
OPERND TAY ;SAVE INDEX
 LDA #<SUBS
 LDX #>SUBS
;*********************************
; LOOK UP AND JMP TO ROUTINE
;*********************************
GETOPE STA ZEROUR ;LOW TABLE
 STX ZEROUR+1 ;HIGH TABLE
 LDA MODES,Y ;GET OFFSET
 TAY ;INDEX OFFSET
 LDA (ZEROUR),Y ;GET LOW BYTE
 STA ADRS ;STORE
 INY ;INC INDEX
 LDA (ZEROUR),Y ;GET HIGH BYTE
 STA ADRS+1 ;STORE
 JMP (ADRS) ;INDIRECT JMP
;*********************************
; TABLE OF ADDRESSING MODE SUBS
;*********************************
; MACHINE LANGUAGE ROUTINES
;*********************************
SUBP = *     ; MODES
.WORD PRTONE ; 0  $00
.WORD PRTONE ; 2  $02
.WORD PRTTWO ; 4  $04
.WORD PRTTWO ; 6  $06
.WORD PRTTWO ; 8  $08
.WORD PRTTWO ; 10 $0A
.WORD PRTTHE ; 12 $0C
.WORD PRTTHE ; 14 $0E
.WORD PRTTHE ; 16 $10
.WORD PRTONE ; 18 $12
.WORD PRTTWO ; 20 $14
.WORD PRTTWO ; 22 $16
.WORD PRTTWO ; 24 $18
.WORD PRTTHE ; 26 $1A
;*********************************
; CODE ANALYSIS ROUTINES
;*********************************
SUBS1 = *    ; MODES
.WORD IMPONE ; 0  $00
.WORD IMPONE ; 2  $02
.WORD IMMEDT ; 4  $04
.WORD ONEBYT ; 6  $06
.WORD ONEBYT ; 8  $08
.WORD ONEBYT ; 10 $0A
.WORD TWOBYT ; 12 $0C
.WORD TWOBYT ; 14 $0E
.WORD TWOBYT ; 16 $10
.WORD IMPONE ; 18 $12
.WORD RELATV ; 20 $14
.WORD ONEBYT ; 22 $16
.WORD ONEBYT ; 24 $18
.WORD TWOBYT ; 26 $1A
;*********************************
; FINAL PASS ADDRESSING MODES
;*********************************
SUBS  = *    ; MODES
.WORD ILLEGL ; 0  $00
.WORD ACC    ; 2  $02
.WORD IMMEDT ; 4  $04
.WORD ZEROPG ; 6  $06
.WORD ZEROX  ; 8  $08
.WORD ZEROY  ; 10 $0A
.WORD ABSLUT ; 12 $0C
.WORD ABSX   ; 14 $0E
.WORD ABSY   ; 16 $10
.WORD IMPLID ; 18 $12
.WORD RELATV ; 20 $14
.WORD INDX   ; 22 $16
.WORD INDY   ; 24 $18
.WORD INDRCT ; 26 $1A
;*********************************
; LIST OF MNEMONICS
;*********************************
MNAMES = *  ; MCODES
.BYTE 0,0,0 ; 0   $00
.TEXT 'ADC' ; 3   $03
.TEXT 'AND' ; 6   $06
.TEXT 'ASL' ; 9   $09
.TEXT 'BCC' ; 12  $0C
.TEXT 'BCS' ; 15  $0F
.TEXT 'BEQ' ; 18  $12
.TEXT 'BIT' ; 21  $15
.TEXT 'BMI' ; 24  $18
.TEXT 'BNE' ; 27  $1B
.TEXT 'BPL' ; 30  $1E
.TEXT 'BRK' ; 33  $21
.TEXT 'BVC' ; 36  $24
.TEXT 'BVS' ; 39  $27
.TEXT 'CLC' ; 42  $2A
.TEXT 'CLD' ; 45  $2D
.TEXT 'CLI' ; 48  $30
.TEXT 'CLV' ; 51  $33
.TEXT 'CMP' ; 54  $36
.TEXT 'CPX' ; 57  $39
.TEXT 'CPY' ; 60  $3C
.TEXT 'DEC' ; 63  $3F
.TEXT 'DEX' ; 66  $42
.TEXT 'DEY' ; 69  $45
.TEXT 'EOR' ; 72  $48
.TEXT 'INC' ; 75  $4B
.TEXT 'INX' ; 78  $4E
.TEXT 'INY' ; 81  $51
.TEXT 'JMP' ; 84  $54
.TEXT 'JSR' ; 87  $57
.TEXT 'LDA' ; 90  $5A
.TEXT 'LDX' ; 93  $5D
.TEXT 'LDY' ; 96  $60
.TEXT 'LSR' ; 99  $63
.TEXT 'NOP' ; 102 $66
.TEXT 'ORA' ; 105 $69
.TEXT 'PHA' ; 108 $6C
.TEXT 'PHP' ; 111 $6F
.TEXT 'PLA' ; 114 $72
.TEXT 'PLP' ; 117 $75
.TEXT 'ROL' ; 120 $78
.TEXT 'ROR' ; 123 $7B
.TEXT 'RTI' ; 126 $7E
.TEXT 'RTS' ; 129 $81
.TEXT 'SBC' ; 132 $84
.TEXT 'SEC' ; 135 $87
.TEXT 'SED' ; 138 $8A
.TEXT 'SEI' ; 141 $8D
.TEXT 'STA' ; 144 $90
.TEXT 'STX' ; 147 $93
.TEXT 'STY' ; 150 $96
.TEXT 'TAX' ; 153 $99
.TEXT 'TAY' ; 156 $9C
.TEXT 'TSX' ; 159 $9F
.TEXT 'TXA' ; 162 $A2
.TEXT 'TXS' ; 165 $A5
.TEXT 'TYA' ; 168 $A8
;*********************************
; QUASI-OPCODES
;*********************************
.TEXT 'ASO' ; 171 $AB
.TEXT 'RLA' ; 174 $AE
.TEXT 'LSE' ; 177 $B1
.TEXT 'RRA' ; 180 $B4
.TEXT 'AXS' ; 183 $B7
.TEXT 'LAX' ; 186 $BA
.TEXT 'DCM' ; 189 $BD
.TEXT 'INS' ; 192 $C0
.TEXT 'ALR' ; 195 $C3
.TEXT 'ARR' ; 198 $C6
.TEXT 'OAL' ; 201 $C9
.TEXT 'SAX' ; 204 $CC
.TEXT 'NOP' ; 207 $CF
.TEXT 'SKB' ; 210 $D2
.TEXT 'SKW' ; 213 $D5
;*********************************
; TABLE OF MNEMONIC CODES
;*********************************
;
;A MNEMONIC'S CODE IS ITS OFFSET
;    INTO MNAMES, THE LIST OF
;         MNEONIC NAMES.
;
;*********************************
MCODES = *
;     0X  1X  2X  3X  4X  5X  6X  7X
; 0X  BRK ORA KIL SLO NOP ORA ASL SLO
.BYTE $21,$69,$00,$00,$00,$69,$09,$00
;     8X  9X  AX  BX  CX  DX  EX  FX
     ;PHP ORA ASL ANC NOP ORA ASL SLO
.BYTE $6F,$69,$09,$00,$00,$69,$09,$00
; 1X  BPL ORA KIL SLO NOP ORA ASL SLO
.BYTE $1E,$69,$00,$00,$00,$69,$09,$00
     ;CLC ORA NOP SLO NOP ORA ASL SLO
.BYTE $2A,$69,$00,$00,$00,$69,$09,$00
; 2X  JSR AND KIL RLA BIT AND ROL RLA
.BYTE $57,$06,$00,$00,$15,$06,$78,$00
     ;PLP ABD ROL ANC BIT AND ROL RLA
.BYTE $75,$06,$78,$00,$15,$06,$78,$00
; 3X  BMI AND KIL RLA NOP AND ROL RLA
.BYTE $18,$06,$00,$00,$00,$06,$78,$00
;     SEC AND NOP RLA NOP AND ROL RLA
.BYTE $87,$06,$00,$00,$00,$06,$78,$00
; 4X  RTI EOR KIL SRE NOP EOR LSR SRE
.BYTE $7E,$48,$00,$00,$00,$48,$63,$00
;     PHA EOR LSR ALR JMP EOR LSR SRE
.BYTE $6C,$48,$63,$00,$54,$48,$63,$00
; 5X  BVC EOR KIL SRE NOP EOR LSR SRE
.BYTE $24,$48,$00,$00,$00,$48,$63,$00
;     CLI EOR NOP SRE NOP EOR LSR SRE
.BYTE $30,$48,$00,$00,$00,$48,$63,$00
; 6X  RTS ADC KIL RRA NOP ADC ROR RRA
.BYTE $81,$03,$00,$00,$00,$03,$7B,$00
;     PLA ADC ROR ARR JMP ADC ROR RRA
.BYTE $72,$03,$7B,$00,$54,$03,$7B,$00
; 7X  BVS ADC KIL RRA NOP ADC ROR RRA
.BYTE $27,$03,$00,$00,$00,$03,$7B,$00
;     SEI ADC NOP RRA NOP ADC ROR RRA
.BYTE $8D,$03,$00,$00,$00,$03,$7B,$00
; 8X  NOP STA NOP SAX STY STA STX SAX
.BYTE $00,$90,$00,$00,$96,$90,$93,$00
;     DEY NOP TXA XXA STY STA STX SAX
.BYTE $45,$00,$A2,$00,$96,$90,$93,$00
; 9X  BCC STA KIL AHX STY STA STX SAX 
.BYTE $0C,$90,$00,$00,$96,$90,$93,$00
;     TYA STA TXS TAS SHY STA SHX AHX
.BYTE $A8,$90,$A5,$00,$00,$90,$00,$00
; AX  LDY LDA LDX LAX LDY LDA LDX LAX
.BYTE $60,$5A,$5D,$00,$60,$5A,$5D,$00
;     TAY LDA TAX LAX LDY LDA LDX LAX
.BYTE $9C,$5A,$99,$00,$60,$5A,$5D,$00
; BX  BCS LDA KIL LAX LDY LDA LDX LAX
.BYTE $0F,$5A,$00,$00,$60,$5A,$5D,$00
;     CLV LDA TSX LAS LDY LDA LDX LAX
.BYTE $33,$5A,$9F,$00,$60,$5A,$5D,$00
; CX  CPY CMP NOP DCP CPY CMP DEC DCP
.BYTE $3C,$36,$00,$00,$3C,$36,$3F,$00
;     INY CMP DEX AXS CPY CMP DEC DCP
.BYTE $51,$36,$42,$00,$3C,$36,$3F,$00
; DX  BNE CMP KIL DCP NOP CMP DEC DCP
.BYTE $1B,$36,$00,$00,$00,$36,$3F,$00
;     CLD CMP NOP DCP NOP CMP DEC DCP
.BYTE $2D,$36,$00,$00,$00,$36,$3F,$00
; EX  CPX SBC NOP ISC CPX SBC INC ISC
.BYTE $39,$84,$00,$00,$39,$84,$4B,$00
;     INX SBC NOP SBC CPX SBC INC ISC
.BYTE $4E,$84,$66,$00,$39,$84,$4B,$00
; FX  BEQ SBC KIL ISC NOP SBC INC ISC
.BYTE $12,$84,$00,$00,$00,$84,$4B,$00
;     SED SBC NOP ISC NOP SBC INC ISC
.BYTE $8A,$84,$00,$00,$00,$84,$4B,$00
;*********************************
; TABLE OF ADDRESSING MODE CODES
;*********************************
;
; AN ADDRESSING MODE'S CODE IS
; ITS OFFSET INTO SUBS, THE TABLE
; OF ADDRESSING MODE SUBROUTINES
;
; ILLEGL ; 0  $00
; ACC    ; 2  $02
; IMMEDT ; 4  $04
; ZEROPG ; 6  $06
; ZEROX  ; 8  $08
; ZEROY  ; 10 $0A
; ABSLUT ; 12 $0C
; ABSX   ; 14 $0E
; ABSY   ; 16 $10
; IMPLID ; 18 $12
; RELATV ; 20 $14
; INDX   ; 22 $16
; INDY   ; 24 $18
; INDRCT ; 26 $1A
;*********************************
MODES = * 
; 0X   0  1 2 3 4 5 6 7
.BYTE 18,22,0,0,0,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,2,0,0,12,12,0
; 1X   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,0,8,8,0
;      8  9 A B C D E F
.BYTE 18,16,0,0,0,14,14,0
; 2X   0  1 2 3 4 5 6 7
.BYTE 12,22,0,0,6,6,6,0
;.BYTE 12,22,0,0,28,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,2,0,12,12,12,0
;.BYTE 18,4,2,0,30,12,12,0
; 3X   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,0,8,8,0
;      8  9 A B C D E F
.BYTE 18,16,0,0,0,14,14,0
; 4X   0  1 2 3 4 5 6 7
.BYTE 18,22,0,0,0,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,2,0,12,12,12,0
; 5X   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,0,8,8,0
;      8  9 A B C D E F
.BYTE 18,16,0,0,0,14,14,0
; 6X   0  1 2 3 4 5 6 7
.BYTE 18,22,0,0,0,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,2,0,26,12,12,0
; 7X   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,0,8,8,0
;      8  9 A B C D E F
.BYTE 18,16,0,0,0,14,14,0
; 8X   0  1 2 3 4 5 6 7
.BYTE 0,22,0,0,6,6,6,0
;      8  9 A B C D E F
.BYTE 18,0,18,0,12,12,12,0
; 9X   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,8,8,10,0
;      8  9 A B C D E F
.BYTE 18,16,18,0,0,14,0,0
; AX   0  1 2 3 4 5 6 7
.BYTE 4,22,4,0,6,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,18,0,12,12,12,0
; BX   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,8,8,10,0
;      8  9 A B C D E F
.BYTE 18,16,18,0,14,14,16,0
; CX   0  1 2 3 4 5 6 7
.BYTE 4,22,0,0,6,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,18,0,12,12,12,0
; DX   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,0,8,8,0
;      8  9 A B C D E F
.BYTE 18,16,0,0,0,14,14,0
; EX   0  1 2 3 4 5 6 7
.BYTE 4,22,0,0,6,6,6,0
;      8  9 A B C D E F
.BYTE 18,4,18,0,12,12,12,0
; FX   0  1 2 3 4 5 6 7
.BYTE 20,24,0,0,0,8,8,0
;      8  9 A B C D E F
.BYTE 18,16,0,0,0,14,14,0
;*********************************
;.FIL 0:SYM.ASM
;*********************************
.END