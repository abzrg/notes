SRC    := README.md
STYLE  := style.css
TARGET := index.html
DEPS   := $(STYLE)
KATEX  := --katex


all: $(TARGET)


build: $(TARGET)
$(TARGET): $(SRC) $(DEPS)
	pandoc \
		--toc=true --toc-depth=2 \
		--standalone \
		--css=$(STYLE) \
		$(KATEX) \
		--from=markdown --to=html \
		$< -o $@


live:
	live-server &
	ls -1 $(SRC) $(DEPS) \
		| entr pandoc \
			--toc=true --toc-depth=2 \
			--standalone \
			--css=$(STYLE) \
			$(KATEX) \
			--from=markdown --to=html \
			$(SRC) -o $(TARGET)


publish:
	git show :0:$(SRC) > $(SRC).HEAD
	$(MAKE) SRC=$(SRC).HEAD
	$(RM) -fv $(SRC).HEAD


update_date: $(SRC)
	sed -i -e '/Last Update/ s/:.*/: '"$$(date +'%B %e, %Y')"'/' $<


setup_hooks:
	if test -z `git config --local --get core.hooksPath`; then \
		git config --local core.hooksPath .githooks/; \
	fi


.PHONY: all setup_hooks build update_date live
