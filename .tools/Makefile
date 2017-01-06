CC := g++

all:parse

%.o:%.cc
	$(CC) -c -o $@ $<

parse:main.o data_parser.o cf_utils.cc
	$(CC) $+ -o $@ 

clean:
	rm -f data_parser.o main.o cf_utils.o
	rm -f parse
