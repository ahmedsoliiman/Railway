const { Carriage, CarriageType } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all carriage types
// @route   GET /api/admin/carriage-types
// @access  Private/Admin
exports.getAllCarriageTypes = async (req, res) => {
  try {
    const types = await CarriageType.findAll({
      order: [['carriage_type_id', 'ASC']],
    });

    res.json({
      success: true,
      data: types.map(type => ({
        id: type.carriage_type_id,
        type: type.type,
        capacity: type.capacity,
        price: parseFloat(type.price),
      })),
    });
  } catch (error) {
    console.error('Get carriage types error:', error);
    res.status(500).json({
      success: false,
      message: 'Error fetching carriage types',
    });
  }
};

// @desc    Get all carriages
// @route   GET /api/admin/carriages
// @access  Private/Admin
exports.getAllCarriages = async (req, res) => {
  try {
    const carriages = await Carriage.findAll({
      include: [{
        model: CarriageType,
        as: 'carriageType',
        required: false,
      }],
      order: [
        ['carriage_number', 'ASC'],
      ],
    });

    res.json({
      success: true,
      data: carriages.map(carriage => ({
        id: carriage.id,
        carriageNumber: carriage.carriage_number,
        carriageTypeId: carriage.carriage_type_id,
        carriageType: carriage.carriageType ? {
          id: carriage.carriageType.carriage_type_id,
          type: carriage.carriageType.type,
          capacity: carriage.carriageType.capacity,
          price: parseFloat(carriage.carriageType.price),
        } : null,
        createdAt: carriage.created_at,
        updatedAt: carriage.updated_at,
      })),
    });
  } catch (error) {
    console.error('Get carriages error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch carriages',
    });
  }
};

// @desc    Create carriage
// @route   POST /api/admin/carriages
// @access  Private/Admin
exports.createCarriage = async (req, res) => {
  try {
    console.log('Create carriage request body:', req.body);
    // Accept both camelCase (frontend) and snake_case (API)
    const name = req.body.name;
    const class_type = req.body.class_type || req.body.classType;
    const seats_count = req.body.seats_count || req.body.seatsCount;
    
    

    // Validation
    if (!name || !class_type || !seats_count) {
      console.log('Validation failed:', { name, class_type, seats_count });
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: [
          !name && { field: 'name', message: 'Name is required' },
          !class_type && { field: 'classType', message: 'Class type is required' },
          !seats_count && { field: 'seatsCount', message: 'Seats count is required' },
        ].filter(Boolean),
      });
    }

    if (!['first', 'second', 'economic'].includes(class_type)) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: [
          { field: 'classType', message: 'Class type must be first, second, or economic' },
        ],
      });
    }

    if (seats_count < 1) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: [
          { field: 'seatsCount', message: 'Seats count must be at least 1' },
        ],
      });
    }

    const carriage = await Carriage.create({
      name,
      class_type,
      seats_count,
      model: model || null,
      description: description || null,
    });

    res.status(201).json({
      success: true,
      message: 'Carriage created successfully',
      data: {
        carriage: {
          id: carriage.id,
          name: carriage.name,
          classType: carriage.class_type,
          seatsCount: carriage.seats_count,


        },
      },
    });
  } catch (error) {
    console.error('Create carriage error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create carriage',
    });
  }
};

// @desc    Update carriage
// @route   PUT /api/admin/carriages/:id
// @access  Private/Admin
exports.updateCarriage = async (req, res) => {
  try {
    const { id } = req.params;
    // Accept both camelCase (frontend) and snake_case (API)
    const name = req.body.name;
    const class_type = req.body.class_type || req.body.classType;
    const seats_count = req.body.seats_count || req.body.seatsCount;
    
    

    const carriage = await Carriage.findByPk(id);
    if (!carriage) {
      return res.status(404).json({
        success: false,
        message: 'Carriage not found',
      });
    }

    // Validate class_type if provided
    if (class_type && !['first', 'second', 'economic'].includes(class_type)) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: [
          { field: 'classType', message: 'Class type must be first, second, or economic' },
        ],
      });
    }

    // Validate seats_count if provided
    if (seats_count !== undefined && seats_count < 1) {
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: [
          { field: 'seatsCount', message: 'Seats count must be at least 1' },
        ],
      });
    }

    await carriage.update({
      name: name || carriage.name,
      class_type: class_type || carriage.class_type,
      seats_count: seats_count !== undefined ? seats_count : carriage.seats_count,
      
      
      updated_at: new Date(),
    });

    res.json({
      success: true,
      message: 'Carriage updated successfully',
      data: {
        carriage: {
          id: carriage.id,
          name: carriage.name,
          classType: carriage.class_type,
          seatsCount: carriage.seats_count,


        },
      },
    });
  } catch (error) {
    console.error('Update carriage error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update carriage',
    });
  }
};

// @desc    Delete carriage
// @route   DELETE /api/admin/carriages/:id
// @access  Private/Admin
exports.deleteCarriage = async (req, res) => {
  try {
    const { id } = req.params;

    const carriage = await Carriage.findByPk(id);
    if (!carriage) {
      return res.status(404).json({
        success: false,
        message: 'Carriage not found',
      });
    }

    await carriage.destroy();

    res.json({
      success: true,
      message: 'Carriage deleted successfully',
    });
  } catch (error) {
    console.error('Delete carriage error:', error);
    if (error.name === 'SequelizeForeignKeyConstraintError') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete carriage that is used in trains',
      });
    }
    res.status(500).json({
      success: false,
      message: 'Failed to delete carriage',
    });
  }
};
