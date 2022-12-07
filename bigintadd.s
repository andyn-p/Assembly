    .section .rodata
    
    .section .data
    
    .section .bss
    
    .section .text
    
// BigInt_larger fn ----------------------------------------------------
    
    .equ TRUE, 1
    .equ FALSE, 0
    
    .equ BI_LARGER_STACK_SIZE, 32
    
    // params and local vars
    .equ lLength1, 8
    .equ lLength2, 16
    .equ lLarger, 24
    
BigInt_larger:

    // prolog
    sub     sp, sp, BI_LARGER_STACK_SIZE      
    str     x30, [sp]

    // store params
    str     x0, [sp, lLength1]
    str     x1, [sp, lLength2]
    
    // if (lLength1 <= lLength2) goto else1;
    cmp     x0, x1              // compare lLength1 and lLength2
    ble     else1               // goto else1 if lLength1 <= lLength2
    
    // lLarger = lLength1;
    ldr     x0, [sp, lLength1]  // place lLength1 val in x0
    str     x0, [sp, lLarger]   // store val in x0 in lLarger
    
else1:
    
    // lLarger = lLength2;
    ldr     x0, [sp, lLength2]  // place lLength2 val in x0
    str     x0, [sp, lLarger]   // store val in x0 in lLarger
    
return1:
    
    // return lLarger;
    ldr     x0, [sp, lLarger]   // place lLarger in x0 (return reg)
    add     sp, sp, BI_LARGER_STACK_SIZE // move sp back
    ret

    .size   BigInt_larger, (. - BigInt_larger)
    
// BigInt_add fn -------------------------------------------------------
    
    // stack size
    .equ BI_ADD_STACK_SIZE, 64
    
    // magic numbers
    .equ MAX_DIGITS, 32768
    .equ SIZE_OF_UL, 8
    
    // params and local vars
    .equ oAddend1, 8
    .equ oAddend2, 16
    .equ oSum, 24
    .equ ulCarry, 32
    .equ ulSum, 40
    .equ lIndex, 48
    .equ lSumLength, 56
    
    .global BigInt_add
    
BigInt_add:
    
    // prolog
    sub     sp, sp, BI_ADD_STACK_SIZE
    str     x30, [sp]
    
    // store params 
    str     x0, [sp, oAddend1]
    str     x1, [sp, oAddend2]
    str     x3, [sp, oSum]

    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [sp, oAddend1]      // load the addr of oAddend1->lLength (same as oAddend1) to x0
    ldr     x0, [x0]                // dereference x0 into x0

    ldr     x1, [sp, oAddend2]
    ldr     x1, [x1]                // do the same with oAddend2->lLength
    
    bl      BigInt_larger
    str     x0, [sp, lSumLength]
    
    // if (oSum->lLength <= lSumLength) goto skipif1;
    ldr     x0, [sp, oSum]          // load addr of oSum->length
    ldr     x0, [x0]                // dereference x0 into x0
    ldr     x1, [sp, lSumLength]    // load lSumLength into x1
    cmp     x0, x1                  // compare oSum's length and lSumLength
    ble     skipif1
    
    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    ldr     x0, [sp, oSum]          // load addr of oSum->length
    add     x0, x0, 8               // move past to aulDigits[0]
    mov     x1, MAX_DIGITS          // load MAX_DIGITS
    mov     x2, SIZE_OF_UL          // load SIZE_OF_UL
    mul     x2, x1, x2              // set 3rd param
    mov     x1, 0                   // set 2nd param
    bl memset
    
skipif1:
    // ulCarry = 0; lIndex = 0;
    mov     x0, 0                   // store 0 in x0
    str     x0, [sp, ulCarry]       // store val of x0 to ulCarry
    str     x0, [sp, ulSum]         // store val of x0 to ulSum

loop1: 
    // if (lIndex >= lSumLength) goto endloop1
    ldr     x0, [sp, lIndex]        // load value of lIndex to x0
    ldr     x1, [sp, lSumLength]    // load value of lSumLength to x1
    cmp     x0, x1                  // compare x0 and x1
    bge     endloop1                // if x0 greater or equal to x1, go to endloop1
    
    // ulSum = ulCarry; 
    ldr     x0, [sp, ulCarry]       // load the val of ulCarry to x0
    str     x0, [sp, ulSum]         // store the val of x0 to ulSum
    
    // ulCarry = 0;
    mov     x0, 0                   // store 0 in x0
    str     x0, [sp, ulCarry]       // store the val of x0 to ulCarry
    
    
    // ulSum += oAddend1->aulDigits[lIndex];
    ldr     x0, [sp, ulSum]         // load ulSum into x0
    ldr     x1, [sp, oAddend1]      // load addr of oAddend1->length
    add     x1, x1, 8               // move past to aulDigits[0]
    ldr     x2, [sp, lIndex]        // load lIndex addr into x2
    ldr     x1, [x1, x2, lsl 3]     // load aulDigits[lIndex] into x1
    add     x0, x0, x1              // add to ulSum
    str     x0, [sp, ulSum]         // store value back in ulSum

    // if (ulSum >= oAddend1->aulDigits[lIndex]) goto overflow1;
    ldr     x0, [sp, ulSum]         // load val of ulSum to x0
    ldr     x1, [sp, oAddend1]      // x1 store the addr of oAddend1->lLength
    add     x1, x1, 8               // x1 now is the addr of oAddend1->aulDigits[0]
    ldr     x2, [sp, lIndex]        // load val of lIndex to x2
    ldr     x1, [x1, x2, lsl 3]     // x1 is now val stored in oAddend1->aulDigits[lIndex]
    cmp     x0, x1                  // compare x0 and x1
    bge     overflow1               // if x0 bigger or equal to x1, go to overflow1
    
    // ulCarry = 1;
    mov     x0, 1                   // place 1 into x0
    str     x0, [sp, ulCarry]       // store x0 into ulCarry
    
overflow1:

    // ulSum += oAddend2->aulDigits[lIndex];
    ldr     x0, [sp, ulSum]         // load ulSum into x0
    ldr     x1, [sp, oAddend2]      // load oAddend->length addr
    add     x1, x1, 8               // move into oAddend->aulDigits
    ldr     x2, [sp, lIndex]        // load lIndex into x2
    ldr     x1, [x1, x2, lsl 3]     // load aulDigits[lIndex] into x1
    add     x0, x0, x1              // add to ulSum
    str     x0, [sp, ulSum]         // store value back in ulSum
    
    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto overflow2;
    ldr     x0, [sp, ulSum]         // load ulSum into x0
    ldr     x1, [sp, oAddend1]      // load oAddend->length addr
    add     x1, x1, 8               // move into oAddend->aulDigits
    ldr     x2, [sp, lIndex]        // load lIndex into x2
    ldr     x1, [x1, x2, lsl 3]     // laod aulDigits[lIndex] into x1 
    cmp     x0, x1                  // compare x0 and x1
    bge     overflow2               // goto overflow2 if x0 >= x1
    
overflow2:

    // oSum->aulDigits[lIndex] = ulSum;
    ldr     x0, [sp, oSum]          // load oSum->length addr
    add     x0, x0, 8               // move past to aulDigits
    ldr     x1, [sp, lIndex]        // load lIndex into x2
    ldr     x0, [x0, x1, lsl 3]     // move to oSum->aulDigits[lIndex]
    ldr     x1, [sp, ulSum]         // load ulSum into x1
    str     x1, x0                  // store ulSum into oSum->aulDigits[lIndex]

    // lIndex++;
    ldr     x0, [sp, lIndex]        // load val of lIndex into x0
    add     x0, x0, 1               // increment x0 by 1
    str     x0, [sp, lIndex]        // store val of x0 back to lIndex
    
    //goto loop1
    b       loop1                   // go to loop1       
    
endloop1:

    // if (ulCarry != 1) goto endif1;
    ldr     x0, [sp, ulCarry]       // load val of ulCarry to x0
    mov     x1, 1                   // set x1 = 1
    cmp     x0, x1                  // compare x0 and x1
    bne     endif1                  // if not equal go to endif1
    
    
    // if (lSumLength != MAX_DIGITS) goto skipif2;
    ldr     x0, [sp, lSumLength]    // load val of lSumLength to x0
    ldr     x1, MAX_DIGITS          // set x1 to be MAX_DIGITS
    cmp     x0, x1                  // compare x0 and x1
    bne     skipif2                 // if not equal go to skipif2
    
    
    // return FALSE;
    mov     x0, FALSE               // load FALSe into x0    
    ldr     x30, [sp]               // enter addr
    add     sp, sp, BI_ADD_STACK_SIZE   // move sp back
    ret
    
skipif2:
    // oSum->aulDigits[lSumLength] = 1;
    ldr     x0, [sp, lSumLength]    // load val of lSumLength to x0
    ldr     x1, [sp, oSum]          // load addr of oSum->lLength to x1
    add     x1, x1, 8               // now x1 is the addr of oSum->aulDigits[0]
    mov     x2, 1                   // let x2 = 1
    str     x2, [x1, x0, lsl 3]     // store x2 to oSum->aulDigits[lSumLength]


    // lSumLength++;
    ldr     x0, [sp, lSumLength]    // load lSumLength into x0
    add     x0, x0, 1               // add 1
    str     x0, [sp, lSumLength]    // store lSumLength
    
endif1:

    // oSum->lLength = lSumLength;
    ldr     x0, [sp, oSum]          // load oSum->length into x0
    ldr     x1, [sp, lSumLength]    // load lSumLength into x0
    str     x1, x0                  // store lSumLength in oSum->length
    
    // return TRUE;
    mov     x0, TRUE                // load TRUE into x0
    ldr     x30, [sp]               // enter addr
    add     sp, sp, BI_ADD_STACK_SIZE   // move sp back
    ret

    .size BigInt_add, (. - BigInt_add)
    
    
    