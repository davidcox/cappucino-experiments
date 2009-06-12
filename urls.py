from django.conf.urls.defaults import *
from os import path

# Uncomment the next two lines to enable the admin:
from django.contrib import admin
admin.autodiscover()

cappuccino_path = path.abspath('cappuccino')

urlpatterns = patterns('',
    # Example:
    # (r'^soma_web/', include('soma_web.foo.urls')),

    # Uncomment the admin/doc line below and add 'django.contrib.admindocs' 
    # to INSTALLED_APPS to enable admin documentation:
    # (r'^admin/doc/', include('django.contrib.admindocs.urls')),

    # Uncomment the next line to enable the admin:
    (r'^admin/(.*)', admin.site.root),
    (r'^manage$', 'config.views.index'),
    (r'^manage/(.*)', 'django.views.static.serve', {'document_root' : path.abspath('cappuccino/')} ),
    
    # test
    (r'^test', 'recorder.views.test_it_baby'),
    
    # status ajax calls
    (r'^config/property/(.*)', 'config.views.property'),  # get the version number for something
    (r'^.*', 'recorder.views.test_it_baby')
)
