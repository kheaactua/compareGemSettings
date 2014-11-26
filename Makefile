.SUFFIXES: .f90

#FC:=gfortran -cpp
FC:=pgfortran -Mpreprocess

.PHONY: all
all: _readNamelist

.f90.o:
	${FC} -c $<

_readNamelist: readNamelist.o bidon.o
	${FC} -o $@ $^

clean:
	rm -f readNamelist.o bidon.o comparenamelists.mod
