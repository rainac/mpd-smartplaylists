# suffixes:
#
#  spxml - XML format
#  sp    - Text format
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

device=handy

%.spxml: %.sp
	cat $< | smartplaylist-txt2xml.sh > $@

%.spsh: %.spxml
	cat $< | smartplaylist-querysh.sh > $@

%.spfl: %.spsh
	cat $< | bash > $@

%.scp-$(device): %.spfl
	cat $< | copy-mpd-to-device.sh -d $(device) | bash
# do not produce the target so this can be run repeatedly as a command mode

%.scp-handy: %.spfl
	cat $< | copy-mpd-to-handy.sh | bash
# do not produce the target so this can be run repeatedly as a command mode

%.rsync-$(device): %.spfl
	cat $< | copy-mpd-to-device.sh -d $(device)
# do not produce the target so this can be run repeatedly as a command mode

%.rsync-handy: %.spfl
	cat $< | copy-mpd-to-handy.sh
# do not produce the target so this can be run repeatedly as a command mode
