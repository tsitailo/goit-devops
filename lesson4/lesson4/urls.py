from django.contrib import admin
from django.urls import path
from django.http import HttpResponse

def index(request):
    return HttpResponse("""
        <h1>lesson4</h1>
        <p>Django + PostgreSQL + Nginx + Docker працює!</p>
        <a href="/admin">Admin</a>
    """)

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', index),
]