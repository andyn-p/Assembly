// rodata
    .section .rodata
printfFormatString:
    .string "%7ld %7ld %7ld\n"

// data
   .section .data
lLineCount:
    .quad 0
lWordCount:
    .quad 0
lCharCount:
    .quad 0
iInWord:
    .word FALSE

// bss
    .section .bss
iChar:
    .skip 4

// program
    .section .text

    .equ MAIN_STACK_BYTECOUNT, 16

    .equ EOF, -1
    .equ TRUE, 1
    .equ FALSE, 0

    .global main

main:
    // enter the stack
    sub     sp, sp, MAIN_STACK_BYTECOUNT
    str     x30, [sp]

loop1:
    // iChar = getchar(); if (iChar == -1) goto endloop1;
    bl      getchar             // execute getchar, places val in x0
    adr     x1, iChar           // puts iChar addr in x1
    str     w0, [x1]            // store x0 into iChar
    cmp     x1, EOF             // compares iChar to EOF, cmp val in x0
    beq     loop1End            // exits loop

    // lCharCount++;
    adr     x0,lCharCount       // place lCharCount addr in x0
    ldr     x1, [x0]            // load lCharCount val in x1
    add     x1, x1, 1           // add 1
    str     x1, [x0]            // store val in x1 into addr in x0


    // if (!isspace(iChar)) goto endif1;
    ldr     w0, [x1]            // place iChar val into x0
    bl      isspace             // calls isspace with param in x0
    cmp     w0, FALSE           // checks if isspace returned FALSE
    beq     endif1

    // if (!iInWord) goto endif2;
    adr     x0, iInWord         // place iInWord addr in x0
    ldr     x0, [x0]            // load inWord val into x0
    cmp     x0, FALSE           // compare x0 to FALSE
    beq     endif2

    // lWordCount++;
    adr     x0, lWordCount      // place lWordCount addr in x0
    ldr     x1, [x0]            // load lWordCount val in x1
    add     x1, x1, 1           // add 1
    str     x1, [x0]            // store val in x1 into addr in x0

    // iInWord = FALSE;
    adr     x0, iInWord         // place iInWord addr in x0
    mov     w1, FALSE           // place FALSE val in x1
    str     w1, [x0]            // place FALSE val in iInWord

endif1:
    // if(iInWord) goto endif2;
    adr     x0, iInWord         // place iInWord addr in x0
    ldr     x0, [x0]            // load iInWord val
    cmp     x0, TRUE            // compares to TRUE
    beq     endif2              // if equal go to endif2

    // iInWord = TRUE;
    adr     x0, iInWord         // place iInWord addr in x0
    mov     w1, TRUE            // place constant TRUE in w1
    str     w1, [x0]            // store w1 (TRUE) into the addr stored in x0(iInWord

endif2:
    // if (iChar != '\n') goto endif3;
    adr     x0, iChar           // place iChar addr in x0
    ldr     w0, [x0]            // place value of iChar in x0
    cmp     w0, '\n'            // compare w0 with'\n'
    bne     endif3              // if not equal go to endif

    // lLineCount++
    adr     x0, lLineCount      // place lLineCount addr in x0
    ldr     x1, [x0]            // load lLineCount val in x1
    add     x1, x1, 1           // add 1
    str     x1, [x0]            // store val in x1 into addr in x0

endif3:
    // goto loop1
    b       loop1

loop1End:
    // if (!iInWord) goto endif4;
    adr     x0, iInWord         // place iInWord addr in x0
    ldr     x0, [x0]            // load iInWord value into x0
    cmp     x0, FALSE           // compare with FALSE
    beq     endif4              // if equal to FALSE go to endif4

    // lWordCount++
    adr     x0, lWordCount      // place lWordCount addr in x0
    ldr     x1, [x0]            // place lWord val in x1
    add     x1, x1, 1           // add 1
    str     x1, [x0]              // store val in x1 into addr in x0

endif4:

    // load all params
    adr     x0, printfFormatString  // load format string into x0
    adr     x1, lLineCount          // place lLineCount addr in x1
    ldr     x1, [x1]                // place lLineCount val in x1
    adr     x2, lWordCount          // place lWordCount addr in x2
    ldr     x2, [x2]                // place lWordCount val in x2
    adr     x3, lCharCount          // place lCharCount addr in x3
    ldr     x3, [x3]                // place lCharCount val in x3

    bl      printf                  // calls printf

    mov     w0, 0                   // place 0 in w0
    ldr     x30, [sp]               // put sp addr in x30
    add     sp, sp, MAIN_STACK_BYTECOUNT
    ret                             // ret

    .size   main, (. - main)

