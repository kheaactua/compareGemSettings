.SUFFIXES : .o .f90 .ftn90 .F90
SHELL = /bin/bash

OPTIL?=2

# Are we in an Env Can environment?
ifeq (,$(BASE_ARCH))
FC:=pgfortran -O$(OPTIL)
else
ifeq "$(BASE_ARCH)" "$(EC_ARCH)"
$(error FATAL: EC_ARCH is equal to BASE_ARCH, no compiler architecture is defined, ABORTING)
endif
FC:=s.f90
endif

.PHONY: all
all: _readNamelist

.f90.o:
	${FC} -c $<
.F90.o:
	${FC} -c $<
.ftn90.o:
	${FC} -c $<

_readNamelist: readNamelist.o bidon.o
	${FC} -o $@ $^
	rm -f bidon.o readNamelist.f90

clean:
	rm -f readNamelist.o bidon.o comparenamelists.mod readNamelist.f90
