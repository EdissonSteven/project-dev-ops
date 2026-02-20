const swaggerSpec = {
  openapi: '3.0.0',
  info: {
    title: 'RetailTech Product Service API',
    version: '1.0.0',
    description: 'Microservicio de catálogo de productos para RetailTech E-Commerce'
  },
  servers: [
    {
      url: 'http://localhost:3000',
      description: 'Servidor de desarrollo'
    }
  ],
  tags: [
    { name: 'Health', description: 'Estado del servicio' },
    { name: 'Products', description: 'Gestión de productos' }
  ],
  components: {
    schemas: {
      Product: {
        type: 'object',
        properties: {
          id:       { type: 'integer', example: 1 },
          name:     { type: 'string',  example: 'Laptop Dell XPS 13' },
          price:    { type: 'number',  format: 'float', example: 1299.99 },
          category: { type: 'string',  example: 'laptops' },
          stock:    { type: 'integer', example: 15 }
        }
      },
      ProductInput: {
        type: 'object',
        required: ['name', 'price', 'category', 'stock'],
        properties: {
          name:     { type: 'string',  example: 'Laptop Dell XPS 13' },
          price:    { type: 'number',  format: 'float', example: 1299.99 },
          category: { type: 'string',  example: 'laptops' },
          stock:    { type: 'integer', example: 15 }
        }
      },
      Error: {
        type: 'object',
        properties: {
          error: { type: 'string', example: 'Producto no encontrado' }
        }
      }
    }
  },
  paths: {
    '/health': {
      get: {
        tags: ['Health'],
        summary: 'Health check del servicio',
        responses: {
          200: {
            description: 'Servicio activo',
            content: {
              'application/json': {
                schema: {
                  type: 'object',
                  properties: {
                    status:    { type: 'string', example: 'UP' },
                    timestamp: { type: 'string', format: 'date-time' },
                    service:   { type: 'string', example: 'product-service' }
                  }
                }
              }
            }
          }
        }
      }
    },
    '/api/products': {
      get: {
        tags: ['Products'],
        summary: 'Obtener todos los productos',
        parameters: [
          {
            name: 'category',
            in: 'query',
            description: 'Filtrar por categoría',
            required: false,
            schema: { type: 'string', example: 'laptops' }
          }
        ],
        responses: {
          200: {
            description: 'Lista de productos',
            content: {
              'application/json': {
                schema: {
                  type: 'array',
                  items: { '$ref': '#/components/schemas/Product' }
                }
              }
            }
          }
        }
      },
      post: {
        tags: ['Products'],
        summary: 'Crear un nuevo producto',
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { '$ref': '#/components/schemas/ProductInput' }
            }
          }
        },
        responses: {
          201: {
            description: 'Producto creado',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Product' }
              }
            }
          },
          400: {
            description: 'Datos inválidos',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Error' }
              }
            }
          }
        }
      }
    },
    '/api/products/{id}': {
      get: {
        tags: ['Products'],
        summary: 'Obtener un producto por ID',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'integer', example: 1 }
          }
        ],
        responses: {
          200: {
            description: 'Producto encontrado',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Product' }
              }
            }
          },
          404: {
            description: 'Producto no encontrado',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Error' }
              }
            }
          }
        }
      },
      put: {
        tags: ['Products'],
        summary: 'Actualizar un producto',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'integer', example: 1 }
          }
        ],
        requestBody: {
          required: true,
          content: {
            'application/json': {
              schema: { '$ref': '#/components/schemas/ProductInput' }
            }
          }
        },
        responses: {
          200: {
            description: 'Producto actualizado',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Product' }
              }
            }
          },
          404: {
            description: 'Producto no encontrado',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Error' }
              }
            }
          }
        }
      },
      delete: {
        tags: ['Products'],
        summary: 'Eliminar un producto',
        parameters: [
          {
            name: 'id',
            in: 'path',
            required: true,
            schema: { type: 'integer', example: 1 }
          }
        ],
        responses: {
          204: { description: 'Producto eliminado' },
          404: {
            description: 'Producto no encontrado',
            content: {
              'application/json': {
                schema: { '$ref': '#/components/schemas/Error' }
              }
            }
          }
        }
      }
    }
  }
};

module.exports = swaggerSpec;
