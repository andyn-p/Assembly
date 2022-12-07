GCC 	= gcc217
TARGETS = mywcc mywcs

all: $(TARGETS)

clean:
	rm -f $(TARGET)

mywcc: mywc.c
	$(GCC) $^ -o $@

mywcs: mywc.s
	$(GCC) $^ -o $@

