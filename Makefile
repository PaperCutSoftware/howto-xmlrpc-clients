.SUFFIXES:


PANDOC_FLAGS:=--number-sections -s -smart

DOCUMENTCLASS:=article

all: BlogPost.pdf

clean:
	-rm -f BlogPost.pdf BlogPost.html 

%.pmd: %.m4
	server/server.py&
	m4 -P $< > $@
	echo ps -u $(USER) | awk '/server\.py/ { print $2}'|xargs echo kill
	ps -u $(USER) | awk '/server\.py/ { print $$2}'|xargs echo kill

%.pdf: %.pmd
	pandoc $(PANDOC_FLAGS) -V documentclass=$(DOCUMENTCLASS) --toc -t latex  $< -o $@

%.html: %.pmd
	pandoc $(PANDOC_FLAGS) $< -o $@
