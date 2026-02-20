const request = require('supertest');
const app = require('./app');

describe('Product Service API', () => {
  
  describe('GET /health', () => {
    it('debería retornar status UP', async () => {
      const res = await request(app).get('/health');
      
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('status', 'UP');
      expect(res.body).toHaveProperty('service', 'product-service');
    });
  });

  describe('GET /api/products', () => {
    it('debería retornar todos los productos', async () => {
      const res = await request(app).get('/api/products');
      
      expect(res.statusCode).toBe(200);
      expect(Array.isArray(res.body)).toBe(true);
      expect(res.body.length).toBeGreaterThan(0);
    });

    it('debería filtrar productos por categoría', async () => {
      const res = await request(app)
        .get('/api/products')
        .query({ category: 'smartphones' });
      
      expect(res.statusCode).toBe(200);
      expect(res.body.every(p => p.category === 'smartphones')).toBe(true);
    });
  });

  describe('GET /api/products/:id', () => {
    it('debería retornar un producto específico', async () => {
      const res = await request(app).get('/api/products/1');
      
      expect(res.statusCode).toBe(200);
      expect(res.body).toHaveProperty('id', 1);
      expect(res.body).toHaveProperty('name');
    });

    it('debería retornar 404 para producto inexistente', async () => {
      const res = await request(app).get('/api/products/999');
      
      expect(res.statusCode).toBe(404);
      expect(res.body).toHaveProperty('error');
    });
  });

  describe('POST /api/products', () => {
    it('debería crear un nuevo producto', async () => {
      const newProduct = {
        name: 'MacBook Pro M3',
        price: 2499.99,
        category: 'laptops',
        stock: 10
      };

      const res = await request(app)
        .post('/api/products')
        .send(newProduct);
      
      expect(res.statusCode).toBe(201);
      expect(res.body).toHaveProperty('id');
      expect(res.body.name).toBe(newProduct.name);
    });

    it('debería retornar 400 si faltan campos', async () => {
      const res = await request(app)
        .post('/api/products')
        .send({ name: 'Incomplete Product' });
      
      expect(res.statusCode).toBe(400);
      expect(res.body).toHaveProperty('error');
    });
  });

  describe('PUT /api/products/:id', () => {
    it('debería actualizar un producto existente', async () => {
      const updates = {
        price: 1399.99,
        stock: 20
      };

      const res = await request(app)
        .put('/api/products/1')
        .send(updates);
      
      expect(res.statusCode).toBe(200);
      expect(res.body.price).toBe(updates.price);
      expect(res.body.stock).toBe(updates.stock);
    });

    it('debería retornar 404 para producto inexistente', async () => {
      const res = await request(app)
        .put('/api/products/999')
        .send({ price: 100 });
      
      expect(res.statusCode).toBe(404);
    });
  });

  describe('DELETE /api/products/:id', () => {
    it('debería eliminar un producto', async () => {
      const res = await request(app).delete('/api/products/4');
      
      expect(res.statusCode).toBe(204);
    });

    it('debería retornar 404 para producto inexistente', async () => {
      const res = await request(app).delete('/api/products/999');
      
      expect(res.statusCode).toBe(404);
    });
  });

  describe('Error handling', () => {
    it('debería retornar 404 para rutas no existentes', async () => {
      const res = await request(app).get('/api/nonexistent');
      
      expect(res.statusCode).toBe(404);
    });
  });
});
