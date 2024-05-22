SRC    := README.md
STYLE  := style.css
TARGET := index.html
DEPS   := $(STYLE)
KATEX  := --katex



all: $(TARGET)


build: $(TARGET)


update_date: $(SRC)
	sed -i -e '/Last Update/ s/:.*/: '"$$(date +'%B %e, %Y')"'/' $<


$(TARGET): $(SRC) $(DEPS)
	$(MAKE) update_date
	pandoc \
		--toc=true --toc-depth=2 \
		--standalone \
		--css=$(STYLE) \
		$(KATEX) \
		--from=markdown --to=html \
		$< -o $@


live:
	$(MAKE) update_date
	ls -1 $(SRC) $(DEPS) \
		| entr pandoc \
			--toc=true --toc-depth=2 \
			--standalone \
			--css=$(STYLE) \
			$(KATEX) \
			--from=markdown --to=html \
			$(SRC) -o $(TARGET)


.PHONY: all build update_date live
