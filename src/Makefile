PROGRAMS    = easywall
easywall_LDFLAGS = 
easywall_LIBS = iptc
     
CFLAGS+=-I./include -DLINUX -Wall

easywall_OBJS = main.o
easywall_CFLAGS = -ggdb3 $(CFLAGS)

DEVELOPER_MODE=1
COLOURED_OUTPUT=1
SILENT_BUILD=1

include Makefile.rules


