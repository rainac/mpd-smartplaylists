           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
            SMART PLAYLISTS FOR THE MUSIC PLAYER DEMON (MPD)

                                Johannes
           ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


Table of Contents
─────────────────

1. Installation
.. 1. Requirements
.. 2. Quick start
2. A custom text based language (representation) for Smartplaylists
.. 1. Simple Queries
..... 1. Default category
.. 2. And and Or queries
..... 1. Precedence
.. 3. Nested Queries using parentheses
.. 4. Assigning a playlist name to a playlist
3. Command line interface for the Smartplaylists
4. How does it work: Generating smart playlists for MPD with XSLT





1 Installation
══════════════

  There is currently no real installation procedure. Just clone the repo
  and cd to the directory:
  ┌────
  │ git clone https://github.com/rainac/mpd-smartplaylists.git
  │ cd mpd-smartplaylists
  └────
  Then run any operations from this directory, in particular the main
  script *smartplaylists.sh*:
  ┌────
  │ ./smartplaylist.sh artist = stones
  └────


1.1 Requirements
────────────────

  You need to install the [P2X parser tool] first (yes, this project is
  in part intended to showcase the use of P2X).

  Also, this project will most probably require a Linux system.


[P2X parser tool] <https://github.com/rainac/p2x>


1.2 Quick start
───────────────

  The *smartplaylists.sh* accepts a query in the form of command line
  arguments or from the standard input
  ┌────
  │ ./smartplaylist.sh artist = stones
  │ echo "artist = stones" | ./smartplaylist.sh      # the same
  └────
  To use the transfer features, you will need two other options: `-m'
  for the mode of operation and `d' to give the target device (local
  directory or host and directory):
  ┌────
  │ ./smartplaylist.sh -m tar -d ~/mymusic  artist = stones            # download from MPD to local directory
  │ ./smartplaylist.sh -m tar -d mobile:SDCard/Music artist = stones   # transfer from MPD to remote host
  └────
  To transfer stuff to a smartphone you should install the `Termux' app,
  which provides the required tools like `ssh', `tar', `rsync', etc.


2 A custom text based language (representation) for Smartplaylists
══════════════════════════════════════════════════════════════════

  The idea is to create a small custom language to express queries to a
  Music Player Demon (MPD). We want to allow searching the categories
  provided with arbitrary search strings, and allow to combine these
  with *and* and *or*. In addition we would like to support parentheses
  and a kind of assignment operator we call *is*.


2.1 Simple Queries
──────────────────

  A simple query has a /category/, or /tag type/, and a search string.
  These are separated by an equal operator, *eq* or *=*. The available
  categories are those accepted by the `mpc' commands `search', `find',
  `findadd', etc. (see manpage mpc(1)).

  For example, `artist=rolling' search the category `artist' for the
  string `rolling'. Using the mpc client, such a query using the command
  `search' would look like this:
  ┌────
  │ mpc search artist rolling
  └────
  Using the smartplaylist client it looks like this
  ┌────
  │ ./smartplaylist.sh artist=rolling
  └────
  Spaces in between the category, operator and search string are
  allowed:
  ┌────
  │ ./smartplaylist.sh artist =rolling
  └────
  Spaces in the search string must be quoted:
  ┌────
  │ ./smartplaylist.sh artist = 'rolling stones'
  └────
  The expression can also be read from the standard input: allowed:
  ┌────
  │ echo "artist = rolling" | ./smartplaylist.sh
  └────


2.1.1 Default category
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  The default category is `artist'. It is used when just a plain string
  is given. In the example, we could rewrite the query to read just
  `rolling'.  Using the smartplaylist client it looks like this
  ┌────
  │ ./smartplaylist.sh rolling
  └────


2.2 And and Or queries
──────────────────────

  Queries may be combined using either the *and* or the *or* operator:
  ┌────
  │ ./smartplaylist.sh artist = rolling and artist = stones
  └────
  is a more specific query than just `artist = rolling' but more general
  than `artist = 'rolling stones''. An *or* query looks very similar:
  ┌────
  │ ./smartplaylist.sh artist = rolling or artist = beatles
  └────


2.2.1 Precedence
╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

  The *and* operator has a higher precedence than the *or* operator, it
  binds to its operands more tightly, so to say. Hence when you say
  ┌────
  │ ./smartplaylist.sh artist = rolling or artist = beatles and album = white
  └────
  you will get everything from the Rolling Stones and The Beatles' White
  Album.


2.3 Nested Queries using parentheses
────────────────────────────────────

  Sometimes it is desirable to also have an *or* query nested inside an
  *and* query. This is possible using parentheses:
  ┌────
  │ ./smartplaylist.sh '(' artist = rolling or artist = beatles ')' and album = white
  └────
  will get just The Beatles' White Album, as the Stones do not have a
  "white" album (at least not in my collection).


2.4 Assigning a playlist name to a playlist
───────────────────────────────────────────

  This is done using the colon `:' operator, which has the alias
  "is". For example:
  ┌────
  │ ./smartplaylist.sh white_album: artist = beatles and album = white
  └────
  shall create a new playlist `white_album' on the MPD server,
  containing the results of the query on the right of the colon. The
  colon operator has a lower precedence than both


3 Command line interface for the Smartplaylists
═══════════════════════════════════════════════

  The basic command line program is *smartplaylists.sh*. First of all,
  running
  ┌────
  │ ./smartplaylists.sh -h
  └────
  will show a summary of options.

  The main option is _-m_, which determines the mode of operation. For
  example _-m spsh_ will generate shell code calling mpc with the given
  query and _-m spfl_ (the default) will execute the query and thus
  return the list of search results.

  *smartplaylists.sh* will take as query input the remaining command
  line arguments, for example:
  ┌────
  │ ./smartplaylists.sh -m spsh hector and tito
  └────

  When there are no arguments (other than options), then
  smartplaylists.sh will read from stdin. So the same example as before
  can also be stated as
  ┌────
  │ echo "hector and tito" | ./smartplaylists.sh -m spsh
  └────

  smartplaylist.sh shall in the future recognize different input
  formats, in particular, queries may then be given as either text or
  XML.

  The main modes of operations are currently the following:

  spxml
        convert text based query to XML
  spfl
        execure query and print results (the default)
  scp-device
        copy the query results from the MPD host to another device,
        using /scp/

  For example, when you have an Android device with an SSH app such as
  /SSHelper/, the device is in you local network as host "mobile", then
  you could transfer the result of the query "album eq dubn" to the
  device with this command

  ┌────
  │ ./smartplaylist.sh -m scp-device -d "mobile:/mnt/sdcard2/Music/incoming" album eq dub
  └────


4 How does it work: Generating smart playlists for MPD with XSLT
════════════════════════════════════════════════════════════════

  Code generation with XSLT is after all the years a hot topic for me. I
  think it is a great technique to generate code for many means. Let's
  see an example for the code generation with XSLT.

  The goal is to create a feature I had been using with XMBC: smart
  playlists. The idea is basically that you enter a static query which
  is saved with a name and when you load the smart playlist the query is
  evaluated against your database. This is of course great if you
  regularly add music to youy library. To me especially because I use to
  record from internet radios and thus end up with MP3 collections which
  are quite unwieldy. Especially annoying are the many spelling
  variations in the names and titles. This just demands some fuzzy
  flexible treatment with smart playlists.

  The idea is to generate Bash shell code that updates the smart
  playlists from a problem definition. The first thing we need is such a
  problem definition, in XML of course. This is in the file
  <file:smartplaylists.xml>:

  ┌────
  │ <smart-playlists version="1.0">
  │   <playlist name="el-rookie">
  │     <or>
  │       <and>
  │         <query type="artist">rookie</query>
  │       </and>
  │       <and>
  │         <query type="artist">roockie</query>
  │       </and>
  │     </or>
  │   </playlist>
  │   <playlist name="wisin-y-yandel">
  │     <or>
  │       <and>
  │         <query type="artist">wisin</query>
  │         <query type="artist">yandel</query>
  │       </and>
  │     </or>
  │   </playlist>
  │ </smart-playlists>
  └────

  As you can see the XML is not as simple as you might expect. This is
  because I developed the XML problem definition and the XSLT in tandem,
  such that one suits the other. Let's see how the XSLT (file
  <file:genupdate-sh.xsl>) looks:

  ┌────
  │ <xsl:stylesheet version="1.0"
  │     xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  │ 
  │   <xsl:param name="format" select="''"/>
  │   <xsl:param name="mpc" select="'mpc'"/>
  │ 
  │   <xsl:variable name="format-flag">
  │     <xsl:if test="$format">-f "<xsl:value-of select="$format"/>"</xsl:if>
  │   </xsl:variable>
  │ 
  │   <xsl:output method="text"/>
  │   <xsl:template match="text()"/>
  │ 
  │   <xsl:template match="/">
  │     <xsl:if test="//playlist"
  │             >mpc rm tmp-update-pls
  │ mpc save tmp-update-pls
  │ </xsl:if>
  │     <xsl:apply-templates/>
  │     <xsl:if test="//playlist"
  │             >mpc clear
  │ mpc load tmp-update-pls
  │ </xsl:if>
  │     <xsl:text>&#xa;</xsl:text>
  │   </xsl:template>
  │ 
  │   <xsl:template match="smart-playlists">
  │     <xsl:for-each select="*">
  │       <xsl:apply-templates select="."/>
  │       <xsl:text>&#xa;</xsl:text>
  │     </xsl:for-each>
  │   </xsl:template>
  │ 
  │   <xsl:template match="playlist">
  │     <xsl:text>mpc clear&#xa;</xsl:text>
  │     <xsl:apply-templates/> | mpc add
  │ mpc rm <xsl:value-of select="@name"/>
  │ mpc save <xsl:value-of select="@name"/>
  │     <xsl:text>&#xa;</xsl:text>
  │   </xsl:template>
  │ 
  │   <xsl:template match="filter|filter-out">
  │     <xsl:apply-templates select="*[1]"/>
  │     <xsl:for-each select="*[position()>1]">
  │       <xsl:text> | grep -i -v "</xsl:text>
  │       <xsl:value-of select="."/>
  │       <xsl:text>"</xsl:text>
  │     </xsl:for-each>
  │   </xsl:template>
  │ 
  │   <xsl:template match="filter-in">
  │     <xsl:apply-templates select="*[1]"/>
  │     <xsl:for-each select="*[position()>1]">
  │       <xsl:text> | grep -i "</xsl:text>
  │       <xsl:value-of select="."/>
  │       <xsl:text>"</xsl:text>
  │     </xsl:for-each>
  │   </xsl:template>
  │ 
  │   <xsl:template match="or[count(*)=1]">
  │     <xsl:apply-templates/>
  │   </xsl:template>
  │ 
  │   <xsl:template match="/" mode="indent-"/>
  │   <xsl:template match="/*" mode="indent-"/>
  │   <xsl:template match="/*/*" mode="indent-"/>
  │ 
  │   <xsl:template match="*" name="indent-" mode="indent-">
  │     <xsl:text> </xsl:text>
  │     <xsl:apply-templates select=".." mode="indent-"/>
  │   </xsl:template>
  │ 
  │   <xsl:template match="*" name="indent" mode="indent">
  │     <xsl:apply-templates select=".." mode="indent-"/>
  │   </xsl:template>
  │ 
  │   <xsl:template match="or">
  │     <xsl:call-template name="indent"/>
  │     <xsl:text>(</xsl:text>
  │     <xsl:text>&#xa;</xsl:text>
  │     <xsl:for-each select="*">
  │       <xsl:apply-templates select="."/>
  │       <xsl:text>&#xa;</xsl:text>
  │     </xsl:for-each>
  │     <xsl:call-template name="indent"/>
  │     <xsl:text>)</xsl:text>
  │   </xsl:template>
  │ 
  │   <xsl:template match="and">
  │     <xsl:call-template name="indent"/>
  │     <xsl:text>mpc </xsl:text>
  │     <xsl:value-of select="$format-flag"/> search <xsl:apply-templates/>
  │   </xsl:template>
  │ 
  │   <xsl:template match="query">
  │     <xsl:text> </xsl:text>
  │     <xsl:value-of select="@type"/>
  │     <xsl:text> </xsl:text>
  │     <xsl:value-of select="."/>
  │   </xsl:template>
  │ 
  │   <xsl:template match="paren">
  │     <xsl:message>warning: paren encountered</xsl:message>
  │   </xsl:template>
  │ 
  │ </xsl:stylesheet>
  └────

  Let's step through the code to see what all the things do. The first
  lines are the XML declaration and the open tag of the top-level
  *stylesheet* element. Then in the *output* element we set the method
  to `text' since we whan to generate Bash source code.

  Then next important thing is to provide a do-nothing template for the
  *text()* nodes, because we will have to tightly control the output,
  since newline characters matter in Bash shell code (they terminate a
  command).

  Then comes the template for the root node */* which is executed
  first. There we enter the commands that should be run first and
  last. We back up the current playlist to `tmp-update-pls' and restore
  it in the end. In between we invoke *apply-templates* which will
  generate the code we actually need.

  In the template matching the *playlist* element we generate the code
  that creates a playlist according to the query and save it under the
  name given by attribute *@name*. As you see, there is again some stuff
  we have to do first and some other which we do in the end, and in
  between we invoke *apply-templates*. First we clear the current
  playlist. Then comes *apply-templates*, which we assume to compose the
  playlist. Then we can save it.

  The template matching element *or* simply invokes *apply-templates*,
  because for each child some command is to be generated.

  The template matching element *and* will simply invoke generate a `mpc
  add' command, which receives is fed the output from a `mpc search'
  command. Each child shall produce a tuple `<type> <query>', which are
  intersected by `mpc add', so we invokes *apply-templates* again.

  Finally, the template matching element *query* will output the query
  type as its attribute *@type* and the query as its text content.

  Now we want to see the XSLT in action: We run *xsltproc* with it on
  the smart playlist definition XML:

  ┌────
  │ xsltproc genupdate-sh.xsl smartplaylists.xml
  └────

  ┌────
  │ 
  │ mpc rm tmp-update-pls
  │ mpc save tmp-update-pls
  │ 
  │ mpc clear
  │ 
  │ mpc search  artist rookie | mpc add
  │ 
  │ mpc search  artist roockie | mpc add
  │ 
  │ mpc rm el-rookie
  │ mpc save el-rookie
  │ 
  │ mpc clear
  │ 
  │ mpc search  artist wisin artist yandel | mpc add
  │ 
  │ mpc rm wisin-y-yandel
  │ mpc save wisin-y-yandel
  │ 
  │ mpc clear
  │ mpc load tmp-update-pls
  │ 
  └────

  The result is valid Bash code, so we can just pipe it to the shell:

  ┌────
  │ xsltproc genupdate-sh.xsl smartplaylists.xml | bash
  └────

  Then load one of the freshly generated and up-to-date playlists:

  ┌────
  │ mpc load wisin-y-yandel
  └────

  A few things to note:

  • Running this playlist update command will save and restore your
    current playlist, but it will stop playback

  • you might want to run `mpc update' before to update the database

  • Also, other than with XBMC smart playlists, ours will not be updated
    automatically when you load them. You could run the command from
    your crontab, of course

  Happy code generating!
