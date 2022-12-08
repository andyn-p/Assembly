    .section .rodata
    
    .section .data
    
    .section .bss
    
    .section .text
    

// BigInt_add fn -------------------------------------------------------
    
    // enum
    .equ TRUE, 1
    .equ FALSE, 0
    
    // stack size
    .equ BI_ADD_STACK_SIZE, 64
    
    // magic numbers
    .equ MAX_DIGITS, 32768
    .equ SIZE_OF_UL, 8
    
    // callee stuff
    .equ oldx19, 8
    .equ oldx20, 16
    .equ oldx21, 24
    .equ oldx22, 32
    .equ oldx23, 40
    .equ oldx24, 48
    .equ oldx25, 56
    
    // regs for local vars
    lSumLength  .req x19
    lIndex      .req x20
    ulSum       .req x21
    ulCarry     .req x22
    oSum        .req x23
    oAddend1    .req x24
    oAddend2    .req x25
    
    
    .global BigInt_add
    
BigInt_add:
    
    // prolog
    sub     sp, sp, BI_ADD_STACK_SIZE
    str     x30, [sp]
    
    // store old reg vals
    str     x19, [sp, oldx19]
    str     x20, [sp, oldx20]
    str     x21, [sp, oldx21]
    str     x22, [sp, oldx22]
    str     x23, [sp, oldx23]
    str     x24, [sp, oldx24]
    str     x25, [sp, oldx25]

    // store params 
    mov     oAddend1, x0
    mov     oAddend2, x1
    mov     oSum, x2
    
    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [oAddend1]                // deref
    ldr     x1, [oAddend2]                // deref
    cmp     x0, x1                  // compare lengths
    ble     lelse1                  // if <=, then lLength2 is bigger

    mov     lSumLength, x0          // lLength2 is bigger
    b       finish1                 // skip past 
    
lelse1:

    mov     lSumLength, x1
    
finish1:
    
    // if (oSum->lLength <= lSumLength) goto skipif1;
    ldr     x0, [oSum]              // load val at addr of oSum->length to x0
    cmp     x0, lSumLength          // compare oSum's length and lSumLength
    ble     skipif1
    
    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    mov     x0, oSum                // load addr of oSum->length to x0
    add     x0, x0, 8               // move past to aulDigits[0]
    mov     x1, MAX_DIGITS          // load MAX_DIGITS
    mov     x2, SIZE_OF_UL          // load SIZE_OF_UL
    mul     x2, x1, x2              // set 3rd param
    mov     x1, 0                   // set 2nd param
    bl      memset
    
skipif1:
    // ulCarry = 0; lIndex = 0;
    mov     ulCarry, 0              // store 0 in ulCarry
    mov     lIndex, 0               // store 0 in lIndex


    // if (lIndex >= lSumLength) goto endloop1
    cmp     lIndex, lSumLength      // compare lIndex and lSumLength
    bge     endloop1                // if lIndex ge lSumLength, go to endloop1

loop1: 

    // ulSum = ulCarry; 
    mov     ulSum, ulCarry;         
    
    // ulCarry = 0;
    mov     ulCarry, 0              
    
    // ulSum += oAddend1->aulDigits[lIndex];
    add     x0, oAddend1, 8         // move x0 into oAddend1->aulDigits[0]
    lsl     x1, lIndex, 3           // lsl lIndex
    add     x0, x0, x1              // move x0 into oAddend1->aulDigits[lIndex]
    ldr     x0, [x0]                // deref
    add     ulSum, ulSum, x0        // add to ulSum

    // if (ulSum >= oAddend1->aulDigits[lIndex]) goto overflow1;
    cmp     ulSum, x0               // compare ulSum and x0
    bhs     overflow1               // if x0 bigger or equal to x1, go to overflow1
    
    // ulCarry = 1;
    mov     ulCarry, 1              
    
overflow1:

    // ulSum += oAddend2->aulDigits[lIndex];
    add     x0, oAddend2, 8         // move x0 into oAddend2->aulDigits[0]
    lsl     x1, lIndex, 3           // lsl lIndex
    add     x0, x0, x1              // move x0 into oAddend2->aulDigits[lIndex]
    ldr     x0, [x0]                // deref
    add     ulSum, ulSum, x0        // add to ulSum
    
    // if (ulSum >= oAddend2->aulDigits[lIndex]) goto overflow2;
    cmp     ulSum, x0               // compare ulSum and x0
    bhs     overflow2               // goto overflow2 if x0 >= x1
    
    // ulCarry = 1;
    mov     ulCarry, 1
    
overflow2:

    // oSum->aulDigits[lIndex] = ulSum;
    add     x0, oSum, 8             // put addr of oSum->aulDigits[0] to x0
    lsl     x1, lIndex, 3           // leftshift lIndex
    add     x0, x0, x1              // x0 is now at oSum->aulDigits[lIndex]
    str     ulSum, [x0]             // store ulSum to x0

    // lIndex++;
    add     lIndex, lIndex, 1       // increment lIndex
    
    // if (lIndex < lSumLength) goto loop1
    cmp     lIndex, lSumLength      // compare lIndex and lSumLength
    blt     loop1                   // if lIndex less than lSumLength, go to loop1     
    
endloop1:

    // if (ulCarry != 1) goto endif1;
    cmp     ulCarry, 1              // compare ulCarry to 1
    bne     endif1
    
    // if (lSumLength != MAX_DIGITS) goto skipif2;
    cmp     lSumLength, MAX_DIGITS  // compare lSumLength and MAX_DIGITS
    bne     skipif2                 // if not equal go to skipif2
    
    // restore the values and return FALSE;
    ldr     x19, [sp, oldx19]
    ldr     x20, [sp, oldx20]
    ldr     x21, [sp, oldx21]
    ldr     x22, [sp, oldx22]
    ldr     x23, [sp, oldx23]
    ldr     x24, [sp, oldx24]
    ldr     x25, [sp, oldx25]
    ldr     x30, [sp]               // enter addr

    mov     x0, FALSE               // load FALSe into x0    
    add     sp, sp, BI_ADD_STACK_SIZE   // move sp back
    ret
    
skipif2:
    // oSum->aulDigits[lSumLength] = 1;
    add     x0, oSum, 8             // put addr of oSum->aulDigits[0] to x0
    lsl     x1, lIndex, 3           // leftshift lIndex
    add     x0, x0, x1              // x0 is now at oSum->aulDigits[lIndex]
    mov     x1, 1                   // move 1 into x1
    str     x1, [x0]                // store 1 into memory addr in x0

    // lSumLength++;
    add     lSumLength, lSumLength, 1   // increment lSumLength
    
endif1:

    // oSum->lLength = lSumLength;
    str     lSumLength, [oSum]      // store lSumLength at oSum addr
    
    // return TRUE;
    ldr     x19, [sp, oldx19]
    ldr     x20, [sp, oldx20]
    ldr     x21, [sp, oldx21]
    ldr     x22, [sp, oldx22]
    ldr     x23, [sp, oldx23]
    ldr     x24, [sp, oldx24]
    ldr     x25, [sp, oldx25]
    
    mov     x0, TRUE                // load TRUE into x0
    ldr     x30, [sp]               // enter addr
    add     sp, sp, BI_ADD_STACK_SIZE   // move sp back
    ret

    .size BigInt_add, (. - BigInt_add)
    
    
    