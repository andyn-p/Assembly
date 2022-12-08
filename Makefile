GCC 	= gcc217
TARGETS = mywcc mywcs fibc fibs fib

FLAGS   =
FLAGS 	= -g
# FLAGS   = -D NDEBUG -O 
# FLAGS   = -pg

all: $(TARGETS)

clean:
	rm -f $(TARGETS)
	rm -f file1 file2

mywcc: mywc.c
	$(GCC) $^ -o $@

mywcs: mywc.s
	$(GCC) $^ -o $@

fibc: fib.c bigint.c bigintadd.c
	$(GCC) $(FLAGS) $^ -o $@
	
fibs: fib.c bigint.c bigintadd.s 
	$(GCC) $(FLAGS) $^ -o $@
	
fib: fib.c bigint.c bigintaddopt.s
	$(GCC) $(FLAGS) $^ -o $@