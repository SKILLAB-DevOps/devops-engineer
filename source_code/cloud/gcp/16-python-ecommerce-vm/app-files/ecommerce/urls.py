from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static
from drf_spectacular.views import SpectacularAPIView, SpectacularSwaggerView
from django.http import JsonResponse

def api_root(request):
    return JsonResponse({
        'message': 'Welcome to the E-commerce API',
        'version': '1.0.0',
        'deployment': 'gcp-vm-django',
        'endpoints': {
            'products': '/api/products/',
            'categories': '/api/categories/',
            'orders': '/api/orders/',
            'admin': '/admin/',
            'swagger': '/swagger/',
            'schema': '/api/schema/'
        }
    })

urlpatterns = [
    path('admin/', admin.site.urls),
    path('', api_root, name='api-root'),
    path('api/', include('store.urls')),
    path('api/schema/', SpectacularAPIView.as_view(), name='schema'),
    path('swagger/', SpectacularSwaggerView.as_view(url_name='schema'), name='swagger-ui'),
]

if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)