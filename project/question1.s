; Emre Yigit - 150210715
				AREA     syst, CODE, READONLY
				EXPORT 	SysTick_Handler
SysTick_Handler	PROC
				; R5 is for counting if it reached to 4, meaning that counting a second.
				; R6 is for counting if it reached to 9, meaning that counting a loop until 9.
				CMP 	R5, #4 ; Check if it reached to 4
				BEQ 	Case1 ; If yes go Case1
SysTickEnd		
				LSLS R6, R6, #2 ; Multiply R6 by 4 in order to reach the correct index since it is 32 bit.
				LDR R3, [R4, R6] ; Load R3 which corresponds to PortB Data Out Register with the R6th value of LedList.
				STR R3, [R7, #0] ; Store R3 which is a LedList value at address R7 (0x20001000)
				ASRS R6, R6, #2 ; Divide R6 by 4 since we multiplied by 4 already.
				ADDS R5, R5, #1 ; Increase R5 by one
				BX	LR ; Return from interrupt subroutine.
Case1			
				MOVS R5, #0 ; Reset R5
				CMP R6, #9 ; Check if R6 reached 9
				BEQ Case2 ; If yes go Case 2
				ADDS R6,R6,#1 ; Else increase R6 by 1
				B SysTickEnd ; Branch to SysTickEnd

Case2			MOVS R6,#0 ; Reset R6
				B SysTickEnd ; Branch to SysTickEnd
				ENDP				
				
				AREA main, CODE, READONLY
				ENTRY
				THUMB
				EXPORT	__main
				ALIGN
__main			FUNCTION
				
				LDR R7, = 0x20001000 ; The address of PortB Data Out Register is saved at R7.
				LDR R4, = LedList ; The address of LedList is saved at R4.
				MOVS R6, #0 ; Start R0 from 0
				MOVS R5, #1 ; We need to start R5 from 1 to count correctly because we are updating R7 inside the interrupt.
				LDR R0, = 0xE000E010 ; SysTick Control and Status Register's address is saved at R0.
				LDR R1, = 11999999
		        ; We can not count a second using a 48 Mhz microcontroller since the limit is 2^24 which is smaller than
				; the value that we are required to use. So it will create interrupts every 250ms.
				; Period = (1+ReloadValue)/FrequencyOfCPU 1/4 = (1+ ReloadValue) / 48. 10^6  ReloadValue = 12.10^6 - 1 = 11999999
				STR R1, [R0, #4] ; Store Reload Value at SysTick Reload Value Register that has address 0xE000E014.
				MOVS R1, #0 ; Clear R1
				STR R1,[R0,#8] ; Clear Current Value Register at address 0xE000E018
				MOVS R1, #7 ; Set enable, clock and interrupt bits.
				STR R1, [R0] ; Store R1 at SysTick Control and Status Register.
loop			
				B		loop ; An infinite loop to keep the program.
				ENDFUNC
				
LedList			DCD 0x00004000, 0x00007900, 0x00002400, 0x00003000, 0x00001900, 0x00001200, 0x00000200, 0x00007800, 0x00000000, 0x00001000
				; An array to keep the port bit values for every number between 0-9. 
	
				END
