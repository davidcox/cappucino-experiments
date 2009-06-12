# Create your views here.
from django.shortcuts import *
from django.utils import simplejson
import os
import re


def index(request):
    capp_path = os.path.abspath('cappuccino/index.html')
    
    f = open(capp_path, 'r')
    s = f.read()
    return HttpResponse(s)
    

def property(request, propstring):
    
    os.system("echo \"%s\" > /tmp/propstring.txt" % propstring)
    jsoncallback = request.GET['jsoncallback']
    
    val = ""
    try:
        val = eval("%s()" % propstring)
    except Exception, e:
        print "unknown function %s" % propstring
    
    a = {"property":propstring, "value":val}
    json = simplejson.dumps(a)
    response_string = jsoncallback + "(" + json + ")"
    
    return HttpResponse(response_string)


def os_version():
    version = (os.popen("uname -smr")).read()
    return version
    
def uptime():
    fullstring = (os.popen("uptime")).read()
    m = re.search("up (.*?,.*?),", fullstring)
    g = m.groups()
    time_string = g[0]
    return time_string
    
def pkg_version(pkg):
    version = (os.popen("pkg-config --modversion %s" % pkg)).read()
    if(version == ""):
        version = "Not installed"
    return version
    
def somanetwork_version():
    return pkg_version("somanetwork-1.0")
    
def somadspio_version():
    return pkg_version("somadspio-1.0")

def recorder_version():
    return pkg_version("soma-recorder")
    
def disk_free_space():
    df_output = (os.popen("df -h /")).read()
    m = re.search(".*?\n.*?\s+(.*?)\s+(.*?)\s+(.*?)\s+", df_output)
    g = m.groups()
    df_result = g[2] + " (" + g[0] + " total)"
    print df_result
    return df_result

def server_ip():
    ifconfig_output = (os.popen("ifconfig")).read()
