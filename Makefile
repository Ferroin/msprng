.PHONY: clean

CC := gcc
CFLAGS := -O3

msprng.ihx : msprng.o
	msp430-objcopy -O ihex msprng.o msprng.ihx

msprng.o : msprng.s
	msp430-as -agl=msprng.list -mcpu=430 -mmpy=none -o msprng.o msprng.s

algotest : algotest.c
	$(CC) $(CFLAGS) -o algotest algotest.c

dieharder.txt : algotest
	./algotest < /dev/random | dieharder -g 200 -a -k 2 -Y 1 -m 10 | tee dieharder.txt

fips.txt : algotest
	./algotest < /dev/random | rngtest -c 1048576 | tee fips.txt

clean :
	rm -f msprng.ihx msprng.o msprng.list algotest
