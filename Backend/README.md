# Train Booking System

A professional train booking system with admin dashboard built with Node.js, Express, and PostgreSQL.

## Features

### Admin Dashboard
- Manage stations (add, edit, delete)
- Manage trains (add, edit, delete)
- Manage tours/schedules (add, edit, delete)
- View all reservations
- User management

### Public User Features
- User registration with email confirmation
- Login/Logout functionality
- Browse available tours
- Book train tickets
- View profile and reservations
- Manage bookings

## Setup Instructions

### Prerequisites
- Node.js (v14 or higher)
- PostgreSQL (running on port 5433)
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Configure environment variables:
   - Copy `.env.example` to `.env`
   - Update database credentials (port 5433, password: testpass)
   - Update email configuration for confirmation codes

3. Create database:
```bash
# Connect to PostgreSQL and create database
psql -U postgres -p 5433
CREATE DATABASE train_system;
\q
```

4. Run database migrations:
```bash
npm run migrate
```

5. Start the server:
```bash
# Development mode
npm run dev

# Production mode
npm start
```

## API Endpoints

### Authentication
- `POST /api/auth/signup` - Register new user
- `POST /api/auth/verify-email` - Verify email with confirmation code
- `POST /api/auth/login` - User login
- `POST /api/auth/logout` - User logout
- `GET /api/auth/me` - Get current user profile

### Admin Routes (requires admin role)
- `GET /api/admin/stations` - Get all stations
- `POST /api/admin/stations` - Create station
- `PUT /api/admin/stations/:id` - Update station
- `DELETE /api/admin/stations/:id` - Delete station
- `GET /api/admin/trains` - Get all trains
- `POST /api/admin/trains` - Create train
- `PUT /api/admin/trains/:id` - Update train
- `DELETE /api/admin/trains/:id` - Delete train
- `GET /api/admin/tours` - Get all tours
- `POST /api/admin/tours` - Create tour
- `PUT /api/admin/tours/:id` - Update tour
- `DELETE /api/admin/tours/:id` - Delete tour

### User Routes
- `GET /api/tours` - Browse available tours
- `GET /api/tours/:id` - Get tour details
- `POST /api/reservations` - Book a tour
- `GET /api/reservations` - Get user's reservations
- `DELETE /api/reservations/:id` - Cancel reservation
- `GET /api/profile` - Get user profile
- `PUT /api/profile` - Update user profile

## Admin Dashboard

Access the admin dashboard at: `http://localhost:3000/admin`

Default admin credentials (created during migration):
- Email: admin@trainbooking.com
- Password: Admin@123

## Database Schema

- **users** - User accounts and authentication
- **stations** - Train stations
- **trains** - Train information
- **tours** - Scheduled train tours
- **reservations** - User bookings
- **email_verifications** - Email confirmation codes

## Technology Stack

- **Backend**: Node.js, Express.js
- **Database**: PostgreSQL
- **Authentication**: JWT, bcrypt
- **Email**: Nodemailer
- **Frontend**: HTML, CSS, JavaScript (Vanilla)

## Security Features

- Password hashing with bcrypt
- JWT authentication
- Email verification
- Protected routes
- SQL injection prevention
- CORS configuration
- Helmet security headers

## License

ISC
