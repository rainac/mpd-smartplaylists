# Note: this Makefile is usually copied to the work directory by
# smartplaylist.sh, together with one copy of the input data each in
# file tmp.data and tmp.$intype, where intype is the automatically
# detected input type by sniff-input-type.
#
# Make will be called to produce the file tmp.$mode, where mode is the
# string given to the -m or --mode option of smartplaylist.sh.

# suffixes:
#
#  spxml - XML format
#  spdxml - XML format, parentheses expanded
#  sp    - Text format (pretty printed input)
#  spsh  - Bash (mpc command line) format
#  spfl  - File list as returned by MPD searches
#  spfls  - File list as returned by MPD searches, separated by a special mark
#  spfl0  - File list as returned by MPD searches, 0 separated
#  exec - Run command on MPD for each file found
#  rsync-handy - Testing
#  rsync-XXX - Testing
#  scp-handy - Testing
#  scp-XXX - Testing
#  scp-handy-sh - Testing
#  scp-XXX-sh - Testing

# useful commands:
#  - transfer playlist to device
#  - transfer file list to device

debug_flag ?=

device ?= "mobile:"  # scp host

format ?=

flags ?=

%.spp2x: %.sp
	p2x --output-mode y -p $(SMPL_HOME)/p2x.conf $< | tr '[:upper:]' '[:lower:]' | tee $@ > /dev/null

%.spxml1: %.spp2x
	xsltproc $(SMPL_HOME)/create-smartplaylist.xsl $< 2> err.txt | tee $@ > /dev/null
#	-grep -v "compiled against" err.txt 1>&2

%.spxml2: %.spxml1
	xsltproc $(SMPL_HOME)/create-smartplaylist2.xsl $< 2> err.txt | tee $@ > /dev/null
#	-grep -v "compiled against" err.txt 1>&2

%.spxml: %.spxml2
	cp $< $@

#%.spxml: %.sp
#	cat $< | smartplaylist-txt2xml.sh > $@

%.spdxml: %.spxml
	cat $< | smartplaylist-distrib-or-over-and.sh > $@

%.spsh: %.spdxml
	cat $< | xsltproc --stringparam format "$(format)" $(SMPL_HOME)/genupdate-sh.xsl - > $@ 2> err.txt

%.run %.spfl: %.spsh
	cat $< | bash > $@

%.spfl0: %.spfl
	awk '{ ORS=""; print $0; print "\000"; }' $< > $@

%.scp %.scp-device: %.spfl
	cat $< | DST=$(device) copy-mpd-to-host.sh $(debug_flag) -W $(flags) | bash
# do not produce the target so this can be run repeatedly as a command mode

%.tar %.tar-device: %.spfl
	cat $< | copy-tarred-mpd-to-host.sh $(debug_flag) -W $(flags) -d $(device) -z
# do not produce the target so this can be run repeatedly as a command mode

%.rsync %.rsync-pull %.rsync-device: %.spfl
	cat $< | copy-rsync-from-mpd.sh $(debug_flag) -W $(flags) -d $(device)
# do not produce the target so this can be run repeatedly as a command mode

#%.rsync-push %.rsync-device: %.spfl
#	cat $< | copy-rsync-mpd-to-host.sh -d $(device) $(debug_flag)
# do not produce the target so this can be run repeatedly as a command mode

%.exec: %.spfl0
	cat $< | mpd-command.sh $(debug_flag) -W $(flags) -c $(command)
# do not produce the target so this can be run repeatedly as a command mode

# targets for (local) development
check: test1 test2

test1:
	./tests/test_parser.sh

test2:
	./tests/test_parser2.sh
