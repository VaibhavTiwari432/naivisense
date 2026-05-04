const express = require('express');
const cors = require('cors');
const config = require('./config/config');

const authRoutes = require('./routes/auth');
const therapistRoutes = require('./routes/therapist');
const childrenRoutes = require('./routes/children');
const sessionsRoutes = require('./routes/sessions');
const feedbackRoutes = require('./routes/feedback');
const tasksRoutes = require('./routes/tasks');
const reportsRoutes = require('./routes/reports');
const intelligenceRoutes = require('./routes/intelligence');
const adminRoutes = require('./routes/admin');

const app = express();

app.use(cors({
  origin: config.corsOriginsList,
  credentials: true,
}));
app.use(express.json());

app.get('/', (req, res) => res.json({ message: 'NaiviSense API', status: 'running' }));
app.get('/health', (req, res) => res.json({ status: 'healthy' }));

app.use('/api/v1/auth', authRoutes);
app.use('/api/v1/therapist', therapistRoutes);
app.use('/api/v1/children', childrenRoutes);
app.use('/api/v1/sessions', sessionsRoutes);
app.use('/api/v1/feedback', feedbackRoutes);
app.use('/api/v1/tasks', tasksRoutes);
app.use('/api/v1/reports', reportsRoutes);
app.use('/api/v1/intelligence', intelligenceRoutes);
app.use('/api/v1/admin', adminRoutes);

// Global error handler
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ detail: 'Internal server error' });
});

module.exports = app;