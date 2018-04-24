;*********************************; FILE INTERNAL.ASM;*********************************;;        DISASSEMBLER128;    SYMBOLIC DISASSEMBLER;       BY DENTON MARLOWE;;  (C)1986 BY DENTON MARLOWE;;*********************************; INTERNAL ADDRESS TABLE ROUTINES;*********************************; CHECK FOR OUT OF RANGE ADDRESS;*********************************RANGE LDA WORKED+1 ;GET HIGH CMP EAGOL+1 ;COMPARE BCC RANG ;< CHECK START BNE ROUT ;> OUT OF RANGE LDA WORKED ;GET LOW CMP EAGOL ;COMPARE BCS ROUT ;> OUT OF RANGE;*********************************RANG LDA WORKED+1 ;GET HIGH CMP SAGOL+1 ;COMPARE BCC ROUT ;< OUT OF RANGE LDA WORKED ;GET LOW CMP SAGOL ;COMPARE BCC ROUT ;< OUT OF RANGE;********************************* CLC ;C=0 IN RANGE RTSROUT SEC ;C=1 OUT RANGE RTS;*********************************; INITIALIZE INTERNAL TABLE;*********************************INITIN LDA DATABE STA TABINS STA TABINE LDA DATABE+1 STA TABINS+1 STA TABINE+1;*********************************; INITIALIZE INTERNAL TABLE POINT;*********************************INTSET LDA TABINS STA TABINP LDA TABINS+1 STA TABINP+1 RTS;*********************************; SAVE INTERNAL TABLE POINTERS;*********************************SAVINT LDA TABINS STA SAVES LDA TABINS+1 STA SAVES+1 LDA TABINE STA SAVEE LDA TABINE+1 STA SAVEE+1 RTS;*********************************; RESTORE INTERNAL TABLE POINTERS;*********************************RESINT LDA SAVES STA TABINS LDA SAVES+1 STA TABINS+1 LDA SAVEE STA TABINE LDA SAVEE+1 STA TABINE+1 RTS;*********************************; PUT ADDRESS IN INTERNAL TABLE;*********************************PUTI SEC     LDA TABINS     SBC TABINE     STA TEMP     LDA TABINS+1     SBC TABINE+1     ORA TEMP     BEQ PUIT;     JSR INTCHK     ;IS ADDRESS IN TAB     BCS INTEXT     ;IF SO EXIT;PUIT LDA TABINE     ;GET LOW END     STA ZEROUR     ;STORE     LDA TABINE+1   ;GET HIGH END     STA ZEROUR+1   ;STORE     LDY #$00       ;OFFSET     LDA WORKED     ;GET LOW ADDRESS     STA (ZEROUR),Y ;PUT IN TABLE     INY            ;OFFSET TO HIGH     LDA WORKED+1   ;GET HIGH ADDRESS     STA (ZEROUR),Y ;PUT IN TABLE;     JSR SEMIC      ;PRINT ;     JSR PWORKD     ;PRINT ADDRESS;*********************************     JSR INCIE      ;INC TO HIGH & LOW     JMP INCIE      ;INC TO HIGH & LOW;INTEXT = *     CLC            ;C=0 FOR NO MATCH     RTS            ;RETURN;*********************************; INC INTERNAL END TABLE POINTER;*********************************INCIE INC TABINE BNE *+5 INC TABINE+1;*********************************; INC INTERNAL ADDRESS POINTER;*********************************INCI INC TABINP BNE *+5 INC TABINP+1 RTS;*********************************; GET BYTE FROM INTERNAL TABLE;*********************************GETI LDA TABINP STA ZEROUR LDA TABINP+1 STA ZEROUR+1 LDY #$00 LDA (ZEROUR),Y RTS;*********************************; CHECK IF ADDRESS IN TABLE;*********************************INTCHA LDA SELECT STA WORKED LDA SELECT+1 STA WORKED+1;*********************************INTCHK JSR INTSETINTCH  JSR GETI STA WORKER JSR INCI JSR GETI STA WORKER+1 SEC LDA WORKED+1 SBC WORKER+1 STA TEMP LDA WORKED SBC WORKER ORA TEMP BEQ INTMAT;********************************* JSR INCI LDA TABINP+1 CMP TABINE+1 BCC INTCH BNE INTEND LDA TABINP CMP TABINE BCC INTCH;*********************************INTEND CLC RTSINTMAT SEC RTS;*********************************; 2 BYTE TABLE SORT ROUTINE;*********************************SORT JSR INTSET ;SET POINTERS LDA TABINS STA SMALLS STA SMALLP LDA TABINS+1 STA SMALLS+1 STA SMALLP+1;*********************************; PUT FIRST WORD INTO TEMP;*********************************SORT1 JSR GETI STA TEMP JSR INCI JSR GETI STA TEMP+1;*********************************; INC TO NEXT WORD AND COMPARE; SMALLP POINTS TO LOW BYTE;*********************************SORT2 JSR INCI LDA TABINP STA SMALLP LDA TABINP+1 STA SMALLP+1 JSR GETI STA WORKED JSR INCI LDA TABINP+1 CMP TABINE+1 BCC T2 BNE S3 LDA TABINP CMP TABINE BCC T2S3 JMP SORT3T2 JSR GETI STA WORKED+1 CMP TEMP+1 BCC SMALL BNE LARGE LDA WORKED CMP TEMP BCC SMALLLARGE JMP SORT2;*********************************; WORD IS SMALL THAN TEMP PUT IT; WHERE TEMP CAME FROM (SMALLS);*********************************SMALL LDA SMALLS STA ZEROUR LDA SMALLS+1 STA ZEROUR+1 LDY #$00 LDA WORKED STA (ZEROUR),Y INY LDA WORKED+1 STA (ZEROUR),Y;*********************************; PUT TEMP IN PLACE OF WORD; SMALLP POINTS TO LO ADDRESS;********************************* LDA SMALLP STA ZEROUR LDA SMALLP+1 STA ZEROUR+1 LDY #$00 LDA TEMP STA (ZEROUR),Y INY LDA TEMP+1 STA (ZEROUR),Y;********************************* LDA SMALLS STA TABINP LDA SMALLS+1 STA TABINP+1 JMP SORT1;*********************************; IF AFTER SCAN TO TABLE GOTO NEXT; WORD IN TABLE FOR CHECK;*********************************SORT3 CLC LDA SMALLS ADC #$02 STA SMALLS STA TABINP LDA SMALLS+1 ADC #$00 STA SMALLS+1 STA TABINP+1 LDA SMALLS+1 CMP TABINE+1 BCC SORTOK BNE SORT4 LDA SMALLS CMP TABINE BCS SORT4SORTOK JMP SORT1;*********************************SORT4 JMP INTSET;*********************************; PRINT INTERNAL ADDRESS TABLE;*********************************INTPRT SEC LDA TABINS SBC TABINE STA TEMP LDA TABINS+1 SBC TABINE+1 ORA TEMP BNE INTOUT RTS;*********************************INTOUT JSR HEADSY JSR SORT;*********************************LOOP1 LDA #$03 STA SAVAINTPR JSR GETI STA WORKED JSR INCI JSR GETI STA WORKED+1 JSR SPACE JSR SYMOP BCC INTPRS JSR FIXSYM LDA #$02 JSR SPACM JMP INTPRMINTPRS LDA #$08 JSR SPACMINTPRM JSR PWORKD JSR INCI LDA TABINP+1 CMP TABINE+1 BCC PRTOK BNE PREND LDA TABINP CMP TABINE BCS PRENDPRTOK DEC SAVA BMI LOOP2 LDA #$02 JSR SPACM JMP INTPRPREND JMP NEXPTSLOOP2 JSR NEXPTS JMP LOOP1;*********************************;.FIL 0:ASC.ASM;*********************************.END