GCC 	= gcc217
TARGETS = mywcc mywcs fib

# FLAGS   = -D NDEBUG -O 
FLAGS   = -pg

all: $(TARGETS)

clean:
	rm -f $(TARGETS)

mywcc: mywc.c
	$(GCC) $^ -o $@

mywcs: mywc.s
	$(GCC) $^ -o $@

fib: fib.c bigint.c bigintadd.c
	$(GCC) $(FLAGS) $^ -o $@