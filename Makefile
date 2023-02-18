# bitcoin tag v23.0
SOURCE_COMMIT ?= fcf6c8f4eb217763545ede1766831a6b93f583bd
# peercoin tag v0.12.1ppc
TARGET_COMMIT ?= 6839e7cc431fd284b80fdf6a2d338aa03ca3ab6a
COMMIT_RANGE := $(SOURCE_COMMIT)..$(TARGET_COMMIT)

SOURCE_CODE := peercoin

GIT_DIFF_OPTIONS := -C $(SOURCE_CODE) diff $(COMMIT_RANGE)
DIFF2HTML_OPTIONS := -i file -F

EXCLUDE := \
	*.git* \
	src/*bench* \
	src/*crc32c* \
	src/qt/* \
	src/*test* \
	src/*field* \
	src/*sketch* \
	src/univalue/* \
	src/rpc/* \
	src/wallet/* \
	*.am \
	*.cmake \
	*.md \
	*.in \
	*.include \
	*.rc \
	*.yml \
	src/chainparamsseeds.h \
	src/base58.h \
	src/*valgrind_ctime_test.c \
	src/*lintrans.h \
	src/*false_positives.h \
	src/gen_ecmult* \
	src/*bignum.h \
	src/bech32.h \
	src/bech32.cpp \
	src/*int_utils.h \
	src/bitcoin-cli.cpp \
	src/key.cpp
GIT_EXCLUDE := $(EXCLUDE:%=:^%)

TARGET_FILES = $(shell git $(GIT_DIFF_OPTIONS) --name-only src $(GIT_EXCLUDE))

diff_template := $(TARGET_FILES:%=%.diff)
html_template := $(TARGET_FILES:%=%.html)
diff_template_detailed := $(diff_template:%=detailed/%)
html_template_detailed := $(html_template:%=detailed/%)

all : html html_detailed index.html btc-ppc-detailed.diff

diffs : $(diff_template)
diffs_detailed : $(diff_template_detailed)
html : $(html_template)
html_detailed : $(html_template_detailed)

split : $(diff_template:%=issues/%)

issues/% :
	mkdir -p $@
	cp $* $@/
	cd $@ && splitpatch -H *.diff
	echo -n $(*:%.diff=%) > $@/thepath.txt

clean :
	rm -f index.html btc-ppc.diff btc-ppc-detailed.diff
	rm -rf detailed src
.PHONY : clean split

$(SOURCE_CODE) :
	git clone https://github.com/peercoin/peercoin $@
	git -C $@ remote add bitcoin https://github.com/bitcoin/bitcoin
	git -C $@ fetch bitcoin

%.diff : $(SOURCE_CODE)
	mkdir -p $(@D)
	git $(GIT_DIFF_OPTIONS) -- $* > $@

detailed/%.diff : $(SOURCE_CODE)
	mkdir -p $(@D)
	git $(GIT_DIFF_OPTIONS) -W -- $* > $@

%.html : %.diff
	diff2html $(DIFF2HTML_OPTIONS) $@ -- $<

btc-ppc.diff : $(SOURCE_CODE)
	git $(GIT_DIFF_OPTIONS) src > $@

btc-ppc-detailed.diff : $(SOURCE_CODE)
	git $(GIT_DIFF_OPTIONS) -W src > $@

index.html : btc-ppc.diff
	diff2html $(DIFF2HTML_OPTIONS) index.html -- $^