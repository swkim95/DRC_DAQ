INSTALL_LIB = $(NKHOME)/lib
INSTALL_INC = $(NKHOME)/include

MODULE = NoticeIBS_SIPM_DAQ

OutPutOpt = -o #
CFLAGS = -I. -Wall -Wundef -Wunused -Wstrict-prototypes -Werror-implicit-function-declaration -Wno-pointer-sign -Wshadow -O2 -fPIC -m64

SOFLAGS = -shared -Wall
LDFLAGS = $(SOFLAGS)
LDLIBS = -L$(LIBUSB_LIB)
CC = gcc
LD = gcc

INCLUDE = $(MODULE).h 
OBJECT = $(MODULE).o
LIBRARY = lib$(MODULE).so

PROGRAMS = $(LIBRARY)

all: $(PROGRAMS)
clean:
	@rm -rf $(OBJECT) $(PROGRAMS)

$(LIBRARY): $(OBJECT)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) $(OutPutOpt) $@ $(EXPLLINKLIBS)

install: $(LIBRARY) $(INCLUDE)
	install $< $(INSTALL_LIB)
	install $(INCLUDE) $(INSTALL_INC)

#dependicies
$(OBJECT):$(INCLUDE)

