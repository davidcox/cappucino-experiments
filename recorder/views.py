# Create your views here.
import os
from django.http import HttpResponse
from django.utils import simplejson

def test_it_baby(request):
    
    os.system("touch /tmp/booyah")
    
    jsoncallback = request.GET['jsoncallback']
    a = {"stuff":"blah"}
    json = simplejson.dumps(a)
    return HttpResponse(jsoncallback + "(" + json + ")")