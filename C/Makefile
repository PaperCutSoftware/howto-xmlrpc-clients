.PHONEY: run

PROJECT:=simpleExample1
	
XMLRPC_FLAGS:=${shell xmlrpc-c-config client --cflags --libs}

CFLAGS+=$(XMLRPC_FLAGS)

run: $(PWD)/$(PROJECT)
	../server/server.py & \
	$< ;\
	kill %1

$(PROJECT): $(PROJECT).c
