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
        model: carriage.model,
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
    const carriageNumber = req.body.carriageNumber || req.body.carriage_number;
    const carriageTypeId = req.body.carriageTypeId || req.body.carriage_type_id;
    const model = req.body.model;

    // Validation
    if (!carriageNumber || !carriageTypeId) {
      console.log('Validation failed:', { carriageNumber, carriageTypeId });
      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: [
          !carriageNumber && { field: 'carriageNumber', message: 'Carriage number is required' },
          !carriageTypeId && { field: 'carriageTypeId', message: 'Carriage type ID is required' },
        ].filter(Boolean),
      });
    }

    // Verify carriage type exists
    const carriageType = await CarriageType.findByPk(carriageTypeId);
    if (!carriageType) {
      return res.status(400).json({
        success: false,
        message: 'Invalid carriage type ID',
      });
    }

    // Check if carriage number already exists
    const existing = await Carriage.findOne({
      where: { carriage_number: carriageNumber },
    });
    
    if (existing) {
      return res.status(400).json({
        success: false,
        message: 'Carriage number already exists',
      });
    }

    const carriage = await Carriage.create({
      carriage_number: carriageNumber,
      carriage_type_id: carriageTypeId,
      model: model || null,
    });

    // Reload with carriage type
    await carriage.reload({
      include: [{
        model: CarriageType,
        as: 'carriageType',
      }],
    });

    res.status(201).json({
      success: true,
      message: 'Carriage created successfully',
      data: {
        id: carriage.id,
        carriageNumber: carriage.carriage_number,
        carriageTypeId: carriage.carriage_type_id,
        model: carriage.model,
        carriageType: carriage.carriageType ? {
          id: carriage.carriageType.carriage_type_id,
          type: carriage.carriageType.type,
          capacity: carriage.carriageType.capacity,
          price: parseFloat(carriage.carriageType.price),
        } : null,
        createdAt: carriage.created_at,
        updatedAt: carriage.updated_at,
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
    const carriageNumber = req.body.carriageNumber || req.body.carriage_number;
    const carriageTypeId = req.body.carriageTypeId || req.body.carriage_type_id;
    const model = req.body.model;

    const carriage = await Carriage.findByPk(id);
    if (!carriage) {
      return res.status(404).json({
        success: false,
        message: 'Carriage not found',
      });
    }

    // Verify carriage type exists if provided
    if (carriageTypeId) {
      const carriageType = await CarriageType.findByPk(carriageTypeId);
      if (!carriageType) {
        return res.status(400).json({
          success: false,
          message: 'Invalid carriage type ID',
        });
      }
    }

    // Check if carriage number already exists (if changing)
    if (carriageNumber && carriageNumber !== carriage.carriage_number) {
      const existing = await Carriage.findOne({
        where: { carriage_number: carriageNumber },
      });
      
      if (existing) {
        return res.status(400).json({
          success: false,
          message: 'Carriage number already exists',
        });
      }
    }

    await carriage.update({
      carriage_number: carriageNumber || carriage.carriage_number,
      carriage_type_id: carriageTypeId || carriage.carriage_type_id,
      model: model !== undefined ? model : carriage.model,
    });

    // Reload with carriage type
    await carriage.reload({
      include: [{
        model: CarriageType,
        as: 'carriageType',
      }],
    });

    res.json({
      success: true,
      message: 'Carriage updated successfully',
      data: {
        id: carriage.id,
        carriageNumber: carriage.carriage_number,
        carriageTypeId: carriage.carriage_type_id,
        model: carriage.model,
        carriageType: carriage.carriageType ? {
          id: carriage.carriageType.carriage_type_id,
          type: carriage.carriageType.type,
          capacity: carriage.carriageType.capacity,
          price: parseFloat(carriage.carriageType.price),
        } : null,
        createdAt: carriage.created_at,
        updatedAt: carriage.updated_at,
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
