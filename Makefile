PROG=asmgrm
PROG_OBJS=asmgrm.o response.o permutations.o
PROG_LIBS=-lfcgi -lrt

TEST=test
TEST_OBJS=test.o permutations.o
TEST_LIBS=-lrt

SOCK=/tmp/asmgrm.sock
USER=www-data

SRCS=$(wildcard *.asm)

ASM=nasm
ASMFLAGS=-f elf64 -g

LD=ld
LINKER=/lib64/ld-linux-x86-64.so.2
LDFLAGS=-s -m elf_x86_64 -dynamic-linker $(LINKER)

all: $(PROG) $(TEST)

run: $(PROG)
	sudo -u$(USER) killall $(PROG); \
	sudo service nginx stop; \
	sudo rm $(SOCK); \
	sudo -u$(USER) spawn-fcgi -s $(SOCK) -u $(USER) $(PROG) && \
	sudo service nginx start

$(PROG): $(PROG_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(PROG_LIBS)

$(TEST): $(TEST_OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(TEST_LIBS)

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $^

clean:
	rm $(PROG) $(PROG_OBJS) $(TEST) $(TEST_OBJS)
