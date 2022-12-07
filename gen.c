#include <stdio.h>
#include <stdlib.h>

int main() {
    
    int i = 0;
    int mod = 0x7F;
    int val;
    int lineCount;
    
    for ( ; i < 50000; i++) {
        val = rand();
        val %= mod;
        if (val != 0x09 && val != 0x0A && (val <= 0x20 || val >= 0x7E)) {
            i--;
            continue;
        }
        printf("%c", val);
        if (val == '\n') lineCount++;
        if (lineCount == 1000) break;
    }
    
    return 0;
}