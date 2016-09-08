// see http://stackoverflow.com/questions/5722410/how-can-i-use-javascript-to-transform-xml-xslt
// see http://www.w3schools.com/xsl/xsl_client.asp

var xlp = xlp || {}

xlp.hasActiveXSupport = function () {
    return (Object.getOwnPropertyDescriptor && Object.getOwnPropertyDescriptor(window, "ActiveXObject"))
        || ("ActiveXObject" in window)
}

xlp.isIE = xlp.hasActiveXSupport()
xlp.isWebKit = !(typeof document.webkitVisibilityState == "undefined")
xlp.isKonq = xlp.isWebKit && (typeof document.webkitFullscreenEnabled == "undefined")
xlp.isChrome = !(typeof document.webkitFullscreenEnabled == "undefined")
xlp.isMozilla = !(typeof document.mozFullScreenEnabled == "undefined")

xlp.parseXML = function(xmlStr) {
    if (typeof xmlStr != 'string') {
        xmlStr = String(xmlStr)
    }
    if (xlp.isIE && new window.ActiveXObject("Microsoft.XMLDOM")) {
        var xmlDoc = new window.ActiveXObject("Microsoft.XMLDOM")
        xmlDoc.async = "false"
        xmlDoc.loadXML(xmlStr)
        return xmlDoc
    } else if (typeof window.DOMParser != "undefined") {
        return ( new window.DOMParser() ).parseFromString(xmlStr, "text/xml");
    }

}

xlp.sendRequest = function(URL, method, data, callback) {
    if (typeof URL == 'object') {
        sendRequest(URL.URL,
                    URL.method || undefined,
                    URL.data || undefined,
                    URL.callback || undefined)
    }

    if (!method) method = 'GET'
    if (!data) data = ''
    if (!callback) callback = function(){}

    var request

    if (xlp.isIE) {
        request = new ActiveXObject("Msxml2.XMLHTTP")
    } else if (window.XMLHttpRequest) {
        request = new XMLHttpRequest()
    }

    if (!request) {
        console.error("No ajax support.")
        callback(undefined)
        return false
    }

    request.onreadystatechange = function () {
        if (request.readyState === 4) {
            if (request.status === 200) {
                callback(request)
            } else {
                callback(undefined)
                console.error('Could not load ' + URL + ': ' + request.status)
            }
        }
    }

    request.open(method, URL)
    request.send()
}

xlp.sendGet = function(URL, callback) {
    if (typeof URL == 'object') {
        xlp.sendRequest(URL.URL, 'GET', '', URL.callback || undefined)
    } else {
        xlp.sendRequest(URL, 'GET', '', callback)
    }
}

xlp.loadXML = function(path, callback) {
    xlp.sendGet(path, function(request) {
        if (request) {
            var rdoc = request.responseXML
            if (xlp.isIE) {
                rdoc = parseXML(request.responseText)
            } else {
                rdoc = request.responseXML
            }
            callback(rdoc)
        }
    })
}

xlp.mkLoadCached = function() {
    var requested = {}, docs = {}
    var loadCached = function(url, done) {
        var lev
        if (docs[url]) {
            done(docs[url])
        } else {
            if (requested[url]) {
                var levHandler = function(ev) {
                    done(docs[url])
                    document.removeEventListener('doc-loaded'+url, levHandler)
                }
                document.addEventListener('doc-loaded'+url, levHandler)
            } else {
                requested[url] = 1
                xlp.loadXML(url, function(doc) {
                    docs[url] = doc
                    lev = document.createEvent('Event')
                    lev.initEvent('doc-loaded'+url, true, true)
                    document.dispatchEvent(lev)
                    done(doc)
                })
            }
        }
    }
    return loadCached
}

xlp.loadCached = xlp.mkLoadCached()

xlp.fixKonqTransformationResult = function(doc) {
    if ((node=selectSingleNode(doc, "/html/body/*")))
    {
        doc.replaceChild(node, doc.documentElement)
    }
}

xlp.transform = function(xslt, xml) {
    var result, xsltproc

    // IE method
    if (xlp.isIE) {
        result = new ActiveXObject("MSXML2.DOMDocument")
        xml.transformNodeToObject(xslt, result)

        // Other browsers
    } else {
        xsltproc = new XSLTProcessor()
        xsltproc.importStylesheet(xslt)
        result = xsltproc.transformToDocument(xml)
        if (xlp.isKonq) {
            fixKonqTransformationResult(result)
        }
    }

    return result
}

xlp.selectSingleNode = function(doc, xpath) {
    var res = doc.evaluate(xpath, doc, null, XPathResult.ANY_TYPE, null)
    return res.iterateNext()
}

xlp.transformToFragment = function(xslt, xml) {
    var result, xsltproc

    if (xlp.isIE) {
        result = parseXML(xml.transformNode(xslt))
    } else {
        xsltproc = new XSLTProcessor()
        xsltproc.importStylesheet(xslt)
        result = xsltproc.transformToFragment(xml, document)
    }

    return result
}

xlp.serializeNode = function(result) {
    var x, ser, s = ''

    // IE method.
    if (result.childNodes[0] && result.childNodes[0].xml) {
        for (x = 0; x < result.childNodes.length; x += 1) {
            s += result.childNodes[x].xml
        }
        // Other browsers
    } else {
        ser = new XMLSerializer()
        for (x = 0; x < result.childNodes.length; x += 1) {
            s += ser.serializeToString(result.childNodes[x])
        }
    }

    return s
}

xlp.mkpre = function(text) {
    var pre = document.createElement("PRE")
    pre.innerHTML = text
    return pre
}

xlp.attach = function(element, htmlfrag, done) {
    var c
    while (c=element.lastChild) element.removeChild(c)
    element.appendChild(htmlfrag)
    if (typeof done == "function")
        done(element, 1)
}

xlp.mkXLP = function(xslts, xsltbase) {
//    xslts = xslts || []
//    xsltbase = xsltbase || ''
    function step(xml, done, j) {
        if (j == undefined) j = 0
        xlp.loadCached(xsltbase + xslts[j], function(xsl) {
            if (xsl) {
                var res
                if (j < xslts.length - 1) {
                    res = xlp.transform(xsl, xml)
                    step(res, done, j+1)
                } else {
                    res = xlp.transformToFragment(xsl, xml)
                    done(res)
                }
            }
        })
    }
    var transform = function(indoc, done) {
        step(indoc,
             function(outfrag) {
                 done(outfrag)
             })
    }
    var transformTxt = function(instr, done) {
        var indoc = xlp.parseXML(instr)
        transform(indoc,
                  function(outfrag) {
                      done(outfrag)
                  })
    }
    var XLP = {
        xslts: xslts,
        xsltbase: xsltbase,
        transform: transform,
        transformTxt: transformTxt,
        attach: xlp.attach,
        mkpre: xlp.mkpre,
    }
    return XLP
}
