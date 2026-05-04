require('dotenv').config();

const config = {
  databaseUrl: process.env.DATABASE_URL,
  secretKey: process.env.SECRET_KEY || 'change-me-in-production',
  accessTokenExpireMinutes: parseInt(process.env.ACCESS_TOKEN_EXPIRE_MINUTES || '30', 10),
  environment: process.env.ENVIRONMENT || 'development',
  corsOrigins: process.env.CORS_ORIGINS || '*',
  logLevel: process.env.LOG_LEVEL || 'info',
  anthropicApiKey: process.env.ANTHROPIC_API_KEY || '',
  port: parseInt(process.env.PORT || '8000', 10),

  get corsOriginsList() {
    if (this.corsOrigins === '*') return '*';
    return this.corsOrigins.split(',').map(o => o.trim());
  },
};

module.exports = config;