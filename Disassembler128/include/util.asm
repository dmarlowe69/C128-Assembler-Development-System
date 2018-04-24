;*********************************
; FILE UTIL.ASM
;*********************************
;
;        DISASSEMBLER128
;    SYMBOLIC DISASSEMBLER
;       BY DENTON MARLOWE
;
;  (C)1986 BY DENTON MARLOWE
;
;*********************************
;      *** UTILITIES ***
;*********************************
; CHECK LINE COUNT FOR OUTPUT FILE
;*********************************
LINECK LDA PASS
 CMP CPASS
 BNE LINECO
 LDA DEVICE
 AND #$08
 BEQ LINECO
;*********************************
; CLOSE SOURCE FILE AND OPEN NEXT
;*********************************
 SEC
 LDA LINEFL
 SBC #$20
 STA TEMP
 LDA LINEFL+1
 SBC #$03
 ORA TEMP
 BCC LINECO
 NOP
 NOP
 NOP
 JSR EFILE
 LDA #$08
 JSR CLOSE
 JSR OFILE
 LDA #$00
 STA LINEFL
 STA LINEFL+1
 JSR ORGIN
 JSR COMENT
LINECO RTS
;*********************************
;  DISK ERROR CHECK
;*********************************
DISERR LDA #$08 ;DEV #8
 STA $BA ;PUT IN DEV TABLE
 JSR $FFB4 ;SEND TALK
 LDA #$6F ;SECONDARY ADDRESS
 STA $B9 ;PUT IN TABLE
 JSR $FF96 ;SEND SEC
 JSR $FFA5 ;GET FIRST BYTE
 CMP #$30 ;IS IT A ZERO
 BNE DLOOC ;IF NOT ZERO ERROR
DLOOE JSR $FFA5 ;GET BYTE
 CMP #$0D ;IS IT CR?
 BNE DLOOE ;GET NEXT BYTE
 JSR $FFAB ;UNTALK
 CLC ;NO ERROR FLAG
 RTS ;RETURN
;*********************************
; PRINT DISK ERROR
;*********************************
DLOOC PHA ;STACK BYTE
 LDA #$0D ;ASCII CR
 JSR CHROUT ;PRINT IT
 PLA ;GET BYTE
 JSR CHROUT ;PRINT IT
DLOOA JSR $FFA5 ;GET NEXT BYTE
 JSR CHROUT ;PRINT IT
 CMP #$0D ;IS IT CR
 BNE DLOOA ;GET NEXT BYTE
 JSR $FFAB ;UNTALK
 SEC ;SET ERROR FLAG
 RTS ;RETURN
;*********************************
; START NEW LINE AND INC COUNT
;*********************************
NEWLIN INC LINECT
 BNE *+5
 INC LINECT+1
 INC LINEFL
 BNE *+5
 INC LINEFL+1
 JSR CRLF
 LDA DEVICE
 AND #$04
 BEQ NEWEXT
 JSR NEXLIN
NEWEXT RTS
;*********************************
; INPUT UTILITIES
;*********************************
; INPUT STRING ROUTINE
;*********************************
INSTNG LDY #$00
INSTN1 JSR CHRIN
 STA BUF,Y
 INY
 CMP #$0D
 BNE INSTN1
 DEY
 RTS
;*********************************
; INPUT HEX CHAR STRING
;*********************************
GETWRD LDA #$00
 STA ADRS
 STA ADRS+1
 JSR INSTNG
 DEY
 BMI INEND
;*********************************
; PROCESS INPUT
;*********************************
 JSR GETBYT
 LDA TEMP
 STA ADRS
 DEY
 BMI INEND
 JSR GETBYT
 LDA TEMP
 STA ADRS+1
INEND RTS
;*********************************
; COVERT BUFFER INTO BYTES
;*********************************
GETBYT LDA BUF,Y
 JSR BINARY
 STA TEMP
 DEY
 BMI INENX
 LDA BUF,Y
 JSR BINARY
 ASL A
 ASL A
 ASL A
 ASL A
 ORA TEMP
 STA TEMP
INENX RTS
;*********************************
; CONVERT A INTO HEX NIBBLE
;*********************************
BINARY SEC
 SBC #'0'
 BCC NOHEX
 CMP #$0A
 BCC YSHEX
 SBC #$07
 CMP #$10
 BCS NOHEX
 CMP #$0A
 BCS YSHEX
NOHEX SEC
 RTS
YSHEX CLC
 RTS
;*********************************
; GET OPTION (CR/Y OR N): Y=C=0
;*********************************
CRYS   JSR CHRIN
       CMP #'Y'
       BEQ CRYS1
       CMP #$0D
       BEQ CRYS1
       BNE CRNO1
;*********************************
; GET OPTION (Y OR CR/N): Y=C=0
;*********************************
CRNO   JSR CHRIN
       CMP #'N'
       BEQ CRNO1
       CMP #$0D
       BEQ CRNO1
CRYS1  CLC
       RTS
CRNO1  SEC
       RTS
;*********************************
; PRINT UTILITES
;*********************************
; PRINT WORD MSB IN Y LSB IN A
;*********************************
PRBYTS PHA ;PUT A ON STACK
 TYA ;PUT HIH BYTE IN A
 JSR PRBYT ;PRINT MSB
 PLA ;GET LSB
;*********************************
; PRINT BYTE IN A
;*********************************
PRBYT PHA ;PUT BYTE ON STACK
 LSR A ;4 RIGHT SHIFTS
 LSR A ;TO MOVE HIGH
 LSR A ;NIBBLE TO LOW
 LSR A ;NIB WITH HIGH 0'S
 TAY ;USE AS POINTER
 LDA HEXA,Y ;GET ASCII
 JSR PCHAR ;PRINT
 PLA ;PULL BYTE OUT
 AND #$0F ;MASK HIGH NIBBLE
 TAY ;USE AS POINTER
 LDA HEXA,Y ;GET ASCII
 JMP PCHAR ;PRINT
;*********************************
; STRING OUTPUT ROUTINE
;*********************************
STRPNT STA ZEROUR ;POINTER TO
 STY ZEROUR+1 ;MESSAGE
 LDY #$00 ;OFFSET
SOUT LDA (ZEROUR),Y ;GET CHAR
 BEQ SEXIT ;IF ZERO EXIT
 JSR PCHAR ;PRINT
 INY ;INC OFFSET
 BNE SOUT ;LOOP
SEXIT RTS ;RETURN
;*********************************
; PRINT DEC NUMBER (0000)
;*********************************
PRTPAG STX ZEROUR ;LOW  BYTE NUM
 STA ZEROUR+1 ;HIGH BYTE NUM
 LDX #$03 ;4 CHARS
 STX SAVX ;SAVE COUNT
 BNE PRTNU1 ;BRANCH
;*********************************
; PRINT DEC NUMBER (00000)
;*********************************
PRTNUM STX ZEROUR ;LOW  BYTE NUM
 STA ZEROUR+1 ;HIGH BYTE NUM
 LDX #$04 ;5 CHARS
 STX SAVX ;SAVE COUNT
;*********************************
; PRINT DEC NUMBER AND LEADING 0
;*********************************
PRTNU1 LDX SAVX
 LDY #$30
 BNE PRTNU3
PRTNU2 INY 
PRTNU3 SEC 
 LDA ZEROUR
 SBC CONST0,X
 STA ZEROUR
 LDA ZEROUR+1
 SBC CONST1,X
 STA ZEROUR+1
 BCS PRTNU2
 LDA ZEROUR
 ADC CONST0,X
 STA ZEROUR
 LDA ZEROUR+1
 ADC CONST1,X
 STA ZEROUR+1
 TYA
 JSR PCHAR
 DEC SAVX
 BPL PRTNU1
 RTS
;*********************************
;  OUTPUT CHAR TO OPEN CHANNEL
;*********************************
PCHAR PHA ;SAVE CHAR
 LDA DEVICE ;GET FILE FLAG
 AND #$08 ;CHECK FOR DISK
 BEQ PRIN ;IF NONE BRANCH
 LDX #$08 ;DISK FILE #1
 JSR CHKOUT ;FILE IS OUTPUT
 PLA ;GET CHAR
 PHA ;RESAVE CHAR
 JSR CHROUT ;OUTPUT TO DISK
 JSR CLRCHN ;RESET OUTPUT
PRIN LDA DEVICE ;GET DEVICE FLAG
 AND #$04 ;CHECK FOR PRINTER
 BEQ SCREN ;IF NOT BRANCH
 LDX #$04 ;PRINT FILE #4
 JSR CHKOUT ;FILE IS OUTPUT
 PLA ;GET CHAR
 PHA ;RESAVE CHAR
 JSR CHROUT ;OUTPUT TO PRINTER
 JSR CLRCHN ;RESET OUTPUT
SCREN LDA DEVICE ;GET DEVICE FLAG
 AND #$03 ;CHECK FOR SCREEN
 BEQ PEXIT ;IF NOT BRANCH
 PLA ;GET CHAR
 PHA ;RESAVE CHAR
 JSR CHROUT ;OUTPUT TO SCREEN
PEXIT PLA ;GET CHAR
 RTS ;RETURN
;*********************************
; PRINTER OUTPUT ROUTINES
;*********************************
; FINISH OUT PAGE WITH CR
;*********************************
FINISH JSR CRLFPR ;PRINT CR
 INC LISTCT ;INC LINE COUNT
 LDA LISTCT ;GET COUNT
 CMP #$42 ;66 LINES
 BNE FINISH ;IF NOT MORE
 LDA #$00 ;ZERO BYTE
 STA LISTCT ;RESET COUNT
 RTS ;RETURN
;*********************************
; PRINT CR TO PRINTER
;*********************************
CRLFPR LDA #$04 ;DEVICE #4
 STA DEVICE ;SET PRINTER
 JSR CRLF ;CR
 LDA OUTPUT ;GET DEVICE
 STA DEVICE ;RESET DEVICE
 RTS ;RETURN
;*********************************
; START NEWLINE AND CHECK COUNT
;*********************************
NEXPTR JSR CRLFPR ;PRINT CR
NEXLIN INC LISTCT ;INC LINE COUNT
 LDA LISTCT ;GET COUNT
 CMP #$3C ;48 LINES
 BNE LINEOK ;IF NOT BRANCH
 JSR FINISH ;FINISH PAGE
;*********************************
; START NEW PAGE WITH HEADING
;*********************************
HEADER LDA DEVICE ;CHECK DEVICE
 AND #$04 ;PRINTER?
 BEQ LINEOK ;IF NOT EXIT
 JSR NEXPTR ;NEXT LINE
 LDA #$04 ;DEVICE #4
 STA DEVICE ;SET DEVICE
 LDA #<XTITLE ;HEADER
 LDY #>XTITLE ;
 JSR STRPNT ;PRINT IT
;*********************************
; PRINT PAGE COUNT AND HEADER
;*********************************
 LDX PAGECT
 LDA PAGECT+1
 JSR PRTPAG
 JSR NEXPTR
 JSR NEXPTR
 LDA #$04
 STA DEVICE
 LDA #<LTITLE
 LDY #>LTITLE
 JSR STRPNT
 JSR NEXPTR
;*********************************
; INC PAGE COUNT
;*********************************
 INC PAGECT
 BNE PAGER1
 INC PAGECT+1
PAGER1 JSR NEXPTR
 JSR NEXPTR
LINEOK RTS 
;*********************************
; SYMBOL TABLE ROUTINES
;*********************************
; START NEWLINE AND CHECK COUNT
;*********************************
NEXPTS JSR CRLFPR ;PRINT CR
 INC LISTCT ;INC LINE COUNT
 LDA LISTCT ;GET COUNT
 CMP #$3C ;48 LINES
 BNE HEADOK ;IF NOT BRANCH
 JSR FINISH ;FINISH PAGE
;*********************************
; START NEW PAGE WITH HEADING
;*********************************
HEADES JSR NEXPTS ;NEXT LINE
 LDA #<XTITLS ;HEADER
 LDY #>XTITLS ;
 JSR STRPNT ;PRINT IT
 JSR NEXPTS
 JSR NEXPTS
 LDA #<LTITLS
 LDY #>LTITLS
 JSR STRPNT
 JSR NEXPTS
HEADOK RTS
;*********************************
; CHECK FOR NEW PAGE FOR SYMBOL
;*********************************
HEADSY LDA LISTCT
 CMP #$35
 BCS HEADFX
 JSR NEXPTS
 JMP NEXPTS
HEADFX JMP FINISH
;*********************************
; SCREEN UTILITES
;*********************************
SCROFF LDA DEVICE
 AND #$04
 BEQ SCRNO1
 LDA VICREG
 AND #$EF
 STA VICREG
SCRNO1 RTS
;*********************************
SCRON LDA VICREG
 ORA #$10
 STA VICREG
 RTS
;*********************************
; HEX-TO-ASCII TABLE
;*********************************
HEXA .TEXT '0123456789ABCDEF'
;*********************************
; CONSTANTS FOR PRTNUM ROUTINE
;*********************************
CONST0 .BYTE $01,$0A,$64,$E8,$10
CONST1 .BYTE $00,$00,$00,$03,$27
;*********************************
; PAGE TITLE
;*********************************
XTITLE .TEXT 'DISASSEMBLER128.......PAGE '
 .BYTE $00
LTITLE .TEXT 'LINE# LOC   CODE        LINE'
 .BYTE $00
;********************************
; SYMBOL PAGE TITLE
;********************************
XTITLS .TEXT 'SYMBOL TABLE',0
LTITLS .TEXT 'SYMBOL VALUE',0
;*********************************
;.FIL 0:MODE.ASM
;*********************************
.END
