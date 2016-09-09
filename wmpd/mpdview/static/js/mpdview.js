var wmpc = {}

wmpc.CreateRequest = function() {
    var req = null;
    try{
        req = new XMLHttpRequest();
    }
    catch (ms){
        try{
            req = new ActiveXObject("Msxml2.XMLHTTP");
        }
        catch (nonms){
            try{
                req = new ActiveXObject("Microsoft.XMLHTTP");
            }
            catch (failed){
                req = null;
            }
        }
    }
    if (req == null)
        alert("Error creating request object!");
    return req;
}

wmpc.PostprocGenHTML = function(txt) {
    var re = /<script .*src="([^"]+)"/;
    var match = txt.match(re);
    if (match) {
        for (k = 1; k < match.length; ++k) {
            var script = document.createElement( 'script' );
            script.type = 'text/javascript';
            script.src = match[k];
            target.appendChild(script);
        }
    }
}

wmpc.Request = function(method, url, data, callback, error) {
    d = new Object();
    d.request = wmpc.CreateRequest();
    d.request.open(method, url, true);
    d.request.onreadystatechange = function f() {
//        console.log('onreadystatechange: ' + url + ': ' +  d.request.readyState);
        switch(d.request.readyState) {
        case 4:
            if (d.request.status != 200) {
                console.warn("WMPC: HTTP status: " + d.request.status);
                if (typeof error == "function")
                    error(d.request.status, d)
            } else {
                callback(d.request.responseText);
            }
        }
    };
    d.request.send(data);
    return d;
}

wmpc.Get = function(url, callback) {
//    console.log('wmpc.Get: ' + url);
    return wmpc.Request('GET', url, '', callback);
}

wmpc.Post = function(url, data, callback) {
    return wmpc.Request('POST', url, data, callback);
}


wmpc.mkNoOutFunc = function(name) {
    var res = function(url, callback) {
        wmpc.Get('ajax/mpc?cmd=' + name, function(status) {
            console.log('mpc NoOut output: ' + status)
        });
    }
    return res
}

wmpc.mkLogOutFunc = function(name, gDone) {
    var res = function(url, lDone) {
        wmpc.Get('ajax/mpc?cmd='+name, function(status) {
            var target = document.getElementById('wmpc-div-log')
            target.insertBefore(xlp.mkpre(status), target.firstElementChild)
            if (typeof gDone == "function")
                gDone(target, 1)
            if (typeof lDone == "function")
                lDone(target, 1)
        })
    }
    return res
}

wmpc.intervals = {}
wmpc.clearInterval = function (name) {
    console.log('clear inter: ' + name)
    clearInterval(wmpc.intervals[name])
    wmpc.intervals[name] = undefined
}
wmpc.clearIntervals = function () {
    for (k in wmpc.intervals) {
        console.log(k)
        console.log(typeof k)
        console.log(typeof wmpc[k])
        wmpc.clearInterval(k)
    }
    wmpc.intervals = {}
}
wmpc.addInterval = function(name, intervalHandle) {
    console.log('adding inter: ' + name)
    if (wmpc.intervals[name] != undefined) {
        wmpc.clearInterval(name)
    }
    console.log('add inter: ' + name)
    wmpc.intervals[name] = intervalHandle
}

wmpc.updateStatus = function (targetTxt, targetFancy, xproc) {
    wmpc.Get('ajax/mpc?cmd=status', function(status) {
        xlp.attach(document.getElementById(targetTxt), xlp.mkpre(status))
        if (targetFancy != undefined) {
            xproc.transform(status, function(result) {
                xlp.attach(document.getElementById(targetFancy), result)
            })
        }
    });
}
wmpc.setupStatusTxt = function (targetTxt, targetFancy, xproc) {
    wmpc.updateStatusTxtCB = function() {
        wmpc.updateStatus(targetTxt, targetFancy, xproc)
    }
    wmpc.updateStatusTxtCB()
    wmpc.addInterval('status', setInterval(function() {
        wmpc.updateStatusTxtCB()
    }, 1000))
}

wmpc.updatePlaylist = function (targetTxt, targetFancy, xproc) {
    wmpc.Get('ajax/mpc?cmd=playlist', function(status) {
        xlp.attach(document.getElementById(targetTxt), xlp.mkpre(status))
        if (targetFancy != undefined) {
            xproc.transform(status, function(result) {
                xlp.attach(document.getElementById(targetFancy), result)
            })
        }
    });
}
wmpc.setupPlaylist = function (targetTxt, targetFancy, xproc) {
    wmpc.updatePlaylistCB = function() {
        wmpc.updatePlaylist(targetTxt, targetFancy, xproc)
    }
    wmpc.updatePlaylistCB()
    wmpc.addInterval('playlist', setInterval(function() {
        wmpc.updatePlaylistCB()
    }, 10000))
}

wmpc.status = wmpc.mkLogOutFunc('')
wmpc.play = function(index) {
    cmd = 'play'
    if (index != undefined) {
        cmd = cmd + ' ' + index;
    }
    wmpc.Get('ajax/mpc?cmd=' + cmd, function(status) {})
}
wmpc.pause = wmpc.mkLogOutFunc('pause', wmpc.updateStatusTxtCB)
wmpc.next = wmpc.mkLogOutFunc('next', wmpc.updateStatusTxtCB)
wmpc.prev = wmpc.mkLogOutFunc('prev', wmpc.updateStatusTxtCB)
wmpc.clear = wmpc.mkLogOutFunc('clear')
wmpc.crop = wmpc.mkLogOutFunc('crop')
wmpc.current = wmpc.mkLogOutFunc('current')

wmpc.single = wmpc.mkLogOutFunc('single', wmpc.updateStatusTxtCB)
wmpc.consume = wmpc.mkLogOutFunc('consume', wmpc.updateStatusTxtCB)
wmpc.random = wmpc.mkLogOutFunc('random', wmpc.updateStatusTxtCB)
wmpc.repeat = wmpc.mkLogOutFunc('repeat', wmpc.updateStatusTxtCB)

wmpc.shuffle = wmpc.mkLogOutFunc('shuffle')
wmpc.stats = wmpc.mkLogOutFunc('stats')
wmpc.lsplaylistsplain = wmpc.mkLogOutFunc('lsplaylists')
wmpc.playlistplain = wmpc.mkLogOutFunc('playlist')
wmpc.replaygainplain = wmpc.mkLogOutFunc('replaygain')

wmpc.update = wmpc.mkNoOutFunc('update')

wmpc.seek_click = function(el, ev) {
    cmd = 'seek'
    console.dir(el)
    console.dir(ev)
    posdef = Math.round(10000 * (ev.layerX -  el.offsetLeft - 1) / el.clientWidth) / 100.0
    wmpc.Get('ajax/mpc?cmd=seek+' + posdef + '%', function(status) {})
}

wmpc.evh = function(el, ev, func, args) {
    func(args)
//    ev.canceBubble = true
}

function WMPCMain(x, ev) {

    var mainproc = xlp.mkXLP(['mpdview.xsl'], '/static/xsl/')

        var TOKEN_NA = 1111
        var scanConf = {
        name: 'Test',
        ignored: 1,
        rules: [
            { re: ':', action: TOKEN_COLON },
            { re: '/', action: TOKEN_DIV },
            { re: '( |\t)+', action: TOKEN_SPACE },
            { re: '\n', action: TOKEN_NEWLINE },
            { re: '@', action: TOKEN_AT },
            { re: '\\.', action: TOKEN_FULL_STOP },
            { re: '#', action: TOKEN_HASH },
            { re: '%', action: TOKEN_MOD },
            { re: '[0-9]+', action: TOKEN_INTEGER },
            { re: '[0-9]+\\.[0-9]+', action: TOKEN_FLOAT },
            { re: '[a-zA-Z_-][a-zA-Z0-9_-]*', action: TOKEN_IDENTIFIER },
            { re: 'n/a', action: TOKEN_NA },
        ]
    }
    var parseConf = [
        { type: TOKEN_ROOT, mode: MODE_UNARY, prec: 1 },
        { type: TOKEN_NEWLINE, mode: MODE_BINARY, assoc: ASSOC_RIGHT, prec: 90, merged: true },
        { type: TOKEN_JUXTA, mode: MODE_BINARY, assoc: ASSOC_RIGHT, prec: 100 },
        { type: TOKEN_HASH, mode: MODE_UNARY, prec: 130 },
        { type: TOKEN_MOD, mode: MODE_POSTFIX, prec: 132 },
        { type: TOKEN_DIV, mode: MODE_BINARY, assoc: ASSOC_LEFT, prec: 135 },
        { type: TOKEN_COLON, mode: MODE_BINARY, assoc: ASSOC_LEFT, prec: 140 },
        { type: TOKEN_TAB, mode: MODE_IGNORE, prec: 2 },
        { type: TOKEN_SPACE, mode: MODE_IGNORE, prec: 2 },
        { type: TOKEN_ILLEGAL_CHAR, mode: MODE_IGNORE, prec: 2 },
        { type: TOKEN_IGNORE, mode: MODE_IGNORE, prec: 2 }
    ]
    var p2xConf = {
        scanner: scanConf,
        parser: parseConf,
        treeprinter: {},
        debug: true
    }

//    var p2x = p2x.create(p2xConfig)
    var p2xproc = {}
    p2xproc.transform = function(txt, done) {
        // console.log('p2xproc: input: ' + txt)
        // xmltxt = "<fancy-status/>"
        xmltxt = P2X.p2xj(txt, p2xConf)
//        console.log('p2xproc: XML: ' + xmltxt)
        mainproc.transformTxt(xmltxt, function(statusxml) {
//            console.log('p2xproc: MPD status XML::: ' + xlp.serializeNode(statusxml))
            mainproc.transform(statusxml, function(htmlfrag) {
//                console.log('p2xproc: HTMLFragment::: ' + xlp.serializeNode(htmlfrag))
                done(htmlfrag)
            })
        })
    }

    var p2xproc_playlist = {}
    p2xproc_playlist.transform = function(txt, done) {
        // console.log('p2xproc: input: ' + txt)
        // xmltxt = "<fancy-status/>"
        xmltxt = P2X.p2xj(txt, p2xConf)
//        console.log('p2xproc: XML: ' + xmltxt)
        mainproc.transformTxt('<p2xplaylist>'+xmltxt+'</p2xplaylist>', function(statusxml) {
//            console.log('p2xproc: MPD status XML::: ' + xlp.serializeNode(statusxml))
            mainproc.transform(statusxml, function(htmlfrag) {
                // console.log('p2xproc: HTMLFragment::: ' + xlp.serializeNode(htmlfrag))
                done(htmlfrag)
            })
        })
    }

    wmpc.Get('ajax/', function(status) {
        console.log('status XML: ' + status)
        mainproc.transformTxt(status, function(htmlfrag) {
            console.log('result HTML: ' + htmlfrag)
            mainproc.attach(document.getElementById('wmpc-body'), htmlfrag)

            setTimeout(function () {
                wmpc.setupPlaylist('wmpc-div-playlist-txt', 'wmpc-div-playlist-fancy', p2xproc_playlist)
            }, 100)
            wmpc.setupStatusTxt('wmpc-div-status-txt', 'wmpc-div-status-fancy', p2xproc)
        })
    });

}
