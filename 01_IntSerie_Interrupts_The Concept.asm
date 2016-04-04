;----------11 modules to guide you in coding with assembler----------
;See: https://www.youtube.com/playlist?list=PLK3PeNcUzb8SyT-XNAoFc4M60Z2v60fsa
;---1. Cataloguing ---
;
; * Project name: 01 # IntSerie - Interrupts - The Concept!!!
;    Interrupt_HelloWorld.asm
; *  Copyright: (http://www.mstracey.btinternet.co.auk/index.htm)
; * Revision History:
;     20160402:
;       - initial release;
; * Description:
;     This code demonstrates how to program interrupt in PIC16F628A.
;     We are going to count the number of times we turn a switch on, 
;     and then display the number. The program will count from 0 to 9,
;     displayed on 4 LEDs in binary form, and the input or interrupt 
;     will be on RB0. We hope you enjoy learning this in pic !!!
; * Test configuration:
;     MCU:            PIC16F628A @ 4MHz
;                     http://www.microchip.com/wwwproducts/en/en010210
;     Rec.Board:      PicKit3
;                     PicKit3 - http://www.microchip.com/pagehandler/...
;     Oscillator:     4.0000 MHz Crystal
;     Proteus test:   interrupt_study.pdsprj
;     SW:             MPLAB X IDE v3.20
;                     http://www.microchip.com/mplab/mplab-x-ide
; * NOTES: based on Tutorial 12 from
;   http://groups.csail.mit.edu/lbr/stack/pic/pic-prog-assembly.pdf
;   You.tube : https://www.youtube.com/playlist?list=PLK3PeNcUzb8SyT-XNAoFc4M60Z2v60fsa
; * Date : april, 2016 
;*/
 
;---2. Mcu  & Frequency---   
    #define _XTAL_FREQ 4000000	    ; set primary frequency
    list		p=16F628    ; microcontroller used   

;---3. Files included in the Project ---
    #include "p16F628A.inc"	    ;It includes PIC16Fxxx file

;---4. Configuration bits ---
; __config 0x3F29
 __CONFIG _FOSC_XT & _WDTE_OFF & _PWRTE_OFF & _MCLRE_ON & _BOREN_OFF & _LVP_OFF & _CPD_OFF & _CP_OFF

 ;---5. Paging Memory --- 
    #define		bank0		bcf STATUS,RP0  ;Create a mnemonic for the bank 0 of memory
    #define		bank1		bsf STATUS,RP0	;Create a mnemonic for the bank 1 of memory

;---6. Variables & Constants --- 
    cblock		H'20'
    COUNT			    ;This will be our counting variable
    TEMP			    ;Temporary store for w register
    endc

;---7. Inputs --- 
      
;---8. Outputs --- 
    
;---9. Interrupt Routines ---
    org			H'00'	    ;Origin in the address 0000h memory
    goto		main	    ;Deviate from the interrupt vector	
    
    org			H'04'	    ;This is where PC points on an interrupt
    movwf		TEMP	    ;Store the value of w temporarily
    incf		COUNT,1	    ;Increment COUNT by 1, and put the result
				    ;back into COUNT
    movlw		H'0A'	    ;Move the value 10 into w
    subwf		COUNT,0	    ;Subtract w from COUNT, and put the
				    ;result in w
    btfss		STATUS,0    ;Check the Carry flag. It will be set if
				    ;COUNT is equal to, or is greater than w,
				    ;and will be set as a result of the subwf
				    ;instruction
    goto		carry_on    ;If COUNT is <10, then we can carry on
    goto		clear	    ;If COUNT is >9, then we need to clear it
    
carry_on:
    bcf			INTCON,INTF ;We need to clear this flag to enable
				    ;more interrupts
    movfw		TEMP	    ;Restore w to the value before the interrupt
    				
    retfie			    ;Come out of the interrupt routine
clear:
    clrf		COUNT	    ;Set COUNT back to 0
    bcf			INTCON,INTF ;We need to clear this flag to enable
				    ;more interrupts
    retfie			    ;Come out of the interrupt routine  
				     
;---10. Business Rules Code ---
main:
    bank1			    ;Selects bank 1 memory
    movlw		H'00'	    ;W = B'00000000'
    movwf		TRISA	    ;TRISA = H'00' (all bits are output)
    movlw		H'FF'	    ;W = B'11111111'				
    movwf		TRISB	    ;TRISB = H'FF' (all bits are imput)
    bank0			    ;selects the bank 0 of memory (RESET of default)
    movlw		H'07'		
    movwf		CMCON	    ;Disable the comparators
    movlw		H'10'	    ;W = B'11110101'		        
    movwf		PORTB	    ;LEDs start off
    
;*******************Set Up The Interrupt Registers****
    bsf			INTCON,GIE  ;GIE ? Global interrupt enable (1=enable)
    bsf			INTCON,INTE ;INTE - RB0 Interrupt Enable (1=enable)
    bcf			INTCON,INTF ;INTF - Clear FLag Bit Just In Case

;*******************Now Send The Value Of COUNT To Port A			
				
loop:				    ;Infinite Loop

    movf		COUNT,0	    ;Move the contents of Count into W
    movwf		PORTA	    ;Now move it to Port A
    goto		loop	    ;Keep on doing this
   			
		end      	    ;Program end
