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

flags ?=

%.spp2x: %.sp
	p2x --output-mode y -p $(SMPL_HOME)/p2x.conf $< | tr '[:upper:]' '[:lower:]' | tee $@ > /dev/null

%.spxml: %.spp2x
	xsltproc $(SMPL_HOME)/create-smartplaylist.xsl $< | tee $@ > /dev/null

%.spxml: %.sp
	cat $< | smartplaylist-txt2xml.sh > $@

%.spdxml: %.spxml
	cat $< | smartplaylist-distrib-or-over-and.sh > $@

%.spsh: %.spxml
	cat $< | smartplaylist-querysh.sh > $@

%.spsh: %.spdxml
	cat $< | xsltproc genupdate-sh.xsl - > $@

%.run %.spfl: %.spsh
	cat $< | bash > $@

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
