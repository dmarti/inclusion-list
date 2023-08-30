DOMAINS=$(shell cat lists/ALL.txt)
INDEXES=$(DOMAINS:%=sources/homes/%/index.html)
ADSTXT=$(DOMAINS:%=sources/adstxt/%/ads.txt)
FEEDS=$(DOMAINS:%=sources/feeds/%/feed.xml)
DESCRIPTIONS=$(DOMAINS:%=data/descriptions/%)

all : lists/ALL.txt $(ADSTXT) inclusion.csv

sources/adstxt/%/ads.txt : 
	mkdir -p `dirname $@`
	echo $@ | cut -d / -f 3- | xargs echo | xargs curl --connect-timeout 15 -L > $@ || touch $@	

sources/homes/%/index.html : 
	mkdir -p `dirname $@`
	basename `dirname $@` | xargs curl --connect-timeout 15 -L > $@ || touch $@

sources/feeds/%/feed.xml : sources/homes/%/index.html
	mkdir -p `dirname $@`
	tools/get_feed < $< | xargs curl --connect-timeout 15 -L > $@ || touch $@

data/descriptions/% : sources/feeds/%/feed.xml tools/describe-site
	mkdir -p `dirname $@`
	tools/describe-site < $< > $@

sources/raptive/sellers.json :
	mkdir -p `dirname $@`
	wget -O $@ https://ads.cafemedia.com/sellers.json

lists/raptive/domains.txt : sources/raptive/sellers.json
	mkdir -p `dirname $@`
	jq -r '.sellers[].domain' $< | sort -u > $@

lists/ALL.txt : lists/raptive/domains.txt
	cat $< | sort -u > $@

inclusion.csv : $(DESCRIPTIONS)
	echo "domain,title,description" > $@
	find data/descriptions -type f | xargs cat >> $@

clean :
	rm -rf data lists

pristine : clean
	rm -rf sources

.PHONY : clean pristine
