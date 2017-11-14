.SUFFIXES:

.PHONY: clean all tests tests-xml tests-python tests-java tests-go

PANDOC_FLAGS:=--number-sections -s -smart

DOCUMENTCLASS:=article

all: BlogPost.pdf

BlogPost.pdf: server/server.py ${glob xml/*.xml} python3/simpleExample1.py  $(lastword $(MAKEFILE_LIST))

clean:
	-rm -f BlogPost.pdf BlogPost.html 

%.pmd: %.m4
	server/server.py&
	m4 -P $< > $@
	ps -u $(USER) | awk '/python.+server\.py/ { print $$2}'|xargs kill

%.pdf: %.pmd
	pandoc $(PANDOC_FLAGS) -V documentclass=$(DOCUMENTCLASS) --toc -t latex  $< -o $@

%.html: %.pmd
	pandoc $(PANDOC_FLAGS) $< -o $@

tests: tests-xml tests-python tests-java tests-go

tests-xml:
	server/server.py& find xml -name \*.xml -ls -exec curl -v http://localhost:8080/users --data @{} \; ; kill %1

tests-python:
	server/server.py& find python3 -name \*.py -ls -exec {} \; ; kill %1

tests-java:
	server/server.py& cd java && for i in *.build.gradle ; do ./gradlew -b $$i run;done; kill %1

tests-go:
	go get github.com/divan/gorilla-xmlrpc/xml
	server/server.py& find go -name \*.go -ls -exec go run {} \; ;kill %1

