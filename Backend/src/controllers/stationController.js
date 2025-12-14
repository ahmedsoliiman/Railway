const { Station } = require('../models');
const { Op } = require('sequelize');

// @desc    Get all stations
// @route   GET /api/admin/stations
// @access  Private/Admin
exports.getAllStations = async (req, res) => {
  try {
    const stations = await Station.findAll({
      order: [['name', 'ASC']],
    });

    res.json({
      success: true,
      data: stations.map(station => ({
        id: station.id,
        name: station.name,
        code: station.code,
        city: station.city,
        address: station.address,

        createdAt: station.created_at,
        updatedAt: station.updated_at,
      })),
    });
  } catch (error) {
    console.error('Get stations error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch stations',
    });
  }
};

// @desc    Create station
// @route   POST /api/admin/stations
// @access  Private/Admin
exports.createStation = async (req, res) => {
  try {
    const { name, code, city, address } = req.body;

    // Validation
    if (!name || !code || !city) {
      return res.status(400).json({
        success: false,
        message: 'Please provide name, code, and city',
      });
    }

    // Check if code or name already exists
    const existing = await Station.findOne({
      where: {
        [Op.or]: [{ code }, { name }],
      },
    });

    if (existing) {
      return res.status(400).json({
        success: false,
        message: existing.code === code ? 'Station code already exists' : 'Station name already exists',
      });
    }

    const station = await Station.create({
      name,
      code,
      city,
      address: address || null,

    });

    res.status(201).json({
      success: true,
      message: 'Station created successfully',
      data: {
        station: {
          id: station.id,
          name: station.name,
          code: station.code,
          city: station.city,
          address: station.address,

        },
      },
    });
  } catch (error) {
    console.error('Create station error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to create station',
    });
  }
};

// @desc    Update station
// @route   PUT /api/admin/stations/:id
// @access  Private/Admin
exports.updateStation = async (req, res) => {
  try {
    const { id } = req.params;
    const { name, code, city, address } = req.body;

    const station = await Station.findByPk(id);
    if (!station) {
      return res.status(404).json({
        success: false,
        message: 'Station not found',
      });
    }

    // Check for conflicts if name or code is being changed
    if (name || code) {
      const conflicts = await Station.findOne({
        where: {
          id: { [Op.ne]: id },
          [Op.or]: [
            name ? { name } : null,
            code ? { code } : null,
          ].filter(Boolean),
        },
      });

      if (conflicts) {
        return res.status(400).json({
          success: false,
          message: conflicts.name === name ? 'Station name already exists' : 'Station code already exists',
        });
      }
    }

    await station.update({
      name: name || station.name,
      code: code || station.code,
      city: city || station.city,
      address: address !== undefined ? address : station.address,
      updated_at: new Date(),
    });

    res.json({
      success: true,
      message: 'Station updated successfully',
      data: {
        station: {
          id: station.id,
          name: station.name,
          code: station.code,
          city: station.city,
          address: station.address,

        },
      },
    });
  } catch (error) {
    console.error('Update station error:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to update station',
    });
  }
};

// @desc    Delete station
// @route   DELETE /api/admin/stations/:id
// @access  Private/Admin
exports.deleteStation = async (req, res) => {
  try {
    const { id } = req.params;

    const station = await Station.findByPk(id);
    if (!station) {
      return res.status(404).json({
        success: false,
        message: 'Station not found',
      });
    }

    await station.destroy();

    res.json({
      success: true,
      message: 'Station deleted successfully',
    });
  } catch (error) {
    console.error('Delete station error:', error);
    if (error.name === 'SequelizeForeignKeyConstraintError') {
      return res.status(400).json({
        success: false,
        message: 'Cannot delete station that is used in trips',
      });
    }
    res.status(500).json({
      success: false,
      message: 'Failed to delete station',
    });
  }
};
