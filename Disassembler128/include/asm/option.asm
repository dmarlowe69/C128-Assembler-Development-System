;*********************************
; FILE OPTION.ASM
;*********************************
;
;        DISASSEMBLER128
;    SYMBOLIC DISASSEMBLER
;       BY DENTON MARLOWE
;
;  (C)1986 BY DENTON MARLOWE
;
;*********************************
; DISASSEMBLER OPTIONS
;*********************************
DOP LDA #$03 ;DEVICE #3 SCREEN
 STA DEVICE ;CURRENT OUTPUT
 LDA #$00 ;NO DEVICES
 STA OUTPUT ;FINAL OUTPUT
 LDA #<MSG ;START UP MSG
 LDY #>MSG
 JSR STRPNT ;PRINT IT
;*********************************
; READ IN DISK FILE ?
;*********************************
 LDA #<MSF1
 LDY #>MSF1
 JSR STRPNT
 JSR INSTNG
 BNE PFILE0
 JMP STARTS
PFILE0 LDX #$00
PFILE1 LDA PROGM,X
 STA BUF,Y
 INY
 INX
 CPX #$04
 BNE PFILE1
 STY SAVA
 JSR INITD
 JSR PRFILE
;*********************************
; READ IN FILE FOR SA AND EA
;*********************************
 LDX #$08 ;FILE #8
 JSR CHKIN ;INPUT FILE
 JSR CHRIN ;GET LOW BYTE SA
 STA SA ;SET START
 JSR CHRIN ;GET HIGH BYTE SA
 STA SA+1 ;SET START
 JSR INTSA ;SET END
;*********************************
 LDA #$00 ;ZERO BYTE
 STA ADRS ;BYTE COUNTER
 STA ADRS+1 ;BYTE COUNTER
PROGRD JSR CHRIN ;INPUT BYTE
 JSR READST ;READ STATUS
 BNE PROGED ;IF NOT ZERO END
 JSR INCSL ;INC END ADDRESS
 INC ADRS ;INC BYTE COUNT
 BNE *+5 ;
 INC ADRS+1 ;
 BNE PROGRD ;NEXT BYTE
PROGED LDA SELECT ;
 STA EA ;
 LDA SELECT+1 ;
 STA EA+1 ;
;*********************************
 LDA #$08 ;FILE #8
 JSR CLOSE ;CLOSE IT
 JSR CLRCHN ;RESET I/O
;*********************************
; PRINT PROGRAM LOAD ADDRESS
; AND END ADDRESS
;*********************************
 LDA #<MSF2
 LDY #>MSF2
 JSR STRPNT
 LDA SA
 STA WORKED
 LDA SA+1
 STA WORKED+1
 JSR PWORKD
;
 LDA #'-'
;
 JSR PCHAR
 JSR DOLLAR
 JSR PSELEC
 JSR CRLF
;*********************************
; CALCULATE BUFFER ADDRESS
;*********************************
 LDA MEMSIZ
 STA SELECT
 LDA MEMSIZ+1
 STA SELECT+1
 JSR DECSL
 SEC
 LDA SELECT
 SBC ADRS
 STA SELECT
 LDA SELECT+1
 SBC ADRS+1
 STA SELECT+1
;*********************************
; CALCULATE ADDRESS OFFSET
;*********************************
 SEC
 LDA SELECT
 SBC SA
 STA OFFSET
 STA WORKED
 LDA SELECT+1
 SBC SA+1
 STA OFFSET+1
 STA WORKED+1
 LDA #<MSD4A
 LDY #>MSD4A
 JSR STRPNT
 JSR PWORKD
 JSR CRLF
;*********************************
; OPEN FILE AND READ PRG INTO BUF
;*********************************
 JSR PRFILE ;OPEN FILE
 LDX #$08 ;FILE #8
 JSR CHKIN ;INPUT FILE
 JSR CHRIN ;GET LOW BYTE SA
 JSR CHRIN ;GET HIGH BYTE SA
PRO2RD JSR CHRIN ;INPUT BYTE
;
 LDX SELECT ;LOW BYTE POINTER
 STX ZEROUR ;ZERO PAGE
 LDX SELECT+1 ;HIGH BYTE POINTER
 STX ZEROUR+1 ;ZERO PAGE
 LDX #$01 ;RAM BANK 1
 LDY #$00 ;OFFSET
 STA (ZEROUR),Y ;STORE BYTE
; JSR INDSTA
; 
 JSR INCSL ;INC POINTER
 JSR READST ;READ STATUS
 BEQ PRO2RD ;NEXT BYTE
 LDA #$08 ;FILE #8
 JSR CLOSE ;CLOSE IT
 JSR CLRCHN ;RESET I/O
 JMP WINDOP ;WINDOW OPTION
;*********************************
; OPEN PROGRAM FILE
;*********************************
PRFILE LDA SAVA
 LDX #<BUF
 LDY #>BUF
 JSR SETNAM
 LDA #$08
 TAY
 TAX
 JSR SETLFS
;
 LDA #$00     ;LOAD INTO BANK 1
 LDX #$00     ;PROGRAM IN BANK 0
 JSR SETBNK
;
 JSR OPEN
 JSR DISERR
 BCC PROGOK
 LDA #$08
 JSR CLOSE
 PLA
 PLA
 PLA
 PLA

 LDA #$00  ;BANK 15
 STA $FF00 ; 

 
 JMP WREADY
;*********************************
PROGOK RTS
;*********************************
; INIT DISK
;*********************************
INITD LDA #$02
 LDY #>INIT
 LDX #<INIT
 JSR SETNAM
 LDA #$0F
 LDX #$08
 LDY #$0F
 JSR SETLFS
;
 LDA #$00     ;LOAD INTO BANK 1
 LDX #$00     ;PROGRAM IN BANK 0
 JSR SETBNK
;
 JSR OPEN
 LDA #$0F
 JMP CLOSE
;*********************************
; GET START ADDRESS
;*********************************
STARTS LDA #<MSD1
 LDY #>MSD1
 JSR STRPNT
 JSR GETWRD
 LDA ADRS
 STA SA
 LDA ADRS+1
 STA SA+1
;*********************************
; GET END ADDRESS
;*********************************
 LDA #<MSD2
 LDY #>MSD2
 JSR STRPNT
 JSR GETWRD
 LDA ADRS
 STA EA
 LDA ADRS+1
 STA EA+1
;*********************************
; ADDRRESS OFFSET
;*********************************
 LDA #<MSD4
 LDY #>MSD4
 JSR STRPNT
 JSR GETWRD
 LDA ADRS
 STA OFFSET
 LDA ADRS+1
 STA OFFSET+1
;*********************************
; OUTPUT WINDOW
;*********************************
WINDOP LDA #<MSD5
 LDY #>MSD5
 JSR STRPNT
 JSR CRNO
 BCS WIND1
 LDA #<MSD1
 LDY #>MSD1
 JSR STRPNT
 JSR GETWRD
 LDA ADRS
 STA SAOUT
 LDA ADRS+1
 STA SAOUT+1
 LDA #<MSD2
 LDY #>MSD2
 JSR STRPNT
 JSR GETWRD
 LDA ADRS
 STA EAOUT
 LDA ADRS+1
 STA EAOUT+1
 LDA #$FF
 BMI WIND2
WIND1 LDA #$00
WIND2 STA WINDOW
;*********************************
; SETUP GOBAL POINTER
;*********************************
 LDA SA
 STA SAGOL
 LDA SA+1
 STA SAGOL+1
 LDA EA
 STA EAGOL
 LDA EA+1
 STA EAGOL+1
;*********************************
; SOURCE FILE OUTPUT?
;*********************************
OUFILE LDA #<MSG1
 LDY #>MSG1
 JSR STRPNT
;*********************************
 LDA #$00
 STA NCHARS
 JSR INSTNG
 BEQ NOFILE
 LDA #'0'
 STA VERSON
 STY NCHARS
 LDX #$00
GFILE0 LDA BUF,X
 STA NBUF,X
 INX
 CPX NCHARS
 BNE GFILE0
;*********************************
FILEOK LDA #$08
 BNE FILE
NOFILE LDA #$00
FILE ORA OUTPUT
 STA OUTPUT
 JMP PRTGET
;*********************************
;     OPEN SOURCE DISK FILE
;*********************************
OFILED LDY NCHARS
 BEQ NOID
 JSR INITD
NOID JSR SCROFF
;*********************************
OFILE LDY NCHARS
 BEQ OFILE4
 LDA VERSON
 CMP #'0'
 BEQ OFILE1
 LDA VERSON
 STA NBUF,Y
 INY
OFILE1 INC VERSON
 LDX #$00
OFILE2 LDA WRITE,X
 STA NBUF,Y
 INY
 INX
 CPX #$04
 BNE OFILE2
 TYA
 LDY #>NBUF
 LDX #<NBUF
 JSR SETNAM
 LDA #$08
 TAX
 TAY
 JSR SETLFS
;
 LDA #$00     ;LOAD INTO BANK 1
 LDX #$00     ;PROGRAM IN BANK 0
 JSR SETBNK
;
 JSR OPEN
 JSR DISERR
 BCC OFILE4
;*********************************
;  CLOSE OUT FILE ON ERROR
;*********************************
OFILE3 LDA #$08
 JSR CLOSE
 JSR CLRCHN
 PLA
 PLA
 PLA
 PLA

 LDA #$00  ;BANK 15
 STA $FF00 ; 

 JMP WREADY
OFILE4 RTS
;*********************************
; GET PRINTER OPTION
;*********************************
PRTGET LDA #<MSG2
 LDY #>MSG2
 JSR STRPNT
 JSR CRYS
 BCS NOPRT
 LDA #$00
 JSR SETNAM
 LDA #$04
 LDX #$04
 LDY #$00
 JSR SETLFS
;
 LDA #$00     ;LOAD INTO BANK 1
 LDX #$00     ;PROGRAM IN BANK 0
 JSR SETBNK
;
 JSR OPEN
 LDX #$04
 JSR CHKOUT
 JSR READST
 AND #$80
 PHP
 JSR CLRCHN
 PLP
 BMI NOPRT
 LDA #$04
 BNE PRINT
NOPRT LDA #$03
PRINT ORA OUTPUT
 STA OUTPUT
;*********************************
; GO GET SYMBOLIC OPTION
;*********************************
       JSR SOP
;*********************************
; GET RELATIVE ADDRESS OPTION
;*********************************
       LDA #<MSR1
       LDY #>MSR1
       JSR STRPNT
       JSR CRYS
       BCC DOP2
       LDA #$01
       BNE DOP3
DOP2   LDA #$00
DOP3   STA ROPT
;*********************************
; GET BIT INSTRUCTION CODING OPTION
;*********************************
       JSR BITOPT
;*********************************
; DATA TABLE OPTION
;*********************************
AOP LDA SYMBOE
 STA DATABP
 STA DATABS
 STA DATABE
 STA ZEROUR
 LDA SYMBOE+1
 STA DATABP+1
 STA DATABS+1
 STA DATABE+1
 STA ZEROUR+1
;*********************************
 LDA #<MSAOP
 LDY #>MSAOP
 JSR STRPNT
 JSR INSTNG
 BNE BOP
 JMP NOTABS
;*********************************
BOP TYA
 PHA
 JSR INITD
 PLA
 TAY
 LDX #$00
AFILE LDA NAMS,X
 STA BUF,Y
 INY
 INX
 CPX #$04
 BNE AFILE
 TYA
 LDY #>BUF
 LDX #<BUF
 JSR SETNAM
 LDA #$03
 LDX #$08
 LDY #$03
 JSR SETLFS
;
 LDA #$00     ;LOAD INTO BANK 1
 LDX #$00     ;PROGRAM IN BANK 0
 JSR SETBNK
;
 JSR OPEN
 JSR DISERR
 BCS AGET1
 LDX #$03
 JSR CHKIN
;*********************************
; READ IN DATA TABLE
;*********************************
 LDY #$00
 JSR CHRIN
 STA NDATA
 BEQ AGET1
AGET JSR CHRIN
 STA TDATA,Y
 INY
 JSR READST
 BEQ AGET
AGET1 LDA #$03
 JSR CLOSE
 JSR CLRCHN
;*********************************
; PRINT DATA TABLE
;*********************************
PRTDAS LDA NDATA
 STA CDATA
 LDY #$00
 STY SAVY
PRTNEX JSR CRLF
 LDX #$05
 STX SAVX
PRTDAL LDY SAVY
 LDA TDATA,Y
 JSR PRBYT
 JSR SPACE
 INC SAVY
 DEC SAVX
 BNE PRTDAL
 DEC CDATA
 BNE PRTNEX
;*********************************
 JMP XOP0
;*********************************
; READ DATA FOR KEYBOARD
;*********************************
NOTABS LDA #<MSA1 ;NUMBER OF DATA
 LDY #>MSA1
 JSR STRPNT
 JSR GETWRD ;INPUT HEX BYTE
 LDA ADRS ;GET BYTE
 STA NDATA ;SET NUM TABLES
 BNE AOPX ;0 DATA THEN END
 JMP XOP0 ;RETURN
AOPX LDA #$00 ;ZERO OFFSET
 STA CDATA ;FIRST TABLE
;*********************************
; CALCULATE TABLE OFFSET
;*********************************
AOP1 LDA CDATA ;GET TABLE NUMBER
 ASL A ;*2
 ASL A ;*4
 CLC ;C=0
 ADC CDATA ;*5
 STA SAVY ;STORE AS OFFSET
;*********************************
 LDA #<MSA2
 LDY #>MSA2
 JSR STRPNT ;PRINT MSG
 JSR GETWRD ;GET ADDRESS
 LDY SAVY ;GET OFFSET
 LDA ADRS
 STA TDATA,Y
 INY
 LDA ADRS+1
 STA TDATA,Y
 INY
 STY SAVY
;*********************************
; END OF DATA TABLE
;*********************************
AOP2 LDA #<MSA3
 LDY #>MSA3
 JSR STRPNT
 JSR GETWRD ;GET ADDRESS
 LDY SAVY
 LDA ADRS
 STA TDATA,Y
 INY
 LDA ADRS+1
 STA TDATA,Y
 INY
 STY SAVY
;*********************************
; GET TYPE OF TABLE
;*********************************
 LDA #<MSG5 ;TABLE TYPE
 LDY #>MSG5
 JSR STRPNT
AOP3 JSR GETIN
 BEQ AOP3
 CMP #'0'
 BEQ ASC
 CMP #'1'
 BEQ ASC
 CMP #'2'
 BEQ ASC
 CMP #'3'
 BEQ ASC
 CMP #'4'
 BEQ ASC
 CMP #'S'
 BNE AOP3
ASC JSR CHROUT
 LDY SAVY
 STA TDATA,Y
;*********************************
 INC CDATA ;INC TABLE COUNT
 LDA CDATA ;GET TABLE COUNT
 CMP NDATA ;ALL TABLES?
 BEQ XOP0 ;IF NOT GET MORE
 JMP AOP1 ;IF NOT GET MORE
;*********************************
; GET LABEL GENERATION OPTION
;*********************************
XOP0 LDA #<MSB4
 LDY #>MSB4
 JSR STRPNT
 JSR CRYS
 BCS XOP1
 LDA #$01
 BNE XOP2
XOP1 LDA #$00
XOP2 STA XOPT
;*********************************
; OUTPUT FORMAT OPTION
;*********************************
 LDA #<MSB5
 LDY #>MSB5
 JSR STRPNT
 JSR CRYS
 BCS FOP1
 LDA #$00
 BEQ FOP2
FOP1 LDA #$FF
FOP2 STA FOROPT
;*********************************
 RTS
;*********************************
;   COMMAND MESSAGES
;*********************************
MSG .TEXT $0D,$0D
.TEXT 'CBM RESIDENT DISASSEMBLER'
.TEXT ' V080282'
.BYTE $0D
.TEXT '(C) 1982 BY COMMODORE '
.TEXT 'BUSINESS MACHINES'
.BYTE $0D
.BYTE 0
;*********************************
MSF1 .BYTE $0D
.TEXT 'PROGRAM FILE (CR OR NAME):'
.BYTE 0
MSF2 .BYTE $0D
.TEXT 'PROGRAM ADDRESS: $'
.BYTE 0
;*********************************
MSG1 .BYTE $0D
.TEXT 'EDITOR64 FILE (CR OR NAME):'
.BYTE 0
;*********************************
WRITE .TEXT ',S,W'
PROGM .TEXT ',P,R'
INIT  .TEXT 'I0'
;*********************************
MSG2 .BYTE $0D
.TEXT 'HARD COPY (Y/CR OR N)? '
.BYTE 0
;*********************************
MSD1 .BYTE $0D
.TEXT 'START ADDRESS :$'
.BYTE 0
;*********************************
MSD2 .BYTE $0D
.TEXT 'END ADDRESS :$'
.BYTE 0
;*********************************
MSD4 .BYTE $0D
.TEXT 'ADDRESS OFFSET (OR CR):$'
.BYTE 0
;*********************************
MSD4A .BYTE $0D
.TEXT 'ADDRESS OFFSET :$'
.BYTE 0
;*********************************
MSD5 .BYTE $0D
.TEXT 'WINDOW OUTPUT(Y OR N/CR)? '
.BYTE 0
;*********************************
MSR1 .BYTE $0D
.TEXT 'RELATIVE BRANCH TO LABEL '
.TEXT '(Y/CR OR N)? '
.BYTE 0
;*********************************
MSB1 .BYTE $0D
 .TEXT 'BIT INSTRUCTION CODING'
 .BYTE $0D,$0D
 .TEXT '0/CR STANDARD',$0D
 .TEXT '1     $2C ABS',$0D
 .TEXT '2     $24 ZP',$0D
 .TEXT '3     $2C AND $24',$0D
 .BYTE $0D
 .TEXT 'ENTER BIT CODE: '
 .BYTE 0
;*********************************
MSAOP .BYTE $0D
.TEXT 'DATA TABLE FILE (CR OR NAME):'
.BYTE 0
MSA1 .BYTE $0D
.TEXT 'NUMBER OF DATA TABLES (OR CR) :$'
.BYTE 0
MSA2 .BYTE $0D
.TEXT 'TABLE START ADDRESS :$'
.BYTE 0
MSA3 .BYTE $0D
.TEXT 'TABLE END ADDRESS :$'
.BYTE 0
MSG5 .BYTE $0D,$0D
 .TEXT 'DISASSEMBLY OPTIONS'
 .BYTE $0D,$0D
 .TEXT '0 ASCII',$0D
 .TEXT '1 BYTE',$0D
 .TEXT '2 WORD',$0D
 .TEXT '3 DBYTE',$0D
 .TEXT '4 WORD-1',$0D
 .TEXT 'S SKIP ADDRESS RANGE',$0D
 .TEXT 'ENTER DISASSEMBLY CODE: '
 .BYTE 0
;*********************************
MSB4 .BYTE $0D
.TEXT 'LABLE GENERATION (Y/CR OR N)? '
.BYTE 0
;*********************************
MSB5 .BYTE $0D
.TEXT 'FORMATED LISTING (Y/CR OR N)? '
.BYTE 0
;*********************************
;.FIL 0:UTIL.ASM
;*********************************
.END