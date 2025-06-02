import swaggerJSDoc from 'swagger-jsdoc';
import { CONFIG } from './env';

const options = {
  definition: {
    openapi: '3.0.0',
    info: {
      title: 'E-commerce API Documentation',
      version: '1.0.0',
      description: 'Documentation for Clean Architecture E-commerce API built with Node.js, TypeScript, and MongoDB',
    },
    servers: [
      {
        url: `${CONFIG.SERVER_URL}`,
        // url: `${CONFIG.CLIENT_URL}`,
        description: 'Development Server',
      },

    ],

    components: {
      securitySchemes: {
        BearerAuth: {
          type: 'http',
          scheme: 'bearer',
          bearerFormat: 'JWT',
        },
      },
    },

  },

  apis: ['src/**/*.swagger.yaml']
};

const swaggerSpec = swaggerJSDoc(options);
export default swaggerSpec;