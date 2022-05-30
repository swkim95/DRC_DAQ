NOTICE_LIB = $(NKHOME)/lib
NOTICE_INC = $(NKHOME)/include

INSTALL_LIB = $(NKHOME)/lib
INSTALL_INC = $(NKHOME)/include

RC     := root-config
ifeq ($(shell which $(RC) 2>&1 | sed -ne "s@.*/$(RC)@$(RC)@p"),$(RC))
MKARCH := $(wildcard $(shell $(RC) --etcdir)/Makefile.arch)
endif
ifneq ($(MKARCH),)
include $(MKARCH)
else
ROOTSYS = ..
include $(ROOTSYS)/etc/Makefile.arch
endif
-include ../MyConfig.mk

#------------------------------------------------------------------------------

SrcSuf = cc
HdrSuf = h
ObjSuf = o
DllSuf = so
OutPutOpt = -o #keep the space after the option "-o"

CXXFLAGS += -I. -I$(LIBUSB_INC) -I$(NOTICE_INC)
ifneq ($(DEBUG),)
CXXFLAGS += -g
endif

#LDFLAGS += -L$(LIB_nkusb) -lnkusb -shared -Wall,-soname
SOFLAGS += -Wall
LDFLAGS = $(SOFLAGS)
#LDLIBS =  -L$(LIBUSB_LIB) -lusb-1.0 -L$(NOTICE_LIB)
LDLIBS =  -L$(NOTICE_LIB) -lNoticeIBS_SIPM_DAQ

SOURCE = NoticeIBS_SIPM_DAQROOT.$(SrcSuf) NoticeIBS_SIPM_DAQROOTDict.$(SrcSuf)
INCLUDE = NoticeIBS_SIPM_DAQROOT.$(HdrSuf) LinkDef.h
OBJECT = $(SOURCE:.cc=.o)
LIBRARY = libNoticeIBS_SIPM_DAQROOT.$(DllSuf)

all: $(LIBRARY)
clean:
	@rm -rf $(LIBRARY) $(OBJECT) *Dict.$(SrcSuf) *Dict.$(HdrSuf)

install: $(LIBRARY) NoticeIBS_SIPM_DAQROOT.h
	#/bin/rm -f $(INSTALL_LIB)/$<
	#/bin/rm -f $(INSTALL_INC)/NoticeIBS_SIPM_DAQROOT.h
	install $< $(INSTALL_LIB)
	install NoticeIBS_SIPM_DAQROOT.h $(INSTALL_INC)

$(LIBRARY): $(OBJECT)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) $(OutPutOpt) $@

NoticeIBS_SIPM_DAQROOTDict.$(SrcSuf): $(INCLUDE) LinkDef.h
	@echo "Generating dictionary $@..."
	$(ROOTCINT) -f $@ -c -I$(NOTICE_INC) $^

#dependicies
$(OBJECT):$(INCLUDE)
