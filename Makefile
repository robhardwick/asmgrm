PROG=asmgrm
SOCK=/tmp/asmgrm.sock
USER=www-data

SRCS=$(wildcard *.asm)
OBJS=$(SRCS:%.asm=%.o)

ASM=nasm
ASMFLAGS=-f elf64

LD=ld
LINKER=/lib64/ld-linux-x86-64.so.2
LDFLAGS=-s -m elf_x86_64 -dynamic-linker $(LINKER)
LIBS=-lfcgi -lrt

all: $(PROG)

run: $(PROG)
	sudo -u$(USER) killall attoblog; \
	sudo service nginx stop; \
	sudo rm $(SOCK); \
	sudo -u$(USER) spawn-fcgi -s $(SOCK) -u $(USER) $(PROG) && \
	sudo service nginx start

$(PROG): $(OBJS)
	$(LD) $(LDFLAGS) -o $@ $^ $(LIBS)

%.o: %.asm
	$(ASM) $(ASMFLAGS) -o $@ $^

clean:
	rm $(PROG) $(OBJS)
