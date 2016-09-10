from django.shortcuts import render
from django import forms
from django.http import HttpResponse, HttpResponseRedirect, HttpResponseForbidden

from subprocess import Popen, PIPE, CalledProcessError
import select

# Create your views here.

def view_index(request):
    return render(request, 'mpdview/mpdview.html', {'request': request})

def ajax_index(request):
    return render(request, 'mpdview/mpdview.xml', {'request': request})

def runpipe(command, str):
    res = ('', -1)
    try:
#        print 'start command: ', command
        pipe = Popen(command, shell=False, stdout=PIPE, stderr=PIPE, stdin=PIPE)
        result = pipe.communicate(input=str.encode('utf8'))
        if pipe.returncode == 0:
            res = (result[0], 0)
        else:
            print 'error: command returned error code: ', pipe.returncode, result[1]
    except CalledProcessError as e:
        print 'error: command execution failed: ', e.returncode, command
    except OSError as e:
        print 'error: command execution failed: ', e, command
    return res


def startpipe(command, str):
    res = ('', -1)
    try:
        print 'start pipe command: ', command
        res = Popen(command, shell=False, stdout=PIPE, stderr=PIPE, stdin=PIPE)
    except CalledProcessError as e:
        print 'error: command execution failed: ', e.returncode, command
    except OSError as e:
        print 'error: command execution failed: ', e, command
    return res

def closepipe(pipe):
    res = ('', -1)
    try:
        rem = pipe.communicate(input=str.encode('utf8'))
        if pipe.returncode == 0:
            res = (result[0], 0)
        else:
            print 'error: command returned error code: ', pipe.returncode, result[1]
    except CalledProcessError as e:
        print 'error: command execution failed: ', e.returncode, command
    except OSError as e:
        print 'error: command execution failed: ', e, command
    return res


class TextFieldForm(forms.Form):
    q = forms.CharField(max_length=500, required=False)
    cmd = forms.CharField(max_length=500, required=False)
    input = forms.CharField(max_length=500, required=False)

def view_playlist(request):
    qform = TextFieldForm(request.POST)
    return render(request, 'mpdview/mpd.html', {'files': sout, 'qform': qform})

def build_format_json(fields):
    s = '{'
    for name in fields:
        s = s + "\"" + name + "\":"
        s = s + "\"%" + name + "%\","
    s = s[0:-1] + '},'
    return s

def gpParam(request, name, default):
    res = default
    if request.GET:
        if request.GET.has_key(name):
            res = request.GET[name]
    if request.POST:
        if request.POST.has_key(name):
            res = request.POST[name]
    return res

def plist_info(request):
#    fields = ['title', 'artist', 'album', 'track', 'date', 'disc', 'time', 'file', 'mtime', 'mdate']
    field = gpParam(request, 'field', 'title')
    command = ['mpc', '-f', '%'+field+'%', 'playlist'];
    plist = gpParam(request, 'playlist', '')
    if plist:
        command = command + [plist]
    p = startpipe(command, '')
    lines = p.stdout.readlines()
    s = '['
    for line in lines:
        s = s + '"' + line[0:-1].replace('"', '&quot;') + '",'
    s = s[0:-1] + ']'
    return HttpResponse(s)

def ajax_query(request):
    sout = ''
    if request.method == 'POST':
        qform = TextFieldForm(request.POST)
        if form.is_valid():
            query = qform.cleaned_data['q']

            command = ['smartplaylist.sh', '-f', '%file%'];
            sout = runpipe(command, query)

    return render(request, 'mpdview/files.xml', {'files': sout})

def ajax_file_playlist(request):
    command = ['mpc', '-f', '%file%', 'playlist'];
    sout = runpipe(command, '')

    return render(request, 'mpdview/files.xml', {'files': sout})

def suckfds(fds):
    out = ''
    av = select.select(fds, [], [], 0.2)
    if len(av[0]) == 0 and len(av[1]) == 0 and len(av[2]) == 0:
        return None
    else:
        out = out + av[0][0].read()
    return out

def pollfds(fds):
    out = ''
    while True:
        av = select.select(fds, [], [], 0.2)
        if len(av[0]) == 0 and len(av[1]) == 0 and len(av[2]) == 0:
            break
        out = out + av[0][0].read(1)
    return out

class PythonShell():

    def __init__(self):
        self.pythonShell = None

    def start(self, command):
        if command is None:
            self.command = ['python', '-i']
        print 'starting: ', command
        self.pythonShell = Popen(command, bufsize=0, shell=False, stdout=PIPE, stderr=PIPE, stdin=PIPE)
        print 'started, greeting: ', pollfds([self.pythonShell.stdout, self.pythonShell.stderr])

    def getPipe(self):
        if self.pythonShell is None:
            self.start()
        return self.pythonShell

    def pollPipe(self):
        if self.pythonShell is None:
            self.start()
        return pollfds([self.pythonShell.stdout, self.pythonShell.stderr])


pythonShell = PythonShell()

def ajax_python(request):
    expr = gpParam(request, 'expr', '')
    pipe = pythonShell.getPipe()
    pipe.stdin.write(expr)
    pipe.stdin.write('\n')
    pipe.stdin.flush()
    out = pipe.pollPipe()
    return HttpResponse(out)


def ajax_system(request, command=None, input=None):
    if request.method == "GET":
        form = TextFieldForm(request.GET)
    else:
        form = TextFieldForm(request.POST)
    if form.is_valid():
        if command is None:
            command = form.cleaned_data['cmd']
        if input is None:
            input = form.cleaned_data['input']
    else:
        print "Error: Form invalid!"
#    print 'command', command
    sout = runpipe(command.split(' '), input)[0]

    return HttpResponse(sout)

def ajax_mpc(request, command=None):
    if request.method == "GET":
        form = TextFieldForm(request.GET)
    else:
        print request.POST
        form = TextFieldForm(request.POST)
    if form.is_valid():
        command = form.cleaned_data['cmd']
    else:
        print "Error: Form invalid!"
#    print "command: ", command
    return ajax_system(request, 'mpc ' + command)
