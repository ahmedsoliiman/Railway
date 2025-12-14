const { Booking, Trip, Train, Station, User, TripDeparture, sequelize } = require('../models');
const { Op } = require('sequelize');
const crypto = require('crypto');
const emailService = require('../utils/emailService');

// Generate booking reference
const generateBookingReference = () => {
  return 'BK' + Date.now() + crypto.randomBytes(2).toString('hex').toUpperCase();
};

// @desc    Get user's reservations
// @route   GET /api/user/reservations
// @access  Private
exports.getUserReservations = async (req, res) => {
  try {
    const reservations = await Booking.findAll({
      where: { user_id: req.user.id },
      include: [
        {
          model: TripDeparture,
          as: 'tripDeparture',
          include: [
            {
              model: Trip,
              as: 'trip',
              include: [
                { model: Train, as: 'train' },
                { model: Station, as: 'departureStation' },
                { model: Station, as: 'arrivalStation' },
              ],
            },
          ],
        },
      ],
      order: [['created_at', 'DESC']],
    });

    res.json({
      success: true,
      data: reservations.map(r => ({
        id: r.id,
        seatClass: r.seat_class,
        seatNumber: r.seat_number,
        numberOfSeats: r.number_of_seats,
        totalPrice: parseFloat(r.total_price),
        bookingReference: r.booking_reference,
        status: r.status,
        tripDeparture: {
          id: r.tripDeparture.trip_departure_id,
          departureTime: r.tripDeparture.departure_time,
          arrivalTime: r.tripDeparture.arrival_time,
          trip: {
            id: r.tripDeparture.trip.id,
            train: {
              trainNumber: r.tripDeparture.trip.train.train_number,
            },
            departureStation: {
              name: r.tripDeparture.trip.departureStation.name,
              city: r.tripDeparture.trip.departureStation.city,
            },
            arrivalStation: {
              name: r.tripDeparture.trip.arrivalStation.name,
              city: r.tripDeparture.trip.arrivalStation.city,
            },
          },
        },
        createdAt: r.created_at,
      })),
    });
  } catch (error) {
    console.error('Get reservations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch reservations',
    });
  }
};

// @desc    Create Booking (initial booking - pending payment)
// @route   POST /api/user/reservations
// @access  Private
exports.createReservation = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { tourId, tripDepartureId, seatClass, numberOfSeats = 1 } = req.body;

    // Validation
    if (!tourId || !seatClass) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields (tourId, seatClass)',
      });
    }

    if (!['first', 'second', 'economic'].includes(seatClass.toLowerCase())) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Invalid seat class. Must be first, second, or economic',
      });
    }

    // Get trip with pricing info
    const trip = await Trip.findByPk(tourId, {
      transaction: t,
      lock: t.LOCK.UPDATE,
    });

    if (!trip) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'Trip not found',
      });
    }

    // Find the specific departure or use the first available one
    let departure;
    if (tripDepartureId) {
      departure = await TripDeparture.findOne({
        where: { trip_departure_id: tripDepartureId, trip_id: tourId },
        transaction: t,
        lock: t.LOCK.UPDATE,
      });
    } else {
      // If no specific departure is provided, use the first available future departure
      departure = await TripDeparture.findOne({
        where: {
          trip_id: tourId,
          departure_time: { [Op.gt]: new Date() }
        },
        order: [['departure_time', 'ASC']],
        transaction: t,
        lock: t.LOCK.UPDATE,
      });
    }

    if (!departure) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'No available departure found for this trip',
      });
    }

    // Check seat availability
    if (departure.available_seats < numberOfSeats) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: `Only ${departure.available_seats} seats available for this departure`,
      });
    }

    // Get price per seat based on class
    let pricePerSeat;
    const seatClassLower = seatClass.toLowerCase();
    if (seatClassLower === 'first') {
      pricePerSeat = trip.first_class_price;
    } else if (seatClassLower === 'second') {
      pricePerSeat = trip.second_class_price;
    } else if (seatClassLower === 'economic') {
      pricePerSeat = trip.economic_price;
    }

    if (!pricePerSeat || pricePerSeat <= 0) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: `${seatClass} class is not available for this trip`,
      });
    }

    const totalPrice = pricePerSeat * numberOfSeats;

    // Generate booking reference
    const bookingReference = generateBookingReference();

    // Create Booking with pending payment
    const booking = await Booking.create(
      {
        user_id: req.user.id,
        trip_id: tourId,
        trip_departure_id: departure.trip_departure_id,
        seat_class: seatClass,
        seat_number: null, // Will assign after payment
        number_of_seats: numberOfSeats,
        total_price: totalPrice,
        booking_reference: bookingReference,
        status: 'pending',
      },
      { transaction: t }
    );

    // Reduce available seats for this specific departure
    await departure.update(
      { available_seats: departure.available_seats - numberOfSeats },
      { transaction: t }
    );

    await t.commit();

    // Fetch complete Booking
    const completeReservation = await Booking.findByPk(booking.id, {
      include: [
        {
          model: TripDeparture,
          as: 'tripDeparture',
          include: [
            {
              model: Trip,
              as: 'trip',
              include: [
                { model: Train, as: 'train' },
                { model: Station, as: 'departureStation' },
                { model: Station, as: 'arrivalStation' },
              ],
            },
          ],
        },
      ],
    });

    // Send confirmation email
    try {
      const user = await User.findByPk(req.user.id);
      await emailService.sendBookingConfirmation(user.email, user.full_name, {
        reference: completeReservation.booking_reference,
        trainNumber: completeReservation.tripDeparture.trip.train.train_number,
        from: completeReservation.tripDeparture.trip.departureStation.name,
        to: completeReservation.tripDeparture.trip.arrivalStation.name,
        departureTime: new Date(completeReservation.tripDeparture.departure_time).toLocaleString('en-US', { dateStyle: 'medium', timeStyle: 'short' }),
        arrivalTime: new Date(completeReservation.tripDeparture.arrival_time).toLocaleString('en-US', { dateStyle: 'medium', timeStyle: 'short' }),
        seatClass: completeReservation.seat_class,
        seats: completeReservation.number_of_seats,
        totalPrice: parseFloat(completeReservation.total_price),
      });
    } catch (emailError) {
      console.error('Failed to send booking confirmation email:', emailError);
    }

    res.status(201).json({
      success: true,
      message: 'Booking created. Please proceed to payment.',
      data: {
        reservation: {
          id: completeReservation.id,
          seatClass: completeReservation.seat_class,
          numberOfSeats: completeReservation.number_of_seats,
          totalPrice: parseFloat(completeReservation.total_price),
          bookingReference: completeReservation.booking_reference,
          status: completeReservation.status,
          tripDeparture: {
            id: completeReservation.tripDeparture.trip_departure_id,
            departureTime: completeReservation.tripDeparture.departure_time,
            arrivalTime: completeReservation.tripDeparture.arrival_time,
            trip: {
              id: completeReservation.tripDeparture.trip.id,
              train: {
                trainNumber: completeReservation.tripDeparture.trip.train.train_number,
              },
              departureStation: {
                name: completeReservation.tripDeparture.trip.departureStation.name,
                city: completeReservation.tripDeparture.trip.departureStation.city,
              },
              arrivalStation: {
                name: completeReservation.tripDeparture.trip.arrivalStation.name,
                city: completeReservation.tripDeparture.trip.arrivalStation.city,
              },
            },
          },
        },
      },
    });
  } catch (error) {
    await t.rollback();
    console.error('Create Booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create Booking',
    });
  }
};

// @desc    Process payment (credit card or cash)
// @route   POST /api/user/reservations/:id/payment
// @access  Private
exports.processPayment = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { id } = req.params;
    const { paymentMethod, cardNumber, cardHolder, expiryDate, cvv } = req.body;

    // Validation
    if (!paymentMethod || !['credit_card', 'cash'].includes(paymentMethod)) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Invalid payment method. Must be credit_card or cash',
      });
    }

    // Get booking
    const booking = await Booking.findOne({
      where: {
        id,
        user_id: req.user.id,
      },
      include: [{ model: Trip, as: 'trip' }],
      transaction: t,
      lock: t.LOCK.UPDATE,
    });

    if (!booking) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'Booking not found',
      });
    }

    if (booking.status === 'confirmed') {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Payment already completed for this booking',
      });
    }

    // Validate credit card if payment method is credit_card
    if (paymentMethod === 'credit_card') {
      if (!cardNumber || !cardHolder || !expiryDate || !cvv) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: 'Please provide all credit card details',
        });
      }

      // Fake validation (in production, integrate with payment gateway)
      if (cardNumber.length < 13 || cardNumber.length > 19) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: 'Invalid card number',
        });
      }

      if (cvv.length < 3 || cvv.length > 4) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: 'Invalid CVV',
        });
      }

      // Simulate payment processing
      console.log('Processing credit card payment:', {
        amount: booking.total_price,
        cardNumber: cardNumber.slice(-4),
        cardHolder: cardHolder,
      });
    } else {
      // Cash payment - will be paid at station
      console.log('Cash payment registered for booking:', booking.booking_reference);
    }

    // Generate seat number (simple implementation)
    let seatPrefix = 'E'; // Economic
    if (booking.seat_class.toLowerCase() === 'first') {
      seatPrefix = 'F';
    } else if (booking.seat_class.toLowerCase() === 'second') {
      seatPrefix = 'S';
    }
    const seatNumber = `${seatPrefix}${Math.floor(Math.random() * 100) + 1}`;

    // Update booking
    await booking.update(
      {
        status: 'confirmed',
        seat_number: seatNumber,
        updated_at: new Date(),
      },
      { transaction: t }
    );

    await t.commit();

    // Fetch updated Booking
    const updatedReservation = await Booking.findByPk(id, {
      include: [
        {
          model: Trip,
          as: 'trip',
          include: [
            { model: Train, as: 'train' },
            { model: Station, as: 'departureStation' },
            { model: Station, as: 'arrivalStation' },
          ],
        },
      ],
    });

    res.json({
      success: true,
      message: paymentMethod === 'credit_card' 
        ? 'Payment processed successfully' 
        : 'Booking confirmed. Please pay at the station before departure.',
      data: {
        booking: {
          id: updatedReservation.id,
          seatClass: updatedReservation.seat_class,
          seatNumber: updatedReservation.seat_number,
          numberOfSeats: updatedReservation.number_of_seats,
          totalPrice: parseFloat(updatedReservation.total_price),
          bookingReference: updatedReservation.booking_reference,
          status: updatedReservation.status,
          paymentMethod: paymentMethod,
          trip: {
            id: updatedReservation.trip.id,
            departureTime: updatedReservation.trip.departure_time,
            arrivalTime: updatedReservation.trip.arrival_time,
            train: {
              trainNumber: updatedReservation.trip.train.train_number,
              
            },
            departureStation: {
              name: updatedReservation.trip.departureStation.name,
              city: updatedReservation.trip.departureStation.city,
            },
            arrivalStation: {
              name: updatedReservation.trip.arrivalStation.name,
              city: updatedReservation.trip.arrivalStation.city,
            },
          },
        },
      },
    });
  } catch (error) {
    await t.rollback();
    console.error('Process payment error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to process payment',
    });
  }
};

// @desc    Cancel Booking
// @route   DELETE /api/user/reservations/:id
// @access  Private
exports.cancelReservation = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { id } = req.params;

    const Booking = await Booking.findOne({
      where: {
        id,
        user_id: req.user.id,
      },
      include: [{ model: Trip, as: 'trip' }],
      transaction: t,
      lock: t.LOCK.UPDATE,
    });

    if (!Booking) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'Booking not found',
      });
    }

    if (Booking.status === 'cancelled') {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Booking already cancelled',
      });
    }

    // Update Booking status
    await Booking.update(
      {
        status: 'cancelled',
        updated_at: new Date(),
      },
      { transaction: t }
    );

    // Restore seat availability
    const trip = Booking.trip;
    const seatsToRestore = Booking.number_of_seats || 1;
    if (Booking.seat_class === 'first') {
      await trip.update(
        { available_first_class_seats: trip.available_first_class_seats + seatsToRestore },
        { transaction: t }
      );
    } else {
      await trip.update(
        { available_second_class_seats: trip.available_second_class_seats + seatsToRestore },
        { transaction: t }
      );
    }

    await t.commit();

    // Calculate refund (100% refund if cancelled)
    const refundAmount = parseFloat(Booking.total_price);

    res.json({
      success: true,
      message: `Booking cancelled successfully. Refund of $${refundAmount.toFixed(2)} will be processed within 5-7 business days.`,
      data: {
        refundAmount: refundAmount,
        bookingReference: Booking.booking_reference,
      },
    });
  } catch (error) {
    await t.rollback();
    console.error('Cancel Booking error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel Booking',
    });
  }
};
