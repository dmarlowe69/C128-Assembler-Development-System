;*********************************
; FILE DIS.ASM
;*********************************
;
;        DISASSEMBLER128
;    SYMBOLIC DISASSEMBLER
;       BY DENTON MARLOWE
;
;  (C)1986 BY DENTON MARLOWE
;
;*********************************
; KERNAL ADDRESS
;*********************************
VICREG=$D011 ;SCREEN REGISTER
CHROUT=$FFD2 ;OUTPUT CHARACTER
CHKIN =$FFC6 ;OPEN INPUT FILE
CHRIN =$FFCF ;GET KEYBOARD INPUT
GETIN =$FFE4 ;GET KEYBOARD CHAR
CLRCHN=$FFCC ;RESET I/O CHANNELS
STOP =$FFE1 ;CHECK FOR STOP
READST=$FFB7 ;READ ST
SETNAM=$FFBD ;SET FILENAME
SETLFS=$FFBA ;SET LOGICAL FILE
OPEN =$FFC0 ;OPEN FILE
CHKOUT=$FFC9 ;OPEN OUTPUT CHANNEL
CLOSE =$FFC3 ;CLOSE LOGICAL FILE
;WREADY=$E391 ;BASIC RETURN
WREADY=$4D37 ;BASIC RETURN
;*********************************
; ZERO PAGE ADDRESS
;
; USED: $FA,$FB,$FC,$FD,$FE,$FF
;*********************************
;ZEROUR=$02 ;ZEROPAGE POINTER
ZEROLG=$FB ;POINTER FOR LONG LDA/STA
ZEROUR=$FB ;ZEROPAGE POINTER
;MEMSIZ=$37 ;TOP OF FREE RAM+1
MEMSIZ=$39 ;TOP OF FREE RAM+1
;********************************
; EXTERNAL ADDRESS EQUATES
;********************************
CURON  = $CD6F
CUROFF = $CD9F
;
SETBNK = $FF68 ;JSETBNK
CLOSEA = $FF4A ;CLOSE-ALL 
INDFET = $FF74 ;LONG LDA
INDSTA = $FF77 ;LONG STA
INDCMP = $FF7A ;LONG CMP
;
CLALL  = $FFE7
;
PRIMM  = $FF7D
;*********************************
;        ENTRY POINT
;*********************************
*=$1C0F
;*********************************
;        ENTRY POINT
;*********************************
STARTD = *
;*********************************
; SET FLAG TO ALLOW BASIC
; AND KERNAL (ERROR) MESSAGES
; $80 FOR BASIC
; $40 FOR KERNAL
;*********************************
SETMSG=$FF90
       LDA #$40     ;ALLOW KERNAL MESSAGES
       JSR SETMSG
;********************************
; SET MMU
;********************************
       LDA #$00  ;BANK 15
       STA $FF00 ;

       LDA #$0E  ;NO BASIC ROM
       STA $FF00 ;

       LDA #$FC  ;SLOW SPEED
       STA $D030 ;
;********************************
; CLOSE ALL FILES
;********************************
       JSR CLALL
;********************************
; SET TOP OF MEMORY C128 AND PLUS4
;********************************
MEMEND = $8000
       LDA #<MEMEND
       STA MEMSIZ
       LDA #>MEMEND
       STA MEMSIZ+1
;********************************
; SETUP DISASSEMBLER
;********************************
       JMP DISASS
;*********************************
;       VARIABLES
;*********************************
PASS  .BYTE '1'  ;PASS INDICATOR
IPASS .BYTE '1'  ;INTERNAL PASS
EPASS .BYTE '2'  ;EXTERNAL PASS
CPASS .BYTE '3'  ;PRINTING PASS
SPASS .BYTE '4'  ;SYMBOL PASS
;*********************************
XOPT .BYTE $AA ;LABEL GENERATION
ROPT .BYTE $AA ;REL ADDRESS OPT
DEVICE .BYTE $AA ;OUTPUT DEVICE
OUTPUT .BYTE $AA ;OUTPUT FLAG
WINDOW .BYTE $AA ;WINDOW FLAG
FOROPT .BYTE $AA ;FORMAT FLAG
COMOPT .BYTE $AA ;COMMENT FLAG
;*********************************
; DISASSEMBLY ADDRESS POINTERS
;*********************************
SA .WORD $AAAA ;START ADDRESS
EA .WORD $AAAA ;END ADDRESS
SELECT .WORD $AAAA ;BYTE POINTER
OFFSET .WORD $AAAA ;ADDRESS OFFSET
SAGOL  .WORD $AAAA ;GOLBAL START
EAGOL  .WORD $AAAA ;GOLBAL END
SAOUT .WORD $AAAA ;START ADDRESS
EAOUT .WORD $AAAA ;END ADDRESS
;*********************************
; INTERNAL ADDRESS TABLE
;*********************************
TABINP .WORD $AAAA ;TABLE POINTER
TABINS .WORD $AAAA ;TABLE START
TABINE .WORD $AAAA ;TABLE END
;*********************************
; SORT TABLE POINTERS
;*********************************
SMALLS .WORD $AAAA ;TABLE START
SMALLP .WORD $AAAA ;TABLE POINTER
;*********************************
; SYMBOL TABLE
;*********************************
SYMBOL .BYTE $AA   ;SYMBOL OPTION
SYMBOP .WORD $AAAA ;TABLE POINTER
SYMBOS .WORD $AAAA ;TABLE START
SYMBOE .WORD $AAAA ;TABLE END
;*********************************
; UNDEFINED SYMBOL TABLE
;*********************************
UYMBOP .WORD $AAAA ;TABLE POINTER
UYMBOS .WORD $AAAA ;TABLE START
UYMBOE .WORD $AAAA ;TABLE END
;*********************************
; TEMP WORKING STORAGE
;*********************************
WORKED .WORD $AAAA ;TWO BYTE OP
WORKER .WORD $AAAA ;TWO BYTE OP
SAVEP .WORD $AAAA ;TWO BYTE OP
SAVES .WORD $AAAA ;TWO BYTE OP
SAVEE .WORD $AAAA ;TWO BYTE OP
;*********************************
; OTHER VARIABLES
;*********************************
ADRS .WORD $AAAA
TEMP .BYTE $AA
SAVA .BYTE $AA
SAVX .BYTE $AA
SAVY .BYTE $AA
;*********************************
; PRINTER OUTPUT STORAGE
;*********************************
PAGECT .WORD $AAAA ;PAGE COUNT
LISTCT .BYTE $AA ;LINE COUNT
LINECT .WORD $AAAA ;LINE COUNT
ERRCT  .WORD $AAAA ;ERROR COUNT
;*********************************
; INPUT BUFFER
;*********************************
BUF = *
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
 .BYTE 0,0,0,0,0,0,0,0,0,0
;*********************************
; FILE NAME BUFFER
;*********************************
LINEFL .WORD $AAAA
VERSON .BYTE $AA
NCHARS .BYTE $AA
NBUF = *
 .TEXT '0:'
 .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
 .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
 .BYTE $AA,$AA,$AA,$AA
;*********************************
; SYMBOL TABLE BUFFER
;*********************************
SYMBUF = *
 .BYTE $AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA,$AA
;*********************************
; DATA TABLE
;*********************************
EAS .WORD $AAAA
TEXTER .BYTE $AA
CDATA .WORD $AAAA
NDATA .WORD $AAAA
DATABP .WORD $AAAA ;DATA POINT
DATABS .WORD $AAAA ;DATA START
DATABE .WORD $AAAA ;DATA END
;*********************************
; DATA TABLE
;*********************************
TDATA .BYTE $AA
;*********************************
 *=*+$0100
;*********************************
MPASS  .TEXT $0D,'PASS',0
PMSG   .TEXT $0D,$12,' PAUSE ',$92,$0D,0
MSGERR .TEXT 'ERRORS = ',0
MSGDIS .TEXT 'END OF DISASSEMBLY',0
;*********************************
; INITIALIZE DISASSEMBLER
;*********************************
DISASS LDX #$FF
 TXS
 CLD
 JSR DOP ;GET OPTIONS
 JSR INITIN ;INIT POINTERS
 LDA #'1'      ;PASS ONE
 STA PASS ;SET PASS INDICATOR
;*********************************
; DISASSEMBLER LOOP
;*********************************
DISA JSR INTSA ;SET SA
 LDA #00 ;ZERO BYTE
 STA CDATA ;SET TABLE NUMBER
 LDA #<MPASS ;PASS MSG
 LDY #>MPASS ;
 JSR STRPNT ;PRINT IT
 LDA PASS ;GET PASS
 JSR PCHAR ;PRINT NUMBER
 JSR CRLF ;CR
;*********************************
 LDA PASS ;GET PASS
 CMP CPASS ;IS IT LAST
 BEQ DISB ;IF SO PRINT
 CMP EPASS      ;IS IT EXTERNAL
 BNE DLOOP ;IF NOT GO ON
 JSR SAVINT ;SAVE INTERNAL
 JSR EQUINT ;SET EQUATES
 JMP DLOOP ;GO ON
;*********************************
DISB LDA #$01 ;ONE BYTE
 STA LINECT ;SET LINE # TO 1
 STA PAGECT ;SET PAGE TO 1
 LDA #$00 ;ZERO BYTE
 STA LINECT+1 ;SET LINE # TO 1
 STA PAGECT+1 ;SET PAGE TO 1
 STA LISTCT ;SET LIST TO 0
 STA ERRCT ;SET ERROR TO 0
 STA ERRCT+1 ;SET ERROR TO 0
 STA LINEFL ;SET LINE TO 0
 STA LINEFL+1 ;SET LINE TO 0
 LDA OUTPUT ;GET OUTPUT
 STA DEVICE ;SET OUTPUT
;*********************************
 JSR HEADER ;PRINT HEADER
 JSR OFILED ;OPEN DISK FILE
 JSR ORGIN ;PRINT ORGIN LABEL
 JSR EQUPRT ;PRINT EQUATE
;********************************
DLOOP JSR DSLINE ;DIS ONE LINE
 BCS NEXTP ;IF EA STOP
 JSR LINECK ;LINE COUNT
 JSR STOP ;CHECK STOP
 BEQ QUITS ;IF SO QUIT
 JSR GETIN ;GET KEY
 BEQ DLOOP ;IF NONE NEXT
 CMP #' '          ;IS IT A SPACE
 BNE DLOOP ;IF NOT NEXT
;*********************************
; PAUSE LISTING
;********************************
 LDA DEVICE
 PHA
 LDA #$03
 STA DEVICE
 LDA #<PMSG
 LDY #>PMSG
 JSR STRPNT
 PLA
 STA DEVICE
PAUSE JSR GETIN ;PAUSE FOR KEY
 BEQ PAUSE ;
 BNE DLOOP ;NEXT LINE
;********************************
NEXTP INC PASS ;INC PASS
 LDA PASS ;GET PASS
 CMP CPASS ;LAST PASS?
 BCC DISFUL ;IF LESS AGAIN
 BNE DISC ;FINISH
 LDA WINDOW ;WINDOW FLAG
 BEQ DISFUL ;FULL OUTPUT
;*********************************
; WINDOWED OUTPUT
;*********************************
 LDA SAOUT ;
 STA SA ;
 LDA SAOUT+1 ;
 STA SA+1 ;
 LDA EAOUT ;
 STA EA ;
 LDA EAOUT+1 ;
 STA EA+1 ;
;*********************************
DISFUL JMP DISA ;LAST PASS
DISC JSR INCSL
 JSR EFILE ;END FILE MSG
;*********************************
QUITS LDA DEVICE ;CHECK DEV
 AND #$08 ;DISK FILE?
 BEQ QUTERR ;IF NOT BRANCH
 LDA #$08 ;DISK
 JSR CLOSE ;CLOSE IT
 LDA OUTPUT ;GET OUTPUT
 AND #07 ;MASK DISK
 STA OUTPUT ;RESET OUTPUT
 STA DEVICE ;RESET OUTPUT
;*********************************
; PRINT ERRORS
;*********************************
QUTERR LDA OUTPUT
 ORA #$03
 STA OUTPUT
 STA DEVICE
 JSR NEWLIN
 JSR NEWLIN
 LDA #<MSGERR
 LDY #>MSGERR
 JSR STRPNT
 LDX ERRCT
 LDA ERRCT+1
 JSR PRTNUM
;*********************************
 LDA DEVICE ;CHECK DEV
 AND #$04 ;PRINTER?
 BEQ DONED ;IF NOT DONE
 LDA #$04 ;DEVICE 4
 STA OUTPUT ;SET DEVICE
 STA DEVICE ;SET DEVICE
 JSR INTPRT ;PRINT INTABLE
 LDA #$07 ;DEVICE 3 AND 4
 STA DEVICE ;SET DEVICE
 STA OUTPUT ;SET DEVICE
DONED JSR NEWLIN ;NEWLINE
 JSR NEWLIN ;NEWLINE
 LDA #<MSGDIS ;END MSG
 LDY #>MSGDIS
 JSR STRPNT ;PRINT IT
 JSR NEWLIN ;NEW LINE
 LDA DEVICE ;CHECK DEVICE
 AND #$04 ;PRINTER
 BEQ DONE ;
 JSR FINISH ;FINISH PAGE
 LDA #$04 ;PRINTER
 JSR CLOSE ;CLOSE FILE
;*********************************
DONE JSR CLRCHN ;RESET I/O
 JSR SCRON      ;TURN SCREEN ON

 LDA #$00  ;BANK 15
 STA $FF00 ; 

 JMP WREADY     ;RETURN
;*********************************
;.FIL 0:OPTION.ASM
;*********************************
.END