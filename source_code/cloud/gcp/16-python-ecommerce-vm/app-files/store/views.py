from rest_framework import viewsets, filters, status
from rest_framework.decorators import action
from rest_framework.response import Response
from django_filters.rest_framework import DjangoFilterBackend
from django.db.models import Q, Count, Sum
from .models import Category, Product, Customer, Order, OrderItem
from .serializers import (
    CategorySerializer, ProductSerializer, ProductListSerializer,
    CustomerSerializer, OrderSerializer
)

class CategoryViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing product categories.
    Provides CRUD operations for categories.
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']

    @action(detail=True, methods=['get'])
    def products(self, request, pk=None):
        """Get all products in this category"""
        category = self.get_object()
        products = category.products.filter(is_active=True)
        serializer = ProductListSerializer(products, many=True)
        return Response(serializer.data)

class ProductViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing products.
    Supports filtering by category, price range, and stock status.
    """
    queryset = Product.objects.select_related('category').all()
    filter_backends = [DjangoFilterBackend, filters.SearchFilter, filters.OrderingFilter]
    filterset_fields = ['category', 'is_active']
    search_fields = ['name', 'description', 'category__name']
    ordering_fields = ['name', 'price', 'created_at', 'stock_quantity']
    ordering = ['-created_at']

    def get_serializer_class(self):
        if self.action == 'list':
            return ProductListSerializer
        return ProductSerializer

    def get_queryset(self):
        queryset = super().get_queryset()
        
        # Filter by price range
        min_price = self.request.query_params.get('min_price')
        max_price = self.request.query_params.get('max_price')
        
        if min_price:
            queryset = queryset.filter(price__gte=min_price)
        if max_price:
            queryset = queryset.filter(price__lte=max_price)
        
        # Filter by stock status
        in_stock = self.request.query_params.get('in_stock')
        if in_stock and in_stock.lower() == 'true':
            queryset = queryset.filter(stock_quantity__gt=0)
        elif in_stock and in_stock.lower() == 'false':
            queryset = queryset.filter(stock_quantity=0)
            
        return queryset

    @action(detail=False, methods=['get'])
    def featured(self, request):
        """Get featured products (products with highest stock)"""
        products = self.get_queryset().filter(
            is_active=True, 
            stock_quantity__gt=0
        ).order_by('-stock_quantity')[:10]
        
        serializer = ProductListSerializer(products, many=True)
        return Response(serializer.data)

    @action(detail=False, methods=['get'])
    def low_stock(self, request):
        """Get products with low stock (less than 10 items)"""
        products = self.get_queryset().filter(
            is_active=True,
            stock_quantity__lt=10,
            stock_quantity__gt=0
        ).order_by('stock_quantity')
        
        serializer = ProductListSerializer(products, many=True)
        return Response(serializer.data)

class CustomerViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing customers.
    """
    queryset = Customer.objects.select_related('user').all()
    serializer_class = CustomerSerializer
    filter_backends = [filters.SearchFilter, filters.OrderingFilter]
    search_fields = ['user__username', 'user__email', 'user__first_name', 'user__last_name']
    ordering_fields = ['user__username', 'created_at']
    ordering = ['-created_at']

    @action(detail=True, methods=['get'])
    def orders(self, request, pk=None):
        """Get all orders for this customer"""
        customer = self.get_object()
        orders = customer.orders.all().order_by('-created_at')
        serializer = OrderSerializer(orders, many=True)
        return Response(serializer.data)

class OrderViewSet(viewsets.ModelViewSet):
    """
    API endpoint for managing orders.
    """
    queryset = Order.objects.select_related('customer__user').prefetch_related('items__product').all()
    serializer_class = OrderSerializer
    filter_backends = [DjangoFilterBackend, filters.OrderingFilter]
    filterset_fields = ['status', 'customer']
    ordering_fields = ['created_at', 'total_amount', 'status']
    ordering = ['-created_at']

    @action(detail=False, methods=['get'])
    def statistics(self, request):
        """Get order statistics"""
        total_orders = self.get_queryset().count()
        total_revenue = self.get_queryset().aggregate(
            total=Sum('total_amount')
        )['total'] or 0
        
        status_breakdown = self.get_queryset().values('status').annotate(
            count=Count('id')
        ).order_by('status')
        
        return Response({
            'total_orders': total_orders,
            'total_revenue': total_revenue,
            'status_breakdown': list(status_breakdown)
        })

    @action(detail=True, methods=['patch'])
    def update_status(self, request, pk=None):
        """Update order status"""
        order = self.get_object()
        new_status = request.data.get('status')
        
        if new_status not in dict(Order.STATUS_CHOICES):
            return Response(
                {'error': 'Invalid status'}, 
                status=status.HTTP_400_BAD_REQUEST
            )
        
        order.status = new_status
        order.save()
        
        serializer = self.get_serializer(order)
        return Response(serializer.data)