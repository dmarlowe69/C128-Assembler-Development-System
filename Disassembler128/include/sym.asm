;*********************************
; FILE SYMBOL.ASM
;*********************************
;
;        DISASSEMBLER128
;    SYMBOLIC DISASSEMBLER
;       BY DENTON MARLOWE
;
;  (C)1986 BY DENTON MARLOWE
;
;*********************************
; SYMBOLIC ROUTINES
;*********************************
; SYMBOLIC DISASSEMBLY OPTION
;*********************************
SOP    LDA #<MSS1  ;LOW BYTE MESSAGE
       LDY #>MSS1  ;HIGH BYTE MESSAGE
       JSR STRPNT  ;OUTPUT MESSAGE
;      JSR CRNO    ;GET KEY PRESS
       JSR CRYS
       BCC SOP1    ;C=0 YES
;*********************************
; ABSOLUTE DISASSEMBLY SELECTED
;*********************************
       LDA #$00    ;SET SYMBLOIC FLAG
       STA SYMBOL  ;STORE FLAG
       JMP SY      ;FOR INTERNAL
;*********************************
; SYMBOLIC DISASSEMBLY SELECTED
;*********************************
SOP1   LDA #$01    ;SET SYMBOLIC FLAG
       STA SYMBOL  ;STORE FLAG
;*********************************
; SETUP START OF TABLE POINTER
;*********************************
 LDA #<STABLE
 STA SYMBOS
 STA SYMBOP
 LDA #>STABLE
 STA SYMBOS+1
 STA SYMBOP+1
;*********************************
; CHECK FOR SYMBOL TABLE OPTION
;*********************************
SYTAB LDA #<MSS2 ;LOW BYTE MESSAGE
 LDY #>MSS2 ;HIGH BYTE MESSAGE
 JSR STRPNT ;OUTPUT MESSAGE
 JSR CRNO ;GET KEY PRESS
 BCS SY ;C=1 NO
;*********************************
; APPEND SYMBOL TABLE
;*********************************
 LDA #<MSS4
 LDY #>MSS4
 JSR STRPNT
 JSR CRNO
 BCS SOP4
 LDA #<UTABLE
 STA SYMBOP
 LDA #>UTABLE
 STA SYMBOP+1
;*********************************
; GO AND LOAD TABLE
;*********************************
SOP4 JSR READXX ;READ FILE
 BCS SY ;C=1 ERROR
;*********************************
; SETUP END OF TABLE POINTER
;*********************************
 LDA SYMBOP ;XREF POINTER
 STA SYMBOE
 LDA SYMBOP+1
 STA SYMBOE+1
 RTS
;*********************************
; DEFAULT SYMBOL TABLE END
;*********************************
SY LDA #<UTABLE
 STA SYMBOE
 LDA #>UTABLE
 STA SYMBOE+1
 RTS
;*********************************
; SET OR RESET SYMBOL TABLE
;*********************************
SSET LDA SYMBOS
 STA SYMBOP
 LDA SYMBOS+1
 STA SYMBOP+1
 RTS
;*********************************
; EQUATE TABLE SETUP
;*********************************
EQUINT LDA TABINE
 STA TABINP
 STA TABINS
 LDA TABINE+1
 STA TABINP+1
 STA TABINS+1
 RTS
;*********************************
; ENTRY POINT FOR ADDRESS
;*********************************
SYM LDA SYMBOL
 BEQ SYMEND
 LDA SELECT ;COPY SELECT
 STA WORKED ;ADDRESS INTO
 LDA SELECT+1 ;WORKED
 STA WORKED+1
 JMP SYM1 ;CHECK FOR MATCH
;*********************************
; ENTRY POINT FOR OPCODES
;*********************************
SYMOP LDA SYMBOL
 BEQ SYMEND
;*********************************
; COMPARE ADDRESS TO SYMBOL TABLE
;*********************************
SYM1 JSR SSET
SYM2 JSR GETC
 STA WORKER+1
 JSR INCC
 JSR GETC
 STA WORKER
;*********************************
 SEC ;SET CARRY
 LDA WORKER
 SBC WORKED ;SUB FROM LOW
 STA TEMP ;STORE RESULT
 LDA WORKER+1
 SBC WORKED+1 ;SUB FROM HIGH
 ORA TEMP ;OR RESULTS
 BEQ MATCH ;CHECK FOR MATCH
 JSR NEXTC ;IF NOT NEXT
 BCS SYMEND ;END OF TABLE?
 JMP SYM2 ;NO CHECK NEXT
SYMEND CLC ;NO MATCHES CLEAR
 RTS ;RETURN
;*********************************
; FOUND MATCH
;*********************************
MATCH LDA PASS ;CHECK PASS
 CMP CPASS ;IS IT LAST
 BEQ MATCHS ;IF SO PRINT
 CMP SPASS
 BEQ MATCHT
 JSR RANGE ;SYMBOL IN RANGE
 BCC MATEXT ;NO INTERNAL EQ
 JSR INCC ;INC TO SYMBOL
 JSR GETC ;GET FIRST CHAR
 CMP #$20 ;SPACE
 BEQ MATONE ;NOT EQUATE
 JMP PUTI ;PUT IN EQUATE
MATONE RTS ;RETURN
;*********************************
; CHECK FOR SYMBOL+1
;*********************************
MATCHS JSR INCC ;INC TO LABEL
 JSR GETC ;GET CHARARCTER
 CMP #$20 ;IS IT SPACE
 BNE MATCHT ;IF NOT GO ON
 SEC ;SET CARRY
 LDA SYMBOP ;GET LOW POINT
 SBC #$09 ;LAST SYMBOL
 PHA ;PUSH ON STACK
 LDA SYMBOP+1 ;GET HIGH POINT
 SBC #$00 ;LAST SYMBOL
 TAY ;PUT IN Y
 PLA ;GET LO POINT
 JSR STRSYM ;PRINT SYMBOL
 LDA #'+'         ;ASCII +
 JSR PCHAR ;PRINT IT
 LDA #'1'         ;ASCII 1
 JSR PCHAR ;PRINT IT
 SEC ;C=1 SYMBOL
 RTS ;RETURN
;*********************************
MATCHT LDA SYMBOP ;LOW BYTE LABEL
 LDY SYMBOP+1 ;HIGH BYTE LABEL
 JSR STRSYM ;PRINT LABEL
;*********************************
 SEC ;MATCH SET CARRY
MATEXT RTS ;RETURN
;*********************************
; PRINT SYMBOL
;*********************************
STRSYM STA ZEROUR
 STY ZEROUR+1
 LDY #$00
STRSY1 LDA (ZEROUR),Y
 BEQ SYEXIT
 CMP #$20
 BEQ SYEXIT
 JSR PCHAR
 INY
 BNE STRSY1
SYEXIT RTS
FIXSYM LDA (ZEROUR),Y
 BEQ SYEXIT
 JSR PCHAR
 INY
 JMP FIXSYM
;*********************************
; INC SYMBOL ADDRESS TABLE POINTER
;*********************************
NEXTC CLC
 LDA SYMBOP
 ADC #$08
 STA SYMBOP
 LDA SYMBOP+1
 ADC #$00
 STA SYMBOP+1
 CMP SYMBOE+1
 BCC COK
 BNE NCOK
 LDA SYMBOP
 CMP SYMBOE
 BCS NCOK
COK CLC
 RTS
NCOK SEC
 RTS
;*********************************
INCC INC SYMBOP
 BNE *+5
 INC SYMBOP+1
 RTS
;*********************************
; GET BYTE FROM ADDRESS TABLE
;*********************************
GETC LDA SYMBOP
 STA ZEROUR
 LDA SYMBOP+1
 STA ZEROUR+1
 LDY #$00
 LDA (ZEROUR),Y
 RTS
;*********************************
; PRINT EQUATE TABLE
;*********************************
EQUPRT SEC
 LDA TABINS
 SBC TABINE
 STA TEMP
 LDA TABINS+1
 SBC TABINE+1
 ORA TEMP
 BEQ EQUEND
 JSR SORT
 JSR COMENT
 JSR PRTOTH
 LDA #<EQUATE
 LDY #>EQUATE
 JSR STRPNT
 JSR NEWLIN
 JSR COMENT
EQUOP JSR GETI
 STA WORKED
 JSR INCI
 JSR GETI
 STA WORKED+1
 JSR PRTOTH
 JSR SYMOP
 BCS EQUOP1
 JSR PWORK
EQUOP1 LDA #'='
 JSR PCHAR
 LDA #'$'
 JSR PCHAR
 JSR PWORKD
 JSR NEWLIN
;*********************************
 JSR INCI
 LDA TABINP+1
 CMP TABINE+1
 BCC EQUOP
 BNE EQUEND
 LDA TABINP
 CMP TABINE
 BCC EQUOP
;*********************************
EQUEND JSR COMENT
 JMP RESINT
;*********************************
; READ CROSS REFERENCE SEQ FILE
;      INTO SYMBOL TABLE
;*********************************
; READ FILE NAME DEFAULT ON CR
;*********************************
READXX LDA #<MSS3
 LDY #>MSS3
 JSR STRPNT
SOP2 JSR GETIN
 BEQ SOP2
 CMP #'0'
 BEQ SOP3
 CMP #'1'
 BNE SOP2
SOP3 JSR CHROUT
 STA TEXTER
;*********************************
 LDA #<LOADF
 LDY #>LOADF
 JSR STRPNT
;*********************************
 JSR INSTNG
 BEQ READXF
 TYA
 PHA
 JSR INITD
 PLA
 TAY
 LDX #$00
XFILE1 LDA NAMS,X
 STA BUF,Y
 INY
 INX
 CPX #$04
 BNE XFILE1
 TYA
 LDY #>BUF
 LDX #<BUF
 JSR SETNAM
 JMP REOPEN
;*********************************
; DEFAULT FILENAME XRFF0000
;********************************
READXF LDA #$0E
 LDY #>NAME
 LDX #<NAME
 JSR SETNAM
;*********************************
; OPEN FILE
;********************************
REOPEN LDA #$03
 LDX #$08
 LDY #$03
 JSR SETLFS
;
 LDA #$00     ;LOAD INTO BANK 1
 LDX #$00     ;PROGRAM IN BANK 0
 JSR SETBNK
;
 JSR OPEN
;********************************
; CHECK FOR DISK ERROR
;*********************************
 JSR DISERR
 BCS QUITXX
;*********************************
; OUTPUT LOADING MESSAGE
;*********************************
 LDA #<LOADM ;MSG LOW
 LDY #>LOADM ;MSG HIGH
 JSR STRPNT ;OUTPUT MSG
;*********************************
 LDA #$00 ;COL COUNTER
 STA TEMP
;*********************************
; INPUT AND LOAD SYMBOL TABLE
;*********************************
READX JSR READS ;INPUT SYMBOL
 JSR PUTC
 JSR LINES ;SCREEN OUT
 JSR STOP
 BEQ QUITX
 JSR READST
 BEQ READX
;*********************************
;    CLOSE OPEN FILE
;*********************************
QUITX LDA #$03
 JSR CLOSE
 JSR CLRCHN
 JSR CRLF
;*********************************
; SET END OF TABLE
;*********************************
 LDA SYMBOP
 STA SYMBOE
 LDA SYMBOP+1
 STA SYMBOE+1
;*********************************
; OUTPUT LOADED MESSAGE
;*********************************
 LDA #<LOADC
 LDY #>LOADC
 JSR STRPNT
 CLC
 RTS
;*********************************
; OUTPUT ERROR MESSAGE
;*********************************
QUITXX LDA #$03
 JSR CLOSE
 JSR CLRCHN
 LDA #<LOADE
 LDY #>LOADE
 JSR STRPNT
 SEC
 RTS
;*********************************
; READ SYMBOL FROM FILE
;*********************************
READS LDX #$03 ;FILE NUMBER
 JSR CHKIN ;FILE IS INPUT
 LDY #$02 ;COUNTER
 JSR CHRIN ;INPUT CHAR
 STA SYMBUF,Y ;1ST CHAR
 JSR CHROUT ;PRITN IT
 INY ;INC POINTER
READY JSR CHRIN ;NEXT CHAR
 STA SYMBUF,Y ;STORE
 JSR CHROUT ;PRINT IT
 INY ;INC OFFSET
 CPY #$08 ;8 IS FOR NULL
 BNE READY ;BRANCH IF NOT
 LDA #$00 ;NULL MARKER
 STA SYMBUF,Y ;STORE AT END
;*********************************
 JSR SPACE ;PRINT SPACE
 JSR DOLLAR ;PRINT $ SIGN
;*********************************
 LDA TEXTER
 CMP #'0'
 BEQ STDREF
;*********************************
 LDY #$00
 JSR XGET
 INY
 JSR XGET
 JSR CHRIN ;GET $0D
 JMP CLRCHN
;*********************************
XGET JSR CHRIN
 JSR CHROUT
 JSR BINARY
 ASL A
 ASL A
 ASL A
 ASL A
 STA SYMBUF,Y
 JSR CHRIN
 JSR CHROUT
 JSR BINARY
 ORA SYMBUF,Y
 STA SYMBUF,Y
 RTS
;*********************************
STDREF LDY #$00 ;ZERO OFFSET
 JSR CHRIN ;HIGH BYTES
 STA SYMBUF,Y ;
 STY SAVY ;
 JSR PRBYT ;
 LDY SAVY ;
 INY ;
 JSR CHRIN ;LOW BYTE
 STA SYMBUF,Y ;
 JSR PRBYT ;
 JMP CLRCHN ;KEYBOARD INPUT
;*********************************
; MOVE SYMBOL FROM BUFFER TO TABLE
;*********************************
PUTC LDY #$00
 LDA SYMBOP
 STA ZEROUR
 LDA SYMBOP+1
 STA ZEROUR+1
PUT LDA SYMBUF,Y
 STA (ZEROUR),Y
 INY
 CPY #$09
 BNE PUT
 CLC
 LDA SYMBOP
 ADC #$09
 STA SYMBOP
 LDA SYMBOP+1
 ADC #$00
 STA SYMBOP+1
 RTS
;*********************************
; OUTPUT SYMBOL IN 4 COLUMNS
;*********************************
LINES INC TEMP
 LDA #$03
 CMP TEMP
 BEQ RESET
 LDA #'.'
 JMP CHROUT
RESET LDA #$00
 STA TEMP
 LDA #$0D
 JMP CHROUT
;*********************************
;   COMMAND MESSAGES
;*********************************
NAME .TEXT '0:XRLL0000'
NAMS .TEXT ',S,R'
;*********************************
MSS1 .BYTE $0D
; .TEXT 'SYMBOLIC DISASSEMBLY (Y OR N/CR)? '
 .TEXT 'SYMBOLIC DISASSEMBLY (Y/CR OR N)? '
 .BYTE 0
MSS2 .BYTE $0D
 .TEXT 'LOAD USER SYMBOL TABLE (Y OR N/CR)? '
 .BYTE 0
MSS3 .BYTE $0D
 .TEXT 'FORMAT 0=STANDARD 1=ASCII : '
 .BYTE 0
MSS4 .BYTE $0D
 .TEXT 'APPEND DEFAULT TABLE (Y OR N/CR)? '
 .BYTE 0
LOADF .BYTE $0D
.TEXT 'SYMBOL TABLE(CR OR D:NAME): '
.BYTE 0
LOADM .BYTE $0D,$0D
.TEXT 'READING SYMBOL TABLE FILE'
.BYTE $0D,$0D
.BYTE 0
LOADC .BYTE $0D
.TEXT 'SYMBOL TABLE LOADED'
.BYTE $0D,$0D
.BYTE 0
LOADE .BYTE $0D
.TEXT 'SYMBOL TABLE NOT LOADED'
.BYTE $0D,$0D
.BYTE 0
;*********************************
EQUATE .TEXT '; EXTERNAL ADDRESS EQUATES'
 .BYTE 0
;*********************************
; PATCH CODE AREA
;*********************************
 *=*+$0800
;*********************************
; BIT INSTRUCTION CODING
;*********************************
BITOPT = *
       LDA #<MSB1 ;TABLE TYPE
       LDY #>MSB1
       JSR STRPNT
BOP0   JSR GETIN
       BEQ BOP0
       CMP #'0'   ;STANDARD
       BEQ BSC
       CMP #'1'   ;$2C ABS
       BEQ BSC 
       CMP #'2'   ;$24 ZP
       BEQ BSC
       CMP #'3'   ;$2C AND $24
       BEQ BSC
       CMP #$0D   ;STANDARD
       BNE BOP0
       LDA #'0'
BSC = *
       PHA        ;STASH INPUT
       JSR CHROUT ;OUTPUT FEEDBACK
       PLA        ;POP INPUT
       EOR #$30   ;MAKE A NUMBER
       STA BITFLG ;SET FLAG
       RTS
;*********************************
; BIT INSTRUCTION CODING FLAG
;*********************************
BITFLG = *
       .BYTE $AA
;*********************************

;*********************************
; SYMBOL TABLE
;*********************************
;  KERNAL JUMP TABLE
;*********************************
STABLE = *
 .TEXT $FF,$80,'IDBYTE',0
 .TEXT $FF,$81,'CINT  ',0
 .TEXT $FF,$84,'IOINIT',0
 .TEXT $FF,$87,'RAMTAS',0
 .TEXT $FF,$8A,'RESTOR',0
 .TEXT $FF,$8D,'VECTOR',0
 .TEXT $FF,$90,'SETMSG',0
 .TEXT $FF,$93,'SECOND',0
 .TEXT $FF,$96,'TKSA  ',0
 .TEXT $FF,$99,'MEMTOP',0
 .TEXT $FF,$9C,'MEMBOT',0
 .TEXT $FF,$9F,'SCNKEY',0
 .TEXT $FF,$A2,'SETTMO',0
 .TEXT $FF,$A5,'ACPTR ',0
 .TEXT $FF,$A8,'CIOUT ',0
 .TEXT $FF,$AB,'UNTLK ',0
 .TEXT $FF,$AE,'UNLSN ',0
 .TEXT $FF,$B1,'LISTEN',0
 .TEXT $FF,$B4,'TALK  ',0
 .TEXT $FF,$B7,'READST',0
 .TEXT $FF,$BA,'SETLFS',0
 .TEXT $FF,$BD,'SETNAM',0
 .TEXT $FF,$C0,'OPEN  ',0
 .TEXT $FF,$C3,'CLOSE ',0
 .TEXT $FF,$C6,'CHKIN ',0
 .TEXT $FF,$C9,'CHKOUT',0
 .TEXT $FF,$CC,'CLRCHN',0
 .TEXT $FF,$CF,'CHRIN ',0
 .TEXT $FF,$D2,'CHROUT',0
 .TEXT $FF,$D5,'LOAD  ',0
 .TEXT $FF,$D8,'SAVE  ',0
 .TEXT $FF,$DB,'SETTIM',0
 .TEXT $FF,$DE,'RDTIM ',0
 .TEXT $FF,$E1,'STOP  ',0
 .TEXT $FF,$E4,'GETIN ',0
 .TEXT $FF,$E7,'CLALL ',0
 .TEXT $FF,$EA,'UDTIM ',0
 .TEXT $FF,$ED,'SCREEN',0
 .TEXT $FF,$F0,'PLOT  ',0
 .TEXT $FF,$F3,'IOBASE',0
;*********************************
 .TEXT $FF,$FA,'NMIVEC',0
 .TEXT $FF,$FC,'RESVEC',0
 .TEXT $FF,$FE,'IRQVEC',0
;*********************************
UTABLE .BYTE 0
;*********************************
.END
