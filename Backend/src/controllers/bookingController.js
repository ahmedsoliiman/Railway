const { Reservation, Trip, Train, Station, User, sequelize } = require('../models');
const crypto = require('crypto');

// Generate booking reference
const generateBookingReference = () => {
  return 'BK' + Date.now() + crypto.randomBytes(2).toString('hex').toUpperCase();
};

// @desc    Get user's reservations
// @route   GET /api/user/reservations
// @access  Private
exports.getUserReservations = async (req, res) => {
  try {
    const reservations = await Reservation.findAll({
      where: { user_id: req.user.userId },
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
      order: [['created_at', 'DESC']],
    });

    res.json({
      success: true,
      data: reservations.map(r => ({
        id: r.id,
        passengerName: r.passenger_name,
        passengerNationalId: r.passenger_national_id,
        seatClass: r.seat_class,
        seatNumber: r.seat_number,
        price: parseFloat(r.price),
        bookingReference: r.booking_reference,
        paymentStatus: r.payment_status,
        status: r.status,
        trip: {
          id: r.trip.id,
          departureTime: r.trip.departure_time,
          arrivalTime: r.trip.arrival_time,
          train: {
            trainNumber: r.trip.train.train_number,
            name: r.trip.train.name,
          },
          departureStation: {
            name: r.trip.departureStation.name,
            city: r.trip.departureStation.city,
          },
          arrivalStation: {
            name: r.trip.arrivalStation.name,
            city: r.trip.arrivalStation.city,
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

// @desc    Create reservation (initial booking - pending payment)
// @route   POST /api/user/reservations
// @access  Private
exports.createReservation = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { tourId, passengerName, passengerNationalId, seatClass } = req.body;

    // Validation
    if (!tourId || !passengerName || !passengerNationalId || !seatClass) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Please provide all required fields',
      });
    }

    if (!['first', 'second'].includes(seatClass)) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Invalid seat class. Must be first or second',
      });
    }

    // Get trip with train info
    const trip = await Trip.findByPk(tourId, {
      include: [{ model: Train, as: 'train' }],
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

    // Check availability
    const availableSeats =
      seatClass === 'first'
        ? trip.available_first_class_seats
        : trip.available_second_class_seats;

    if (availableSeats <= 0) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: `No available ${seatClass} class seats for this trip`,
      });
    }

    // Get price
    const price = seatClass === 'first' ? trip.first_class_price : trip.second_class_price;

    // Generate booking reference
    const bookingReference = generateBookingReference();

    // Create reservation with pending payment
    const reservation = await Reservation.create(
      {
        user_id: req.user.userId,
        trip_id: tourId,
        passenger_name: passengerName,
        passenger_national_id: passengerNationalId,
        seat_class: seatClass,
        seat_number: null, // Will assign after payment
        price,
        booking_reference: bookingReference,
        payment_status: 'pending',
        status: 'confirmed',
      },
      { transaction: t }
    );

    // Temporarily reduce available seats
    if (seatClass === 'first') {
      await trip.update(
        { available_first_class_seats: trip.available_first_class_seats - 1 },
        { transaction: t }
      );
    } else {
      await trip.update(
        { available_second_class_seats: trip.available_second_class_seats - 1 },
        { transaction: t }
      );
    }

    await t.commit();

    // Fetch complete reservation
    const completeReservation = await Reservation.findByPk(reservation.id, {
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

    res.status(201).json({
      success: true,
      message: 'Reservation created. Please proceed to payment.',
      data: {
        reservation: {
          id: completeReservation.id,
          passengerName: completeReservation.passenger_name,
          passengerNationalId: completeReservation.passenger_national_id,
          seatClass: completeReservation.seat_class,
          price: parseFloat(completeReservation.price),
          bookingReference: completeReservation.booking_reference,
          paymentStatus: completeReservation.payment_status,
          trip: {
            id: completeReservation.trip.id,
            departureTime: completeReservation.trip.departure_time,
            arrivalTime: completeReservation.trip.arrival_time,
            train: {
              trainNumber: completeReservation.trip.train.train_number,
              name: completeReservation.trip.train.name,
            },
            departureStation: {
              name: completeReservation.trip.departureStation.name,
              city: completeReservation.trip.departureStation.city,
            },
            arrivalStation: {
              name: completeReservation.trip.arrivalStation.name,
              city: completeReservation.trip.arrivalStation.city,
            },
          },
        },
      },
    });
  } catch (error) {
    await t.rollback();
    console.error('Create reservation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create reservation',
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

    // Get reservation
    const reservation = await Reservation.findOne({
      where: {
        id,
        user_id: req.user.userId,
      },
      include: [{ model: Trip, as: 'trip' }],
      transaction: t,
      lock: t.LOCK.UPDATE,
    });

    if (!reservation) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'Reservation not found',
      });
    }

    if (reservation.payment_status === 'completed') {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Payment already completed for this reservation',
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
        amount: reservation.price,
        cardNumber: cardNumber.slice(-4),
        cardHolder: cardHolder,
      });
    } else {
      // Cash payment - will be paid at station
      console.log('Cash payment registered for reservation:', reservation.booking_reference);
    }

    // Generate seat number (simple implementation)
    const seatNumber = `${reservation.seat_class === 'first' ? 'F' : 'S'}${Math.floor(Math.random() * 100) + 1}`;

    // Update reservation
    await reservation.update(
      {
        payment_status: 'completed',
        seat_number: seatNumber,
        updated_at: new Date(),
      },
      { transaction: t }
    );

    await t.commit();

    // Fetch updated reservation
    const updatedReservation = await Reservation.findByPk(id, {
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
        reservation: {
          id: updatedReservation.id,
          passengerName: updatedReservation.passenger_name,
          passengerNationalId: updatedReservation.passenger_national_id,
          seatClass: updatedReservation.seat_class,
          seatNumber: updatedReservation.seat_number,
          price: parseFloat(updatedReservation.price),
          bookingReference: updatedReservation.booking_reference,
          paymentStatus: updatedReservation.payment_status,
          paymentMethod: paymentMethod,
          trip: {
            id: updatedReservation.trip.id,
            departureTime: updatedReservation.trip.departure_time,
            arrivalTime: updatedReservation.trip.arrival_time,
            train: {
              trainNumber: updatedReservation.trip.train.train_number,
              name: updatedReservation.trip.train.name,
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

// @desc    Cancel reservation
// @route   DELETE /api/user/reservations/:id
// @access  Private
exports.cancelReservation = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { id } = req.params;

    const reservation = await Reservation.findOne({
      where: {
        id,
        user_id: req.user.userId,
      },
      include: [{ model: Trip, as: 'trip' }],
      transaction: t,
      lock: t.LOCK.UPDATE,
    });

    if (!reservation) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'Reservation not found',
      });
    }

    if (reservation.status === 'cancelled') {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Reservation already cancelled',
      });
    }

    // Update reservation status
    await reservation.update(
      {
        status: 'cancelled',
        payment_status: reservation.payment_status === 'completed' ? 'refunded' : 'pending',
        updated_at: new Date(),
      },
      { transaction: t }
    );

    // Restore seat availability
    const trip = reservation.trip;
    if (reservation.seat_class === 'first') {
      await trip.update(
        { available_first_class_seats: trip.available_first_class_seats + 1 },
        { transaction: t }
      );
    } else {
      await trip.update(
        { available_second_class_seats: trip.available_second_class_seats + 1 },
        { transaction: t }
      );
    }

    await t.commit();

    res.json({
      success: true,
      message: reservation.payment_status === 'completed' 
        ? 'Reservation cancelled. Refund will be processed.' 
        : 'Reservation cancelled successfully',
    });
  } catch (error) {
    await t.rollback();
    console.error('Cancel reservation error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to cancel reservation',
    });
  }
};
