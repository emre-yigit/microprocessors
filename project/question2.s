; Emre Yigit - 150210715
SIZE	  EQU	0x32 ; Size of the array is defined 

		  AREA quicksort, CODE, READONLY ; Define this part will write as code
		  ENTRY
		  THUMB
		  ALIGN
__main    FUNCTION
		  EXPORT __main
		  LDR R3, =array; Pointer for array
		  B defineNumbers ; It is called with B because it will call quicksort

defineNumbers
		  MOVS R2, #0 ; R2 corresponds to temp
		  MOVS R1, #0 ; R1 corresponds to i

defloop   CMP R1, #SIZE ; Compare i and SIZE
		  BGE defloopend ; Leave the loop if it reaches the last element of the array.
		  ADDS R1, R1, #15 ; i = i+15 
		  MOVS R2, R1 ; temp = i
		  SUBS R1, R1, #15; i = i-15

		  LSLS R0, R2, #5 ; temp << 5 
		  EORS R2, R2, R0 ; Xor temp with temp << 5

		  ASRS R0, R2, #4 ; temp >> 4 
		  EORS R2, R2, R0 ; Xor temp with temp >> 4

		  LSLS R0, R2, #1 ; temp << 1 
		  EORS R2, R2, R0 ; Xor temp with temp << 1
		  ; All index values will be multiplied by 4 since we keep 32 bit integer values.
		  LSLS R1,R1, #2 ; i = i*4
		  STR R2,[R3, R1] ; Store temp at i'th index of array
		  ASRS R1,R1, #2 ; i = i/4
		  ADDS R1, R1, #1 ; i = i+1
		  B defloop ; continue to loop

defloopend
		  MOVS R1, #0 ; R1 = 0 means that l = 0
		  MOVS R2, #SIZE ; R2 = SIZE
		  SUBS R2, R2, #1 ; R2 = SIZE - 1
		  BL quickSortL ; Call quicksort

finish	  B finish ; This line corresponds to while(1);

quickSortL ; It is a code to keep the return address before entering to recursion.
		  PUSH{LR} ; We push LR to stack in order to keep the return address.
		  B quickSort ; Branch quickSort
quickSort 
		  CMP R1, R2 ; Compare l and h
		  BGE endQuickSort ; Branch endQuickSort if l is greater or equal to h
		  PUSH {R1} ; Push R1 to the stack in order to keep the old value of R1.
		  PUSH {R2} ; Push R2 to the stack in order to keep the old value of R2.
		  BL partition ; Call partition function
		  ; R0 equals to p_index after the execution of partition funciton 
		  POP {R2} ; Pop h value to R2
		  POP {R1} ; Pop l value to R1
		  PUSH{R1} ; Push R1 to the stack in order to keep the old value of R1 after recursion.
		  PUSH{R2} ; Push R2 to the stack in order to keep the old value of R1 after recursion.
		  PUSH{R0} ; Push R0 to the stack in order to keep the old value of R1 after recursion.
		  SUBS R0, R0, #1 ; p_index = p_index-1
		  MOVS R2, R0 ; R2 is the second parameter of quicksort which is p_index - 1
		  BL quickSortL ; Branch quicksort with LR
		  POP{R0}; Pop p_index value to R0
		  POP{R2} ; Pop h value to R2
		  POP{R1} ; Pop l value to R1
		  ADDS R0, R0, #1 ; p_index = p_index + 1
		  MOVS R1, R0; R1 = p_index 
		  BL quickSortL ; We increased by 1 and moved R0 to R1, since it is the first parameter of quicksort function.

endQuickSort
		  POP{R0} ; Pop LR value from the stack in order to return to return address.
		  BX R0 ; Return to the address at R0.

partition
		  PUSH{R4}
		  PUSH{R5}
		  ; In order to not lose the values at registers R4, R5, R6 and R7
		  ; we pushed them onto the stack to keep the previous values after execution.
		  PUSH{R6}
		  PUSH{R7}
		  LSLS R2,R2, #2 ; h = h*4 (index)
		  ; Lines below are the operations done with C++ in the psudoecode.
		  LDR R4, [R3, R2] ; p = arr[h] 
		  ASRS R2,R2, #2 ; h = h/4
		  MOVS R5, R1 ; i = l
		  SUBS R5, R5, #1 ; i = l - 1
		  MOVS R6, R1 ; j = L

partLoop  CMP R6, R2 ; compare j and h
		  BGE partLoopEnd ; branch partLoopEnd if GE
		  LSLS R6,R6, #2; j = j*4
		  LDR R7, [R3,R6] ; R7 = arr[j]
		  ASRS R6,R6, #2 ; j = j/4
		  ADDS R6, R6, #1 ; j++ We multiply j by 4 before reaching to array index. We don't need to add 4.
		  CMP R7, R4 ; Compare arr[j] and p
		  BGE partLoop ; branch partLoop if GE
		  SUBS R6, R6, #1 ; j = j-1 (since we increased j by 1)
		  ADDS R5, R5, #1 ; i++
		  LSLS R5,R5, #2 ; i = i*4
		  LSLS R6,R6, #2 ; j = j*4
		  LDR R1, [R3,R5]; R1 = arr[i]
		  STR R7, [R3,R5] ; arr[i] = R7 (arr[j]) 
		  STR R1, [R3, R6] ; arr[j] = R1 (arr[i])
		  ; Swapping is done inline in order to avoid calling a subroutine.
		  ; Doing it inline will make it faster since it does not use the stack.
		  ASRS R5, R5, #2 ; i = i/4
		  ASRS R6,R6, #2 ; j = j/4
		  ADDS R6, R6, #1 ; j++
		  B partLoop ; branch to loop
		  
partLoopEnd
		  ADDS R5, R5, #1 ; i++
		  LSLS R5,R5, #2 ; i = i*4
		  LDR R7,[R3, R5] ; R7 = arr[i]
		  LSLS R2, R2, #2 ; h = h*4
		  LDR R1, [R3, R2] ; R1 = arr[h]
		  STR R1, [R3, R5] ; arr[i] = R1
		  STR R7, [R3, R2] ; arr[h] = R7
		  ; Swapping is done inline in order to avoid calling a subroutine.
		  ; Doing it inline will make it faster since it does not use the stack.
		  ASRS R5, R5, #2 ; i = i/4
		  ASRS R2,R2, #2 ; h = h/4
		  MOVS R0, R5 ; R0 = R5
		  POP{R7} 
		  POP{R6}
		  ; Pop the previous register values which we already pushed onto stack to keep their old values.
		  POP{R5}
		  POP{R4}
		  BX LR ; Return to address pointed by R1
		  ALIGN
		  ENDFUNC
 AREA array_mem, DATA, READWRITE
array SPACE SIZE * 4 ; Zero initialized integer array
		  END