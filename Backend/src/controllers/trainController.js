const { Train, Carriage, TrainCarriage, sequelize } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all trains with carriages
// @route   GET /api/admin/trains
// @access  Private/Admin
exports.getAllTrains = async (req, res) => {
  try {
    const trains = await Train.findAll({
      include: [
        {
          model: TrainCarriage,
          as: 'trainCarriages',
          include: [
            {
              model: Carriage,
              as: 'carriage',
            },
          ],
        },
      ],
      order: [['train_number', 'ASC']],
    });

    res.json({
      success: true,
      data: trains.map(train => ({
        id: train.id,
        trainNumber: train.train_number,
        name: train.name,
        type: train.type,
        totalSeats: train.total_seats,
        firstClassSeats: train.first_class_seats,
        secondClassSeats: train.second_class_seats,
        facilities: train.facilities,
        status: train.status,
        carriages: train.trainCarriages.map(tc => ({
          carriageId: tc.carriage_id,
          quantity: tc.quantity,
          name: tc.carriage.name,
          classType: tc.carriage.class_type,
          seatsCount: tc.carriage.seats_count,
          model: tc.carriage.model,
        })),
        createdAt: train.created_at,
        updatedAt: train.updated_at,
      })),
    });
  } catch (error) {
    console.error('Get trains error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch trains',
    });
  }
};

// @desc    Create train with carriages
// @route   POST /api/admin/trains
// @access  Private/Admin
exports.createTrain = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { trainNumber, name, type, carriages, facilities, status } = req.body;

    // Validation
    if (!trainNumber || !name || !carriages || carriages.length === 0) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Please provide trainNumber, name, and at least one carriage',
      });
    }

    // Check if train number already exists
    const existing = await Train.findOne({ where: { train_number: trainNumber } });
    if (existing) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'Train number already exists',
      });
    }

    // Validate all carriages exist
    const carriageIds = carriages.map(c => c.carriageId);
    const foundCarriages = await Carriage.findAll({
      where: { id: carriageIds },
    });

    if (foundCarriages.length !== carriageIds.length) {
      await t.rollback();
      return res.status(400).json({
        success: false,
        message: 'One or more invalid carriage IDs',
      });
    }

    // Calculate seats
    let totalSeats = 0;
    let firstClassSeats = 0;
    let secondClassSeats = 0;

    for (const carriageInput of carriages) {
      const carriage = foundCarriages.find(c => c.id === carriageInput.carriageId);
      const quantity = carriageInput.quantity || 1;
      const seats = carriage.seats_count * quantity;

      totalSeats += seats;
      if (carriage.class_type === 'first') {
        firstClassSeats += seats;
      } else if (carriage.class_type === 'second') {
        secondClassSeats += seats;
      }
    }

    // Create train
    const train = await Train.create(
      {
        train_number: trainNumber,
        name,
        type: type || 'standard',
        total_seats: totalSeats,
        first_class_seats: firstClassSeats,
        second_class_seats: secondClassSeats,
        facilities: facilities || null,
        status: status || 'active',
      },
      { transaction: t }
    );

    // Create train-carriage associations
    for (const carriageInput of carriages) {
      await TrainCarriage.create(
        {
          train_id: train.id,
          carriage_id: carriageInput.carriageId,
          quantity: carriageInput.quantity || 1,
        },
        { transaction: t }
      );
    }

    await t.commit();

    // Fetch complete train with carriages
    const completeTrain = await Train.findByPk(train.id, {
      include: [
        {
          model: TrainCarriage,
          as: 'trainCarriages',
          include: [{ model: Carriage, as: 'carriage' }],
        },
      ],
    });

    res.status(201).json({
      success: true,
      message: 'Train created successfully',
      data: {
        train: {
          id: completeTrain.id,
          trainNumber: completeTrain.train_number,
          name: completeTrain.name,
          type: completeTrain.type,
          totalSeats: completeTrain.total_seats,
          firstClassSeats: completeTrain.first_class_seats,
          secondClassSeats: completeTrain.second_class_seats,
          facilities: completeTrain.facilities,
          status: completeTrain.status,
          carriages: completeTrain.trainCarriages.map(tc => ({
            carriageId: tc.carriage_id,
            quantity: tc.quantity,
            name: tc.carriage.name,
            classType: tc.carriage.class_type,
            seatsCount: tc.carriage.seats_count,
            model: tc.carriage.model,
          })),
        },
      },
    });
  } catch (error) {
    await t.rollback();
    console.error('Create train error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create train',
    });
  }
};

// @desc    Update train
// @route   PUT /api/admin/trains/:id
// @access  Private/Admin
exports.updateTrain = async (req, res) => {
  const t = await sequelize.transaction();

  try {
    const { id } = req.params;
    const { train_number, name, type, carriages, facilities, status } = req.body;

    const train = await Train.findByPk(id);
    if (!train) {
      await t.rollback();
      return res.status(404).json({
        success: false,
        message: 'Train not found',
      });
    }

    // Check train number conflicts
    if (train_number && train_number !== train.train_number) {
      const existing = await Train.findOne({
        where: {
          train_number,
          id: { [Op.ne]: id },
        },
      });
      if (existing) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: 'Train number already exists',
        });
      }
    }

    // Update basic fields
    await train.update(
      {
        train_number: train_number || train.train_number,
        name: name || train.name,
        type: type || train.type,
        facilities: facilities !== undefined ? facilities : train.facilities,
        status: status !== undefined ? status : train.status,
      },
      { transaction: t }
    );

    // Update carriages if provided
    if (carriages && carriages.length > 0) {
      // Validate carriages
      const carriageIds = carriages.map(c => c.carriage_id);
      const foundCarriages = await Carriage.findAll({
        where: { id: carriageIds },
      });

      if (foundCarriages.length !== carriageIds.length) {
        await t.rollback();
        return res.status(400).json({
          success: false,
          message: 'One or more invalid carriage IDs',
        });
      }

      // Calculate new seats
      let totalSeats = 0;
      let firstClassSeats = 0;
      let secondClassSeats = 0;

      for (const carriageInput of carriages) {
        const carriage = foundCarriages.find(c => c.id === carriageInput.carriage_id);
        const quantity = carriageInput.quantity || 1;
        const seats = carriage.seats_count * quantity;

        totalSeats += seats;
        if (carriage.class_type === 'first') {
          firstClassSeats += seats;
        } else if (carriage.class_type === 'second') {
          secondClassSeats += seats;
        }
      }

      // Update seat counts
      await train.update(
        {
          total_seats: totalSeats,
          first_class_seats: firstClassSeats,
          second_class_seats: secondClassSeats,
        },
        { transaction: t }
      );

      // Delete old carriage associations
      await TrainCarriage.destroy({
        where: { train_id: id },
        transaction: t,
      });

      // Create new associations
      for (const carriageInput of carriages) {
        await TrainCarriage.create(
          {
            train_id: id,
            carriage_id: carriageInput.carriage_id,
            quantity: carriageInput.quantity || 1,
          },
          { transaction: t }
        );
      }
    }

    await t.commit();

    // Fetch updated train
    const updatedTrain = await Train.findByPk(id, {
      include: [
        {
          model: TrainCarriage,
          as: 'trainCarriages',
          include: [{ model: Carriage, as: 'carriage' }],
        },
      ],
    });

    res.json({
      success: true,
      message: 'Train updated successfully',
      data: {
        train: {
          id: updatedTrain.id,
          trainNumber: updatedTrain.train_number,
          name: updatedTrain.name,
          type: updatedTrain.type,
          totalSeats: updatedTrain.total_seats,
          firstClassSeats: updatedTrain.first_class_seats,
          secondClassSeats: updatedTrain.second_class_seats,
          facilities: updatedTrain.facilities,
          status: updatedTrain.status,
          carriages: updatedTrain.trainCarriages.map(tc => ({
            carriageId: tc.carriage_id,
            quantity: tc.quantity,
            name: tc.carriage.name,
            classType: tc.carriage.class_type,
            seatsCount: tc.carriage.seats_count,
            model: tc.carriage.model,
          })),
        },
      },
    });
  } catch (error) {
    await t.rollback();
    console.error('Update train error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update train',
    });
  }
};

// @desc    Delete train
// @route   DELETE /api/admin/trains/:id
// @access  Private/Admin
exports.deleteTrain = async (req, res) => {
  try {
    const { id } = req.params;

    const train = await Train.findByPk(id);
    if (!train) {
      return res.status(404).json({
        success: false,
        message: 'Train not found',
      });
    }

    await train.destroy();

    res.json({
      success: true,
      message: 'Train deleted successfully',
    });
  } catch (error) {
    console.error('Delete train error:', error);
    if (error.name === 'SequelizeForeignKeyConstraintError') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete train that is used in trips',
      });
    }
    res.status(500).json({
      success: false,
      message: 'Failed to delete train',
    });
  }
};
