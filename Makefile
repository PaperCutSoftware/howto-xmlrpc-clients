.SUFFIXES:

TESTS:="tests-c tests-php tests-xml tests-python tests-java tests-go"

.PHONY: clean all tests wc pdf html plain pmd $(TESTS) tests-all

# Clean up old server instances
${shell ps -u $(USER) | awk '/python.+server\.py/ {print "kill " $$2|"/bin/sh"}'}

PROJECT:=BlogPost

PANDOC_FLAGS:=--number-sections -s -f markdown+startnum+smart

THISMAKEFILE:=$(lastword $(MAKEFILE_LIST))

DOCUMENTCLASS:=article

IMAGES:=diagram.png

pdf: $(PROJECT).pdf # Default target
all: pdf html

html: $(PROJECT).html
pmd: $(PROJECT).pmd
plain: $(PROJECT).txt
word: $(PROJECT).docx

clean:
	@-rm -vf $(PROJECT).{pdf,html,pmd,docx} diagram.png

%.pmd: %.m4 server/server.py ${glob xml/*.xml} python3/simpleExample1.py $(THISMAKEFILE)
	server/server.py & \
	m4 -P $< > $@ ; \
	kill %1

%.png: %.plantuml
	plantuml -tpng $<

wc: $(PROJECT).pmd
	@echo Word count: $$(pandoc $(PANDOC_FLAGS) -t plain  $< | wc -w)

%.docx: %.pmd $(IMAGES) $(THISMAKEFILE)
	pandoc $(PANDOC_FLAGS) $< -o $@

%.txt: %.pmd $(THISMAKEFILE)
	pandoc $(PANDOC_FLAGS) -t plain $< -o $@

%.pdf: %.pmd $(IMAGES) $(THISMAKEFILE)
	pandoc $(PANDOC_FLAGS) -V documentclass=$(DOCUMENTCLASS) --toc $< -o $@

%.html: %.pmd $(IMAGES) $(THISMAKEFILE)
	pandoc $(PANDOC_FLAGS) $< -o $@

tests-all: $(TESTS)

tests-xml:
	server/server.py & find xml -name \*.xml -ls -exec curl -v http://localhost:8080/users --data @{} \; ; kill %1

tests-python:
	server/server.py & find python3 -name \*.py -ls -exec {} \; ; kill %1

tests-java:
	server/server.py & cd java && for i in *.build.gradle ; do ./gradlew -b $$i run;done; kill %1

tests-go:
	go get github.com/divan/gorilla-xmlrpc/xml
	server/server.py & find go -name \*.go -ls -exec go run {} \; ;kill %1

tests-php:
	server/server.py & php/simpleExample1.php ;kill %1

tests-c:
	cd C; $(MAKE)




