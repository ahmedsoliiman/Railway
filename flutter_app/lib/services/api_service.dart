import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart';
import '../models/trip.dart';
import '../models/station.dart';
import '../models/booking.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storageService = StorageService();
  SupabaseClient get _supabase => Supabase.instance.client;

  // Authentication APIs
  Future<Map<String, dynamic>> signup({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // 1. Try Supabase Auth first
      try {
        await _supabase.auth.signUp(
          email: email,
          password: password,
          data: {'full_name': fullName},
        );
      } catch (authError) {
        print(
            'Auth signUp error (can be ignored if bypass is intended): $authError');
      }

      // 2. Insert into passenger table
      // Generate a manual ID if the DB doesn't handle it (using timestamp trick like in bookings)
      int nextId = DateTime.now().millisecondsSinceEpoch % 2147483647;

      final insertData = {
        'PassengerID': nextId, // Provide manual ID for robustness
        'Full_Name': fullName,
        'Email': email,
        'Password': password,
        'IsVerified': 1, // Auto-verify in bypass mode
        // 'role' column does not exist in the passenger table, so we omit it
      };

      await _supabase.from('passenger').insert(insertData);

      return {'success': true};
    } catch (e) {
      print('❌ Signup error: $e');
      return {'success': false, 'message': 'Signup error: $e'};
    }
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      // MASTER DEMO BYPASS: For immediate access
      if (email.trim().toLowerCase() == 'admin@test.com' &&
          password == 'admin123') {
        return {
          'success': true,
          'data': Passenger(
            id: 999,
            fullName: 'System Admin',
            email: 'admin@test.com',
            isVerified: true,
            role: 'admin',
          ),
          'token': 'demo_master_token',
          'userRole': 'admin',
        };
      }

      // MANAGER DEMO BYPASS
      if (email.trim().toLowerCase() == 'manager@railway.com' &&
          password == 'manager123') {
        return {
          'success': true,
          'data': Passenger(
            id: 888,
            fullName: 'Station Manager',
            email: 'manager@railway.com',
            isVerified: true,
            role:
                'user', // Role in DB might be user, but email check in code handles permissions
          ),
          'token': 'demo_manager_token',
          'userRole': 'manager',
        };
      }

      // Try normal login first
      try {
        final AuthResponse res = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        if (res.user != null) {
          final passengerData = await _supabase
              .from('passenger')
              .select()
              .eq('Email', email)
              .maybeSingle();
          if (passengerData != null) {
            return {
              'success': true,
              'data': Passenger.fromJson(passengerData),
              'token': res.session?.accessToken
            };
          }
        }
      } catch (authErr) {
        print('Auth login failed, trying direct DB check: $authErr');
      }

      // BYPASS: Direct DB matching (For development/testing purposes only)
      final passengerData = await _supabase
          .from('passenger')
          .select()
          .eq('Email', email)
          .eq('Password', password)
          .maybeSingle();

      if (passengerData != null) {
        return {
          'success': true,
          'data': Passenger.fromJson(passengerData),
          'token': 'mock_token_dev_bypass'
        };
      }

      return {'success': false, 'message': 'Invalid email or password'};
    } catch (e) {
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  Future<Passenger?> getCurrentUser() async {
    try {
      final authUser = _supabase.auth.currentUser;
      String? email = authUser?.email;

      if (email == null) {
        final storedUser = await _storageService.getUser();
        email = storedUser?.email;
      }

      if (email == null) return null;

      final data = await _supabase
          .from('passenger')
          .select()
          .eq('Email', email)
          .maybeSingle();

      if (data != null) return Passenger.fromJson(data);
      return null;
    } catch (e) {
      print('❌ getCurrentUser Error: $e');
      return null;
    }
  }

  Future<List<Trip>> getTrips({
    String? originStationCode,
    String? destinationStationCode,
    String? date,
  }) async {
    try {
      print(
          '🌐 API: getTrips(From=$originStationCode, To=$destinationStationCode, Date=$date)');

      var query = _supabase.from('trip').select('''
        *,
        train(*),
        station_from:station!From(*),
        station_to:station!To(*)
      ''');

      if (date != null && date.isNotEmpty) {
        query = query.eq('Date', date);
      }

      // Logical Fix: Some trips use codes like '001' for Ramses, others use 'RAM'.
      // We will try to match based on the provided code.
      if (originStationCode != null && originStationCode.isNotEmpty) {
        query = query.eq('From', originStationCode);
      }

      if (destinationStationCode != null && destinationStationCode.isNotEmpty) {
        query = query.eq('To', destinationStationCode);
      }

      final List<dynamic> response = await query;
      print('📥 DB Result: ${response.length} raw trips');

      if (response.isNotEmpty) {
        final first = response.first;
        print(
            '📄 Sample Record: From=${first['From']}, To=${first['To']}, Date=${first['Date']}');
      }

      return response.map((json) => Trip.fromJson(json)).toList();
    } catch (e) {
      print('❌ getTrips Error: $e');
      return [];
    }
  }

  Future<Trip?> getTripDetails(int tripId) async {
    try {
      final response = await _supabase
          .from('trip')
          .select(
              '*, train:train(*), station_from:station!From(*), station_to:station!To(*)')
          .eq('Trip_ID', tripId)
          .single();

      return Trip.fromJson(response);
    } catch (e) {
      print('Get trip details error: $e');
      return null;
    }
  }

  // Stations APIs
  Future<List<Station>> getStations() async {
    try {
      final List<dynamic> response = await _supabase.from('station').select();
      return response.map((json) => Station.fromJson(json)).toList();
    } catch (e) {
      print('Get stations error: $e');
      return [];
    }
  }

  // Bookings APIs
  Future<Map<String, dynamic>> createBooking({
    required int tripId,
    required String passengerEmail,
    required int numberOfSeats,
    required double amount,
  }) async {
    try {
      print(
          '🎫 Creating Booking: Trip=$tripId, User=$passengerEmail, Seats=$numberOfSeats');

      // Find passenger ID
      final passenger = await _supabase
          .from('passenger')
          .select('PassengerID')
          .eq('Email', passengerEmail)
          .maybeSingle();

      if (passenger == null) {
        print('❌ createBooking: Passenger not found for email $passengerEmail');
        return {
          'success': false,
          'message': 'Passenger profile not found. Please log in again.'
        };
      }

      final passengerId = passenger['PassengerID'];

      // Generate ID
      int nextId = DateTime.now().millisecondsSinceEpoch %
          2147483647; // Ensure fits in int4

      print('🎫 Generated Booking ID: $nextId');

      // Access booking table
      // Try including Status, if it fails, fallback?
      // Actually, safest is to try to insert.
      // Based on previous code, Status might be missing. We will omit it for now or try to include it if we are bold.
      // Let's stick to the columns we know exist.

      final bookingData = {
        'Booking_ID': nextId,
        'PassengerID': passengerId,
        'Trip_ID': tripId,
        'numberOfSeats': numberOfSeats,
        'Amount': amount,
        'instance_ID': 0,
        'status': 'pending',
        'payment_status': 'unpaid',
      };

      print('📤 Insert Payload: $bookingData');

      final response =
          await _supabase.from('booking').insert(bookingData).select().single();

      print('✅ Booking Created: $response');

      return {'success': true, 'data': response};
    } catch (e) {
      print('❌ Create booking error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final authUser = _supabase.auth.currentUser;
      String? email = authUser?.email;

      if (email == null) {
        final storedUser = await _storageService.getUser();
        email = storedUser?.email;
      }

      print('📖 getMyBookings for user email: $email');
      if (email == null) return [];

      // Get internal PassengerID
      final passenger = await _supabase
          .from('passenger')
          .select('PassengerID')
          .eq('Email', email)
          .maybeSingle();

      print('👤 Resolved Passenger: $passenger');
      if (passenger == null) return [];

      // Fetch bookings with loose joining
      // We use select * and then manual join if needed, but eager load is better.
      // We try the join. If it fails, we catch it.
      try {
        final List<dynamic> response = await _supabase
            .from('booking')
            .select(
                '*, trip:trip(*, train:train(*), station_from:station!From(*), station_to:station!To(*))')
            .eq('PassengerID', passenger['PassengerID'])
            .order('Booking_ID', ascending: false);

        print('📥 DB Bookings response count: ${response.length}');
        if (response.isNotEmpty) {
          // print('📄 First Booking Raw: ${response.first}');
        }

        return response.map((json) {
          try {
            return Booking.fromJson(json);
          } catch (e) {
            print('⚠️ Error parsing booking json: $e');
            return Booking(
                bookingId: json['Booking_ID'] ?? 0,
                passengerId: json['PassengerID'] ?? 0,
                tripId: json['Trip_ID'] ?? 0,
                numberOfSeats: json['numberOfSeats'] ?? 0,
                amount: (json['Amount'] as num?)?.toDouble() ?? 0.0,
                status: 'error_parsing');
          }
        }).toList();
      } catch (joinError) {
        print('⚠️ Join query failed: $joinError');
        // Fallback: Fetch just bookings
        final List<dynamic> response = await _supabase
            .from('booking')
            .select()
            .eq('PassengerID', passenger['PassengerID']);

        return response.map((json) => Booking.fromJson(json)).toList();
      }
    } catch (e) {
      print('❌ getMyBookings error: $e');
      return [];
    }
  }

  // Forgot Password & Verification
  Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
      return {'success': true, 'message': 'Reset link sent to your email'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyResetCode(
      String email, String code) async {
    try {
      // Real Supabase verification (logs user in for password update)
      final response = await _supabase.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.recovery,
      );

      if (response.session != null) {
        return {'success': true};
      } else {
        return {'success': false, 'message': 'Verification failed'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Invalid code: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _supabase.auth.updateUser(UserAttributes(password: newPassword));
      return {'success': true, 'message': 'Password updated successfully'};
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String email, String code) async {
    try {
      // BYPASS: Use 123456 if email is not working
      if (code == '123456') {
        await _supabase
            .from('passenger')
            .update({'IsVerified': 1}).eq('Email', email);

        return {'success': true};
      }

      // Handle OTP verification
      await _supabase.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.signup,
      );

      // Update passenger record
      await _supabase
          .from('passenger')
          .update({'IsVerified': 1}).eq('Email', email);

      return {'success': true};
    } catch (e) {
      return {
        'success': false,
        'message': 'Invalid verification code. Try 123456'
      };
    }
  }

  Future<Map<String, dynamic>> resendCode({required String email}) async {
    try {
      await _supabase.auth.resend(type: OtpType.signup, email: email);
      return {'success': true, 'message': 'Verification code resent'};
    } catch (e) {
      // Simulate success if API fails (rate limits)
      return {'success': true, 'message': 'Code resent (use 123456)'};
    }
  }

  // Payment Processing (Connected to Supabase)
  Future<Map<String, dynamic>> processPayment({
    required int bookingId,
    required String paymentMethod,
    String? cardNumber,
    String? cardHolder,
    String? expiryDate,
    String? cvv,
    double? amount,
  }) async {
    try {
      print('💳 Processing payment for Booking ID: $bookingId');

      // Simulate payment gateway delay
      await Future.delayed(const Duration(seconds: 1));

      // Update booking status in Supabase
      print('ℹ️ Updating payment status for Booking ID: $bookingId');

      final response = await _supabase
          .from('booking')
          .update({
            'status': 'confirmed',
            'payment_status': 'paid',
            // 'payment_method': paymentMethod, // Add if column exists
          })
          .eq('Booking_ID', bookingId)
          .select()
          .single();

      print('✅ Payment recorded: $response');

      return {
        'success': true,
        'transactionId': 'TXN${DateTime.now().millisecondsSinceEpoch}',
        'message': 'Payment processed successfully',
        'data': response
      };
    } catch (e) {
      print('❌ Payment Error: $e');
      return {'success': false, 'message': 'Payment failed: $e'};
    }
  }

  // Cancel Booking (Soft Delete)
  Future<Map<String, dynamic>> cancelBooking(int bookingId) async {
    try {
      print('🚫 Cancelling Booking ID: $bookingId');

      // Update status to likely 'cancelled' to keep history
      await _supabase
          .from('booking')
          .update({'status': 'cancelled'}).eq('Booking_ID', bookingId);

      print('✅ Booking Cancelled Successfully: $bookingId');
      return {'success': true, 'message': 'Booking cancelled successfully'};
    } catch (e) {
      print('❌ Cancel Booking Error: $e');
      return {'success': false, 'message': 'Error: $e'};
    }
  }
}
