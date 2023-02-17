SOURCE_COMMIT := fcf6c8f4eb217763545ede1766831a6b93f583bd # bitcoin tag v23.0
TARGET_COMMIT := 6839e7cc431fd284b80fdf6a2d338aa03ca3ab6a # peercoin tag v0.12.1ppc
COMPARE := $(addsuffix $(addprefix .., $(TARGET_COMMIT)), $(SOURCE_COMMIT))

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
GIT_EXCLUDE := $(addprefix :^, $(EXCLUDE))

files = $(shell git -C peercoin diff --name-only $(COMPARE) src $(GIT_EXCLUDE))

diff_template := $(addsuffix .diff, $(files))
html_template := $(addsuffix .html, $(files))
diff_template_detailed := $(addprefix detailed/, $(diff_template))
html_template_detailed := $(addprefix detailed/, $(html_template))

all : html html_detailed index.html btc-ppc-detailed.diff

diffs : $(diff_template)
diffs_detailed : $(diff_template_detailed)
html : $(html_template)
html_detailed : $(html_template_detailed)

clean :
	rm -f index.html btc-ppc.diff btc-ppc-detailed.diff
	rm -rf detailed src

peercoin :
	git clone https://github.com/peercoin/peercoin $@
	git -C $@ remote add bitcoin https://github.com/bitcoin/bitcoin
	git -C $@ fetch bitcoin

%.diff : peercoin
	mkdir -p $(@D)
	git -C $^ diff $(COMPARE) -- $* > $@

detailed/%.diff : peercoin
	mkdir -p $(@D)
	git -C $^ diff -W $(COMPARE) -- $* > $@

%.html : %.diff
	diff2html -F $@ -i file -- $^

btc-ppc.diff : peercoin
	git -C $^ diff $(COMPARE) src > $@

btc-ppc-detailed.diff : peercoin
	git -C $^ diff -W $(COMPARE) src > $@

index.html : btc-ppc.diff
	diff2html -F index.html -i file -- btc-ppc.diff