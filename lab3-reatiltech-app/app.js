const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const swaggerUi = require('swagger-ui-express');
const swaggerSpec = require('./swagger');
const client = require('prom-client');
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// ── Prometheus metrics setup ────────────────────────────────
const register = new client.Registry();
client.collectDefaultMetrics({ register, prefix: 'retailtech_' });

const httpRequestsTotal = new client.Counter({
  name: 'http_requests_total',
  help: 'Total de peticiones HTTP',
  labelNames: ['method', 'route', 'status_code'],
  registers: [register]
});

const httpRequestDuration = new client.Histogram({
  name: 'http_request_duration_seconds',
  help: 'Duración de peticiones HTTP en segundos',
  labelNames: ['method', 'route', 'status_code'],
  buckets: [0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5],
  registers: [register]
});

// Middleware
app.use(helmet({ contentSecurityPolicy: false }));
app.use(cors());
app.use(express.json());

// Middleware de métricas HTTP
app.use((req, res, next) => {
  const end = httpRequestDuration.startTimer();
  res.on('finish', () => {
    const route = req.route ? req.route.path : req.path;
    httpRequestsTotal.labels(req.method, route, res.statusCode).inc();
    end({ method: req.method, route, status_code: res.statusCode });
  });
  next();
});

// Documentación Swagger
app.use('/docs', swaggerUi.serve, swaggerUi.setup(swaggerSpec));

// Endpoint de métricas para Prometheus
app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

// Mock database - productos de tecnología
let products = [
  {
    id: 1,
    name: 'Laptop Dell XPS 13',
    price: 1299.99,
    category: 'laptops',
    stock: 15
  },
  {
    id: 2,
    name: 'iPhone 15 Pro',
    price: 999.99,
    category: 'smartphones',
    stock: 30
  },
  {
    id: 3,
    name: 'Samsung Galaxy S24',
    price: 899.99,
    category: 'smartphones',
    stock: 25
  },
  {
    id: 4,
    name: 'Sony WH-1000XM5',
    price: 349.99,
    category: 'audio',
    stock: 50
  }
];

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'UP',
    timestamp: new Date().toISOString(),
    service: 'product-service'
  });
});

// GET /api/products - Obtener todos los productos
app.get('/api/products', (req, res) => {
  const { category } = req.query;
  
  if (category) {
    const filtered = products.filter(p => p.category === category);
    return res.json(filtered);
  }
  
  res.json(products);
});

// GET /api/products/:id - Obtener producto por ID
app.get('/api/products/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const product = products.find(p => p.id === id);
  
  if (!product) {
    return res.status(404).json({ error: 'Producto no encontrado' });
  }
  
  res.json(product);
});

// POST /api/products - Crear nuevo producto
app.post('/api/products', (req, res) => {
  const { name, price, category, stock } = req.body;
  
  // Validación básica
  if (!name || !price || !category || stock === undefined) {
    return res.status(400).json({ 
      error: 'Faltan campos requeridos: name, price, category, stock' 
    });
  }
  
  const newProduct = {
    id: products.length + 1,
    name,
    price: parseFloat(price),
    category,
    stock: parseInt(stock)
  };
  
  products.push(newProduct);
  res.status(201).json(newProduct);
});

// PUT /api/products/:id - Actualizar producto
app.put('/api/products/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const productIndex = products.findIndex(p => p.id === id);
  
  if (productIndex === -1) {
    return res.status(404).json({ error: 'Producto no encontrado' });
  }
  
  const { name, price, category, stock } = req.body;
  
  products[productIndex] = {
    ...products[productIndex],
    ...(name && { name }),
    ...(price && { price: parseFloat(price) }),
    ...(category && { category }),
    ...(stock !== undefined && { stock: parseInt(stock) })
  };
  
  res.json(products[productIndex]);
});

// DELETE /api/products/:id - Eliminar producto
app.delete('/api/products/:id', (req, res) => {
  const id = parseInt(req.params.id);
  const productIndex = products.findIndex(p => p.id === id);
  
  if (productIndex === -1) {
    return res.status(404).json({ error: 'Producto no encontrado' });
  }
  
  products.splice(productIndex, 1);
  res.status(204).send();
});

// Manejo de errores 404
app.use((req, res) => {
  res.status(404).json({ error: 'Endpoint no encontrado' });
});

// Manejo de errores global
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ error: 'Error interno del servidor' });
});

// Iniciar servidor solo si no está en modo test
if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`🚀 Servidor corriendo en puerto ${PORT}`);
    console.log(`🏥 Health check: http://localhost:${PORT}/health`);
  });
}

module.exports = app;
