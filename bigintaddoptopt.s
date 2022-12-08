    .section .rodata
    
    .section .data
    
    .section .bss
    
    .section .text
    

// BigInt_add fn -------------------------------------------------------
    
    // enum
    .equ TRUE, 1
    .equ FALSE, 0
    
    // stack size
    .equ BI_ADD_STACK_SIZE, 80
    
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
    .equ oldx26, 64
    .equ oldx27, 72
    
    // regs for local vars
    lSumLength  .req x19
    lIndex      .req x20
    ulSum       .req x21
    oSum        .req x22
    oAddend1    .req x23
    oAddend2    .req x24
    oSumD       .req x25
    oAddend1D   .req x26
    oAddend2D   .req x27
    
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
    str     x26, [sp, oldx26]
    str     x27, [sp, oldx27]

    // store params 
    mov     oAddend1, x0
    mov     oAddend2, x1
    mov     oSum, x2
    
    add     oAddend1D, oAddend1, 8
    add     oAddend2D, oAddend2, 8
    add     oSumD, oSum, 8
    
    // lSumLength = BigInt_larger(oAddend1->lLength, oAddend2->lLength);
    ldr     x0, [oAddend1]          // deref
    ldr     x1, [oAddend2]          // deref
    cmp     x0, x1                  // compare lengths
    ble     lelse1                  // if <=, then lLength2 is bigger

    mov     lSumLength, x0          // lLength2 is bigger
    b       finish1                 // skip else
    
lelse1:

    mov     lSumLength, x1
    
finish1:
    
    // if (oSum->lLength <= lSumLength) goto skipif1;
    ldr     x0, [oSum]                      // deref oSum to get length
    cmp     x0, lSumLength                  // compare lengths
    ble     skipif1                         // decide if should memset
    
    // memset(oSum->aulDigits, 0, MAX_DIGITS * sizeof(unsigned long));
    mov     x0, oSumD                       
    mov     x1, 0
    mov     x2, MAX_DIGITS * SIZE_OF_UL
    bl      memset
    
skipif1:
    // lIndex = 0; ulSum = 0 <= initially
    mov     lIndex, 0                       
    mov     ulSum, 0

    // if (lIndex >= lSumLength) goto endloop1
    cmp     lIndex, lSumLength              // check lIndex < lSumLength
    bge     endif1                          // goto endif1


loop1:      
    // ulSum += oAddend1->aulDigits[lIndex];
    ldr     x0, [oAddend1D, lIndex, lsl 3]  // grab a1 val
    
    adcs    ulSum, ulSum, x0                // adds a1 and sets carry
    
    // ulSum += oAddend2->aulDigits[lIndex];
    ldr     x1, [oAddend2D, lIndex, lsl 3]  // grab a2 val
    
    bhs     add2                            // goto add2 if carry = 1
    adcs    ulSum, ulSum, x1                // add and set carry
    b       setsum    

// come here if oAddend1 doesnt produce carry
add2:
    add     ulSum, ulSum, x1                // add, do not set carry
    
setsum:
    // oSum->aulDigits[lIndex] = ulSum;
    str     ulSum, [oSumD, lIndex, lsl 3]   // store ulSum to x0

    // lIndex++;
    add     lIndex, lIndex, 1               // increment lIndex
    
    adcs    ulSum, xzr, xzr                 // ulSum = carry
    
    // if (lIndex < lSumLength) goto loop1
    cmp     lIndex, lSumLength              // check lIndex < lSumLength
    blt     loop1                           // goto loop1 if < 
    
endloop1:
    
    // if ulSum is not 1, meaning carry isnt 1, goto endif1
    cmp     ulSum, 1
    bne     endif1
    
    // if (lSumLength != MAX_DIGITS) goto skipif2;
    cmp     lSumLength, MAX_DIGITS          // check add didnt pass max
    bne     skipif2                         
    
    // restore the values and return FALSE;
    ldr     x19, [sp, oldx19]
    ldr     x20, [sp, oldx20]
    ldr     x21, [sp, oldx21]
    ldr     x22, [sp, oldx22]
    ldr     x23, [sp, oldx23]
    ldr     x24, [sp, oldx24]
    ldr     x25, [sp, oldx25]
    ldr     x26, [sp, oldx26]
    ldr     x27, [sp, oldx27]
    ldr     x30, [sp]                       // enter addr

    mov     x0, FALSE                        
    add     sp, sp, BI_ADD_STACK_SIZE       // move sp back
    ret
    
skipif2:
    // oSum->aulDigits[lSumLength] = 1;
    add     x0, oSum, 8             
    mov     x1, 1                   
    str     x1, [x0, lSumLength, lsl 3]

    // lSumLength++;
    add     lSumLength, lSumLength, 1  
    
endif1:

    // oSum->lLength = lSumLength;
    str     lSumLength, [oSum]              
    
    // return TRUE;
    ldr     x19, [sp, oldx19]
    ldr     x20, [sp, oldx20]
    ldr     x21, [sp, oldx21]
    ldr     x22, [sp, oldx22]
    ldr     x23, [sp, oldx23]
    ldr     x24, [sp, oldx24]
    ldr     x25, [sp, oldx25]
    ldr     x26, [sp, oldx26]
    ldr     x27, [sp, oldx27]
    
    mov     x0, TRUE                // load TRUE into x0
    ldr     x30, [sp]               // enter addr
    add     sp, sp, BI_ADD_STACK_SIZE   // move sp back
    ret

    .size BigInt_add, (. - BigInt_add)
    
    
    