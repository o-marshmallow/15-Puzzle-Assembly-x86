CC=gcc
CFLAGS=-nostdlib -m32 -g
BIN=game

all: *.s
	gcc -o $(BIN) $^ $(CFLAGS)
