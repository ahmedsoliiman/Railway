# Quick Setup Guide for New Developers

## Prerequisites
1. Install PostgreSQL (make sure it's running on port 5433)
2. Install Node.js (v14 or higher)

## Setup Steps

### 1. Clone the Repository
```bash
git clone <repository-url>
cd "Train System/Backend"
```

### 2. Install Dependencies
```bash
npm install
```

### 3. Configure Environment
Create a `.env` file in the Backend folder:

```env
PORT=3001
NODE_ENV=development

DB_HOST=localhost
DB_PORT=5433
DB_NAME=train_system
DB_USER=postgres
DB_PASSWORD=your_postgres_password_here

JWT_SECRET=your_secret_key_here
JWT_EXPIRE=7d

EMAIL_HOST=smtp.gmail.com
EMAIL_PORT=587
EMAIL_USER=your_email@gmail.com
EMAIL_PASSWORD=your_app_password
EMAIL_FROM=Train Booking System <your_email@gmail.com>
```

### 4. Setup Database (ONE COMMAND!)
```bash
npm run setup
```

This will automatically:
- ✅ Create the `train_system` database
- ✅ Create all 8 tables (users, stations, trains, carriages, etc.)
- ✅ Add indexes for performance
- ✅ Insert sample data
- ✅ Create admin user

### 5. Start the Server
```bash
npm run dev
```

The server will start on http://localhost:3001

## Default Admin Credentials
- **Email:** admin@trainbooking.com
- **Password:** Admin@123

## Sample Data Included
- ✅ 4 Stations (Cairo, Alexandria, Aswan, Luxor)
- ✅ 3 Trains (Express, Premium, Standard)
- ✅ 4 Carriages (First Class A/B, Second Class A/B)
- ✅ 3 Sample Trips

## Troubleshooting

### Database Already Exists
If you see "Database already exists", you need to manually drop it first:
```bash
psql -U postgres -p 5433
DROP DATABASE train_system;
\q
npm run setup
```

### Connection Error
- Make sure PostgreSQL is running on port 5433
- Check your DB_PASSWORD in .env matches your PostgreSQL password
- Verify PostgreSQL is accepting connections

### Port Already in Use
If port 3001 is taken, change PORT in .env file

## API Testing
Once running, test the API:
- Admin Dashboard: http://localhost:3001/admin
- Health Check: http://localhost:3001/health
- API Root: http://localhost:3001/

## Next Steps
1. Open http://localhost:3001/admin
2. Login with admin credentials
3. Explore the admin dashboard
4. Test creating stations, trains, and trips

## Need Help?
Check the full README.md for detailed API documentation.
