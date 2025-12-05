const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const cookieParser = require('cookie-parser');
const path = require('path');
require('dotenv').config();

// Import routes
const authRoutes = require('./src/routes/auth');
const adminRoutes = require('./src/routes/admin');
const userRoutes = require('./src/routes/user');
const bookingRoutes = require('./src/routes/booking');
const tripsRoutes = require('./src/routes/trips');

const app = express();

// Security middleware
app.use(helmet({
  contentSecurityPolicy: false,
}));

// CORS configuration - Allow all origins for development
app.use(cors({
  origin: true, // Allow all origins in development
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
}));

// Body parser middleware
app.use(express.json());
app.use(express.urlencoded({ extended: true }));
app.use(cookieParser());

// Logging middleware
if (process.env.NODE_ENV === 'development') {
  app.use(morgan('dev'));
}

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

// API Routes
app.use('/api/auth', authRoutes);
app.use('/api/admin', adminRoutes);
app.use('/api/trips', tripsRoutes);
app.use('/api/user', bookingRoutes);
app.use('/api', userRoutes);

// Root route
app.get('/', (req, res) => {
  res.json({
    success: true,
    message: 'Train Booking System API',
    version: '1.0.0',
    endpoints: {
      auth: '/api/auth',
      admin: '/api/admin',
      trips: '/api/trips',
      reservations: '/api/user/reservations',
      profile: '/api/profile',
      adminDashboard: '/admin',
    },
  });
});

// Admin dashboard route
app.get('/admin', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'admin', 'index.html'));
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'OK', timestamp: new Date().toISOString() });
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Route not found',
  });
});

// Error handling middleware
app.use((err, req, res, next) => {
  console.error('Error:', err);
  res.status(err.status || 500).json({
    success: false,
    message: err.message || 'Internal server error',
  });
});

const PORT = process.env.PORT || 3001;

app.listen(PORT, () => {
  console.log(`
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║          🚂 TRAIN BOOKING SYSTEM SERVER                  ║
║                                                           ║
║  Server running on: http://localhost:${PORT}               ║
║  Environment: ${process.env.NODE_ENV || 'development'}                        ║
║                                                           ║
║  API Endpoints:                                           ║
║  • Auth: http://localhost:${PORT}/api/auth                  ║
║  • Admin: http://localhost:${PORT}/api/admin                ║
║  • Trips: http://localhost:${PORT}/api/trips                ║
║  • Reservations: http://localhost:${PORT}/api/user/reservations  ║
║                                                           ║
║  Admin Dashboard: http://localhost:${PORT}/admin            ║
║                                                           ║
║  Database: PostgreSQL on port 5433                       ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
  `);
});

module.exports = app;
