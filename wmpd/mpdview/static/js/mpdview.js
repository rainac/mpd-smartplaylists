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

wmpc.Request = function(method, url, data, callback) {
    d = new Object();
    d.request = wmpc.CreateRequest();
    d.request.open(method, url, true);
    d.request.onreadystatechange = function f() {
//        console.log('onreadystatechange: ' + url + ': ' +  d.request.readyState);
        switch(d.request.readyState) {
        case 4:
            if (d.request.status != 200) {
                alert("Error: HTTP Status: " + d.request.status);
            } else {
                callback(d.request.responseText);
            }
        }
    };
    d.request.send(data);
    return d;
}

wmpc.Get = function(url, callback) {
    console.log('wmpc.Get: ' + url);
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

wmpc.updateStatusTxt = function (target) {
    wmpc.Get('ajax/mpc?cmd=status', function(status) {
        xlp.attach(target, xlp.mkpre(status))
    });
}
wmpc.setupStatusTxt = function (target) {
    wmpc.updateStatusTxtCB()
    setInterval(function() {
        wmpc.updateStatusTxt(target)
    }, 1000)
}
wmpc.updateStatusTxtCB = function () {
    wmpc.updateStatusTxt(document.getElementById('wmpc-div-status-txt'))
}

wmpc.status = wmpc.mkLogOutFunc('')
wmpc.play = wmpc.mkLogOutFunc('play', wmpc.updateStatusTxtCB)
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

function WMPCMain(x, ev) {

    var mainproc = xlp.mkXLP(['mpdview.xsl'], '/static/xsl/')

    wmpc.Get('ajax/', function(status) {
        console.log('status XML: ' + status)
        mainproc.transformTxt(status, function(htmlfrag) {
            console.log('result HTML: ' + htmlfrag)
            mainproc.attach(document.getElementById('wmpc-body'), htmlfrag)

            wmpc.setupStatusTxt(document.getElementById('wmpc-div-status-txt'))
        })
    });

}
