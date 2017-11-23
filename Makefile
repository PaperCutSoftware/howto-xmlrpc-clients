.SUFFIXES:

.PHONY: clean all tests tests-xml tests-python tests-java tests-go wc

# Clean up old server instances
KILLSERVER:=ps -u $(USER) | awk '/python.+server\.py/ {print "kill " $$2|"/bin/sh"}'

PROJECT := BlogPost

PANDOC_FLAGS :=--number-sections -s -smart -f markdown+startnum

DOCUMENTCLASS := article

IMAGES=diagram.png

pdf: $(PROJECT).pdf # Default
html: $(PROJECT).html
pmd: $(PROJECT).pmd

all: pdf html

clean:
	@-rm -vf $(PROJECT).{pdf,html,pmd}

%.pmd: %.m4 server/server.py ${glob xml/*.xml} python3/simpleExample1.py $(lastword $(MAKEFILE_LIST)) $(IMAGES)

%.pmd: %.m4
	$(KILLSERVER)
	server/server.py & \
	m4 -P $< > $@ ; \
	kill %1

%.png: %.plantuml
	plantuml -tpng $<

wc: $(PROJECT).pmd
	@echo Word count: $$(pandoc $(PANDOC_FLAGS) -t plain  $< | wc -w)

%.pdf: %.pmd
	pandoc $(PANDOC_FLAGS) -V documentclass=$(DOCUMENTCLASS) --toc $< -o $@

%.html: %.pmd
	pandoc $(PANDOC_FLAGS) $< -o $@

tests: tests-xml tests-python tests-java tests-go

tests-xml:
	$(KILLSERVER)
	server/server.py & find xml -name \*.xml -ls -exec curl -v http://localhost:8080/users --data @{} \; ; kill %1

tests-python:
	$(KILLSERVER)
	server/server.py & find python3 -name \*.py -ls -exec {} \; ; kill %1

tests-java:
	$(KILLSERVER)
	server/server.py & cd java && for i in *.build.gradle ; do ./gradlew -b $$i run;done; kill %1

tests-go:
	$(KILLSERVER)
	go get github.com/divan/gorilla-xmlrpc/xml
	server/server.py & find go -name \*.go -ls -exec go run {} \; ;kill %1

