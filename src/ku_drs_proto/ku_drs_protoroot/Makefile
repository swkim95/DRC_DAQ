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

SOFLAGS += -Wall
LDFLAGS = $(SOFLAGS)
LDLIBS =  -L$(NOTICE_LIB) -lNoticeKU_DRS_PROTO

SOURCE = NoticeKU_DRS_PROTOROOT.$(SrcSuf) NoticeKU_DRS_PROTOROOTDict.$(SrcSuf)
INCLUDE = NoticeKU_DRS_PROTOROOT.$(HdrSuf) LinkDef.h
OBJECT = $(SOURCE:.cc=.o)
LIBRARY = libNoticeKU_DRS_PROTOROOT.$(DllSuf)

all: $(LIBRARY)
clean:
	@rm -rf $(LIBRARY) $(OBJECT) *Dict.$(SrcSuf) *Dict.$(HdrSuf)

install: $(LIBRARY) NoticeKU_DRS_PROTOROOT.h
	install $< $(INSTALL_LIB)
	install NoticeKU_DRS_PROTOROOT.h $(INSTALL_INC)

$(LIBRARY): $(OBJECT)
	$(LD) $(LDFLAGS) $^ $(LDLIBS) $(OutPutOpt) $@

NoticeKU_DRS_PROTOROOTDict.$(SrcSuf): $(INCLUDE) LinkDef.h
	@echo "Generating dictionary $@..."
	$(ROOTCINT) -f $@ -c -I$(NOTICE_INC) $^

#dependicies
$(OBJECT):$(INCLUDE)
