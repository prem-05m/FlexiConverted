import swaggerJsDoc from 'swagger-jsdoc';
import swaggerUi from 'swagger-ui-express';
import { Application } from 'express';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'FlexiConvert API',
      version: '1.0.0',
      description: 'API documentation for FlexiConvert Backend Engine',
    },
    servers: [
      {
        url: 'http://localhost:3000',
        description: 'Development server',
      },
    ],
    components: {
      securitySchemes: {
        bearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
        apiKeyAuth: {
          type: 'apiKey',
          in: 'header',
          name: 'x-api-key',
        }
      },
    },
    security: [
      {
        bearerAuth: [],
        apiKeyAuth: []
      },
    ],
  },
  apis: ['./src/routes/*.ts', './src/controllers/*.ts'], // Generate docs from annotations
};

const specs = swaggerJsDoc(options);

export const setupSwagger = (app: Application) => {
  app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
};
