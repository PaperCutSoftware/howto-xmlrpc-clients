.SUFFIXES:

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
