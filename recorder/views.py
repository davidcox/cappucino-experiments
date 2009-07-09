# Create your views here.
import os
import re
from django.http import HttpResponse
from django.utils import simplejson
from soma_manager import *
import time

initialized = False
soma_manager = None
soma_recorder = None

def __init_soma_manager():
    # soma_manager = SomaManager("10.0.0.2", "~/data")
    # soma_recorder = soma_manager.recorder
    return


def property(request, propstring):

    #os.system("echo \"%s\" > /tmp/propstring.txt" % propstring)
    jsoncallback = request.GET['jsoncallback']

    print "Hello"
    #print disk_free_space(request)

    val = ""
    try:
        val = eval("%s(request)" % propstring)
    except Exception, e:
        print "recorder: error with function %s" % propstring
        print e.message
    
    a = {"property":propstring, "value":val}
    json = simplejson.dumps(a)
    response_string = jsoncallback + "(" + json + ")"

    return HttpResponse(response_string)

def set_property(request, propstring):
    #os.system("echo \"%s\" > /tmp/propstring.txt" % propstring)
    jsoncallback = request.GET['jsoncallback']

    value = request.GET['value']

    # do the "set" operation
    try:
        print "!!! set_%s(request, value)" % propstring
        eval("set_%s(request, value)" % propstring)
    except Exception, e:
        print "recorder: error with function set_%s" % propstring
        print e.message
    
    val = ""
    try:
        val = eval("%s(request)" % propstring)
    except Exception, e:
        print "recorder: unknown function %s" % propstring

    a = {"property":propstring, "value":val}
    json = simplejson.dumps(a)
    response_string = jsoncallback + "(" + json + ")"

    return HttpResponse(response_string)

    

def experiment_list(request):
    if not initialized:
        __init_soma_manager()
    exp_list = [{"name":"Reverse Correlation 1"}, {"name":"Basic Invariance"}]
    
    return exp_list


def epoch_list(request):
    exp = request.GET["experiment"]
    
    returnval = None 

    if exp == "Reverse Correlation 1":
        returnval = [{"name":"Default Epoch","active":0}, 
                     {"name":"Test Epoch", "active":1}]
    else:
        returnval =  [{"name":"A Different Epoch","active":0}, 
                      {"name":"Another Epoch", "active":0}]

    print("Returning epoch list for: " + exp)
    print returnval
    return returnval
    
    
def start_timestamp(request):
    # selected_experiment = request.GET["selected_experiment"]
    #     selected_epoch = request.GET["selected_epoch"]
    #     
    return "100000000"
    
    
def current_timestamp(request):
    # selected_experiment = request.GET["selected_experiment"]
    #     selected_epoch = request.GET["selected_epoch"]
    #     
    returnval = str(int(time.time()))
    return returnval

def lookup_selected_experiment(request):
    selected_experiment = ""
    if("selected_experiment" in request.GET):
        selected_experiment = request.GET["selected_experiment"]
    
    return selected_experiment

def lookup_selected_epoch(request):
    selected_epoch = ""
    if("selected_epoch" in request.GET):
        selected_epoch = request.GET["selected_epoch"]

    return selected_epoch

def recording_duration(request):
    selected_experiment = lookup_selected_experiment(request)
    selected_epoch = lookup_selected_epoch(request)
    
    if(selected_experiment == "Reverse Correlation 1"):
        return "01:02:02"
    else: 
        return "03:02:01"

def recorder_time(request):
    return "00:55"


def experiment_disk_size(request):
    selected_experiment = lookup_selected_experiment(request)
    return "302 MB"
    
def experiment_path(request):
    selected_experiment = lookup_selected_experiment(request)
    return "/home/soma/data/" + selected_experiment


def disk_free_space(request):
    df_output = (os.popen("df -h /")).read()
    m = re.search(".*?\n.*?\s+(.*?)\s+(.*?)\s+(.*?)\s+", df_output)
    g = m.groups()
    df_result = g[2] + " (" + g[0] + " total)"
    print df_result
    return df_result


fake_is_recording_1 = False
fake_is_recording_2 = False

def set_recording_state(experiment, epoch, state):
    global fake_is_recording_1, fake_is_recording_2
    if(epoch == "Default Epoch"):
        fake_is_recording_1 = state
    else:
        fake_is_recording_2 = state


def get_recording_state(experiment, epoch):
    global fake_is_recording_1, fake_is_recording_2
    if(epoch == "Default Epoch"):
        return fake_is_recording_1
    else:
        return fake_is_recording_2
    

def set_is_recording(request, value):
    experiment = lookup_selected_experiment(request)
    epoch = lookup_selected_epoch(request)
    if(value == False or value == "false"):
        set_recording_state(experiment, epoch, False)
    else:
        set_recording_state(experiment, epoch, True)


def is_recording(request):
    experiment = lookup_selected_experiment(request)
    epoch = lookup_selected_epoch(request)
    return get_recording_state(experiment, epoch)
    
def start_recording(request):
    fake_is_recording = True
    return

def stop_recording(request):
    fake_is_recording = False
    return

def experiment_name(request):
    if "selected_experiment" in request.GET:
        return request.GET["selected_experiment"]
    
    return "undefined"
    
def experiment_name(request):
    if "selected_epoch" in request.GET:
        return request.GET["selected_epoch"]

    return "undefined"
    
#def test_it_baby(request):
    
#    os.system("touch /tmp/booyah")
    
#    jsoncallback = request.GET['jsoncallback']
#    a = {"stuff":"blah"}
#    json = simplejson.dumps(a)
#    return HttpResponse(jsoncallback + "(" + json + ")")