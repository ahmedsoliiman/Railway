// API Configuration
const API_URL = 'http://localhost:3001/api';
let authToken = localStorage.getItem('adminToken');

// Check authentication on page load
document.addEventListener('DOMContentLoaded', () => {
    if (!authToken) {
        showLoginModal();
    } else {
        initializeAdmin();
    }
});

// Show login modal
function showLoginModal() {
    document.getElementById('login-modal').classList.add('show');
}

// Login form
document.getElementById('login-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();
    const email = document.getElementById('login-email').value;
    const password = document.getElementById('login-password').value;

    try {
        const response = await fetch(`${API_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password }),
        });

        const data = await response.json();

        if (data.success) {
            if (data.data.user.role !== 'admin') {
                alert('Access denied. Admin privileges required.');
                return;
            }
            authToken = data.data.token;
            localStorage.setItem('adminToken', authToken);
            document.getElementById('login-modal').classList.remove('show');
            initializeAdmin();
        } else {
            alert(data.message || 'Login failed');
        }
    } catch (error) {
        console.error('Login error:', error);
        alert('Login failed. Please try again.');
    }
});

// Initialize admin dashboard
async function initializeAdmin() {
    const userInfoLoaded = await loadUserInfo();
    if (!userInfoLoaded) {
        // Invalid token, clear and show login
        localStorage.removeItem('adminToken');
        authToken = null;
        showLoginModal();
        return;
    }
    loadDashboardStats();
    setupNavigation();
    loadStations();
    loadTrains();
    loadTrips();
    loadCarriages();
}

// Load user info
async function loadUserInfo() {
    try {
        const response = await fetch(`${API_URL}/auth/me`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            document.getElementById('user-name').textContent = data.data.user.full_name;
            document.getElementById('user-email').textContent = data.data.user.email;
            return true;
        } else {
            return false;
        }
    } catch (error) {
        console.error('Load user info error:', error);
        return false;
    }
}

// Logout
function logout() {
    localStorage.removeItem('adminToken');
    authToken = null;
    location.reload();
}

// Navigation
function setupNavigation() {
    document.querySelectorAll('.nav-item').forEach((item) => {
        item.addEventListener('click', (e) => {
            e.preventDefault();
            const section = item.dataset.section;
            showSection(section);
        });
    });
}

function showSection(section) {
    // Update nav items
    document.querySelectorAll('.nav-item').forEach((item) => {
        item.classList.remove('active');
    });
    document.querySelector(`[data-section="${section}"]`).classList.add('active');

    // Update content sections
    document.querySelectorAll('.content-section').forEach((sec) => {
        sec.classList.remove('active');
    });
    document.getElementById(`${section}-section`).classList.add('active');

    // Update title
    const titles = {
        dashboard: 'Dashboard',
        stations: 'Manage Stations',
        trains: 'Manage Trains',
        trips: 'Manage Trips',
        reservations: 'All Reservations',
    };
    document.getElementById('section-title').textContent = titles[section];

    // Load section data
    switch (section) {
        case 'dashboard':
            loadDashboardStats();
            break;
        case 'stations':
            loadStations();
            break;
        case 'trains':
            loadTrains();
            break;
        case 'trips':
            loadTrips();
            break;
        case 'reservations':
            loadReservations();
            break;
    }
}

// Load dashboard stats
async function loadDashboardStats() {
    try {
        const response = await fetch(`${API_URL}/admin/dashboard-stats`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const stats = data.data.stats;
            document.getElementById('stat-users').textContent = stats.total_users;
            document.getElementById('stat-stations').textContent = stats.total_stations;
            document.getElementById('stat-trains').textContent = stats.total_trains;
            document.getElementById('stat-tours').textContent = stats.active_trips;
            document.getElementById('stat-reservations').textContent = stats.total_reservations;
            document.getElementById('stat-revenue').textContent = `$${parseFloat(stats.total_revenue).toFixed(2)}`;
        }
    } catch (error) {
        console.error('Load stats error:', error);
    }
}

// ============ STATIONS ============

async function loadStations() {
    try {
        const response = await fetch(`${API_URL}/admin/stations`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const tbody = document.querySelector('#stations-table tbody');
            tbody.innerHTML = '';

            data.data.stations.forEach((station) => {
                const row = `
                    <tr>
                        <td>${station.id}</td>
                        <td>${station.name}</td>
                        <td>${station.city}</td>
                        <td>${station.address || 'N/A'}</td>
                        <td>${station.facilities || 'N/A'}</td>
                        <td>
                            <button class="btn-edit" onclick="editStation(${station.id})">Edit</button>
                            <button class="btn-delete" onclick="deleteStation(${station.id})">Delete</button>
                        </td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        }
    } catch (error) {
        console.error('Load stations error:', error);
    }
}

function showAddStationModal() {
    document.getElementById('station-modal-title').textContent = 'Add Station';
    document.getElementById('station-form').reset();
    document.getElementById('station-id').value = '';
    document.getElementById('station-modal').classList.add('show');
}

async function editStation(id) {
    try {
        const response = await fetch(`${API_URL}/admin/stations`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const station = data.data.stations.find((s) => s.id === id);
            if (station) {
                document.getElementById('station-modal-title').textContent = 'Edit Station';
                document.getElementById('station-id').value = station.id;
                document.getElementById('station-name').value = station.name;
                document.getElementById('station-city').value = station.city;
                document.getElementById('station-address').value = station.address || '';
                document.getElementById('station-latitude').value = station.latitude || '';
                document.getElementById('station-longitude').value = station.longitude || '';
                document.getElementById('station-facilities').value = station.facilities || '';
                document.getElementById('station-modal').classList.add('show');
            }
        }
    } catch (error) {
        console.error('Edit station error:', error);
    }
}

async function deleteStation(id) {
    if (!confirm('Are you sure you want to delete this station?')) return;

    try {
        const response = await fetch(`${API_URL}/admin/stations/${id}`, {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            alert('Station deleted successfully');
            loadStations();
        } else {
            alert(data.message || 'Failed to delete station');
        }
    } catch (error) {
        console.error('Delete station error:', error);
        alert('Failed to delete station');
    }
}

document.getElementById('station-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();

    const id = document.getElementById('station-id').value;
    const stationData = {
        name: document.getElementById('station-name').value,
        city: document.getElementById('station-city').value,
        address: document.getElementById('station-address').value,
        latitude: document.getElementById('station-latitude').value || null,
        longitude: document.getElementById('station-longitude').value || null,
        facilities: document.getElementById('station-facilities').value,
    };

    try {
        const url = id ? `${API_URL}/admin/stations/${id}` : `${API_URL}/admin/stations`;
        const method = id ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${authToken}`,
            },
            body: JSON.stringify(stationData),
        });

        const data = await response.json();

        if (data.success) {
            alert(data.message);
            closeModal('station-modal');
            loadStations();
        } else {
            alert(data.message || 'Failed to save station');
        }
    } catch (error) {
        console.error('Save station error:', error);
        alert('Failed to save station');
    }
});

// ============ TRAINS ============

async function loadTrains() {
    try {
        const response = await fetch(`${API_URL}/admin/trains`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const tbody = document.querySelector('#trains-table tbody');
            tbody.innerHTML = '';

            data.data.trains.forEach((train) => {
                const statusBadge = getStatusBadge(train.status);
                const row = `
                    <tr>
                        <td>${train.id}</td>
                        <td>${train.train_number}</td>
                        <td>${train.name}</td>
                        <td>${train.type}</td>
                        <td>${train.total_seats}</td>
                        <td>${statusBadge}</td>
                        <td>
                            <button class="btn-edit" onclick="editTrain(${train.id})">Edit</button>
                            <button class="btn-delete" onclick="deleteTrain(${train.id})">Delete</button>
                        </td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        }
    } catch (error) {
        console.error('Load trains error:', error);
    }
}

function showAddTrainModal() {
    document.getElementById('train-modal-title').textContent = 'Add Train';
    document.getElementById('train-form').reset();
    document.getElementById('train-id').value = '';
    document.getElementById('train-modal').classList.add('show');
}

async function editTrain(id) {
    try {
        const response = await fetch(`${API_URL}/admin/trains`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const train = data.data.trains.find((t) => t.id === id);
            if (train) {
                document.getElementById('train-modal-title').textContent = 'Edit Train';
                document.getElementById('train-id').value = train.id;
                document.getElementById('train-number').value = train.train_number;
                document.getElementById('train-name').value = train.name;
                document.getElementById('train-type').value = train.type;
                document.getElementById('train-total-seats').value = train.total_seats;
                document.getElementById('train-first-class').value = train.first_class_seats;
                document.getElementById('train-second-class').value = train.second_class_seats;
                document.getElementById('train-facilities').value = train.facilities || '';
                document.getElementById('train-status').value = train.status;
                document.getElementById('train-modal').classList.add('show');
            }
        }
    } catch (error) {
        console.error('Edit train error:', error);
    }
}

async function deleteTrain(id) {
    if (!confirm('Are you sure you want to delete this train?')) return;

    try {
        const response = await fetch(`${API_URL}/admin/trains/${id}`, {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            alert('Train deleted successfully');
            loadTrains();
        } else {
            alert(data.message || 'Failed to delete train');
        }
    } catch (error) {
        console.error('Delete train error:', error);
        alert('Failed to delete train');
    }
}

document.getElementById('train-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();

    const id = document.getElementById('train-id').value;
    const trainData = {
        trainNumber: document.getElementById('train-number').value,
        type: document.getElementById('train-type').value,
        status: document.getElementById('train-status').value || 'active',
        carriages: [
            // For now, send a default carriage structure
            // TODO: Update this based on actual carriage selection UI
            {
                carriageId: 1,
                quantity: parseInt(document.getElementById('train-total-seats').value) || 1
            }
        ]
    };

    try {
        const url = id ? `${API_URL}/admin/trains/${id}` : `${API_URL}/admin/trains`;
        const method = id ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${authToken}`,
            },
            body: JSON.stringify(trainData),
        });

        const data = await response.json();

        if (data.success) {
            alert(data.message);
            closeModal('train-modal');
            loadTrains();
        } else {
            alert(data.message || 'Failed to save train');
        }
    } catch (error) {
        console.error('Save train error:', error);
        alert('Failed to save train');
    }
});

// ============ TOURS ============

async function loadTrips() {
    try {
        const response = await fetch(`${API_URL}/admin/trips`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const tbody = document.querySelector('#trips-table tbody');
            tbody.innerHTML = '';

            data.data.trips.forEach((tour) => {
                const statusBadge = getStatusBadge(trip.status);
                const row = `
                    <tr>
                        <td>${trip.id}</td>
                        <td>${trip.train_name} (${trip.train_number})</td>
                        <td>${trip.origin_city} → ${trip.destination_city}</td>
                        <td>${new Date(trip.departure_time).toLocaleString()}</td>
                        <td>${new Date(trip.arrival_time).toLocaleString()}</td>
                        <td>${trip.available_seats}</td>
                        <td>${statusBadge}</td>
                        <td>
                            <button class="btn-edit" onclick="editTour(${trip.id})">Edit</button>
                            <button class="btn-delete" onclick="deleteTour(${trip.id})">Delete</button>
                        </td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        }
    } catch (error) {
        console.error('Load tours error:', error);
    }
}

async function showAddTourModal() {
    await loadTrainsForDropdown();
    await loadStationsForDropdown();
    document.getElementById('tour-modal-title').textContent = 'Add Tour';
    document.getElementById('tour-form').reset();
    document.getElementById('tour-id').value = '';
    document.getElementById('tour-modal').classList.add('show');
}

async function loadTrainsForDropdown() {
    try {
        const response = await fetch(`${API_URL}/admin/trains`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const select = document.getElementById('tour-train');
            select.innerHTML = '<option value="">Select Train</option>';
            data.data.trains.forEach((train) => {
                select.innerHTML += `<option value="${train.id}">${train.name} (${train.train_number})</option>`;
            });
        }
    } catch (error) {
        console.error('Load trains dropdown error:', error);
    }
}

async function loadStationsForDropdown() {
    try {
        const response = await fetch(`${API_URL}/admin/stations`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const originSelect = document.getElementById('tour-origin');
            const destSelect = document.getElementById('tour-destination');
            
            originSelect.innerHTML = '<option value="">Select Origin</option>';
            destSelect.innerHTML = '<option value="">Select Destination</option>';
            
            data.data.stations.forEach((station) => {
                const option = `<option value="${station.id}">${station.name} (${station.city})</option>`;
                originSelect.innerHTML += option;
                destSelect.innerHTML += option;
            });
        }
    } catch (error) {
        console.error('Load stations dropdown error:', error);
    }
}

async function editTour(id) {
    await loadTrainsForDropdown();
    await loadStationsForDropdown();

    try {
        const response = await fetch(`${API_URL}/admin/trips`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const trip = data.data.trips.find((t) => t.id === id);
            if (tour) {
                document.getElementById('tour-modal-title').textContent = 'Edit Tour';
                document.getElementById('tour-id').value = trip.id;
                document.getElementById('tour-train').value = trip.train_id;
                document.getElementById('tour-origin').value = trip.origin_station_id;
                document.getElementById('tour-destination').value = trip.destination_station_id;
                document.getElementById('tour-departure').value = new Date(trip.departure_time).toISOString().slice(0, 16);
                document.getElementById('tour-arrival').value = new Date(trip.arrival_time).toISOString().slice(0, 16);
                document.getElementById('tour-first-price').value = trip.first_class_price;
                document.getElementById('tour-second-price').value = trip.second_class_price;
                document.getElementById('tour-seats').value = trip.available_seats;
                document.getElementById('tour-status').value = trip.status;
                document.getElementById('tour-modal').classList.add('show');
            }
        }
    } catch (error) {
        console.error('Edit tour error:', error);
    }
}

async function deleteTour(id) {
    if (!confirm('Are you sure you want to delete this tour?')) return;

    try {
        const response = await fetch(`${API_URL}/admin/trips/${id}`, {
            method: 'DELETE',
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            alert('Tour deleted successfully');
            loadTrips();
        } else {
            alert(data.message || 'Failed to delete tour');
        }
    } catch (error) {
        console.error('Delete tour error:', error);
        alert('Failed to delete tour');
    }
}

document.getElementById('tour-form')?.addEventListener('submit', async (e) => {
    e.preventDefault();

    const id = document.getElementById('tour-id').value;
    const tripData = {
        train_id: parseInt(document.getElementById('tour-train').value),
        origin_station_id: parseInt(document.getElementById('tour-origin').value),
        destination_station_id: parseInt(document.getElementById('tour-destination').value),
        departure_time: new Date(document.getElementById('tour-departure').value).toISOString(),
        arrival_time: new Date(document.getElementById('tour-arrival').value).toISOString(),
        first_class_price: parseFloat(document.getElementById('tour-first-price').value),
        second_class_price: parseFloat(document.getElementById('tour-second-price').value),
        available_seats: parseInt(document.getElementById('tour-seats').value),
        status: document.getElementById('tour-status').value,
    };

    try {
        const url = id ? `${API_URL}/admin/trips/${id}` : `${API_URL}/admin/trips`;
        const method = id ? 'PUT' : 'POST';

        const response = await fetch(url, {
            method,
            headers: {
                'Content-Type': 'application/json',
                Authorization: `Bearer ${authToken}`,
            },
            body: JSON.stringify(tourData),
        });

        const data = await response.json();

        if (data.success) {
            alert(data.message);
            closeModal('tour-modal');
            loadTrips();
        } else {
            alert(data.message || 'Failed to save tour');
        }
    } catch (error) {
        console.error('Save tour error:', error);
        alert('Failed to save tour');
    }
});

// ============ RESERVATIONS ============

async function loadReservations() {
    try {
        const response = await fetch(`${API_URL}/admin/reservations`, {
            headers: { Authorization: `Bearer ${authToken}` },
        });

        const data = await response.json();

        if (data.success) {
            const tbody = document.querySelector('#reservations-table tbody');
            tbody.innerHTML = '';

            data.data.reservations.forEach((reservation) => {
                const statusBadge = getStatusBadge(reservation.status);
                const row = `
                    <tr>
                        <td><strong>${reservation.booking_reference}</strong></td>
                        <td>${reservation.user_name}<br><small>${reservation.user_email}</small></td>
                        <td>${reservation.train_name}</td>
                        <td>${reservation.origin_name} → ${reservation.destination_name}</td>
                        <td>${new Date(reservation.departure_time).toLocaleString()}</td>
                        <td>${reservation.seat_class === 'first' ? 'First Class' : 'Second Class'}</td>
                        <td>${reservation.number_of_seats}</td>
                        <td>$${parseFloat(reservation.total_price).toFixed(2)}</td>
                        <td>${statusBadge}</td>
                    </tr>
                `;
                tbody.innerHTML += row;
            });
        }
    } catch (error) {
        console.error('Load reservations error:', error);
    }
}

// Utility functions
function getStatusBadge(status) {
    const badges = {
        active: 'badge-success',
        scheduled: 'badge-success',
        confirmed: 'badge-success',
        maintenance: 'badge-warning',
        boarding: 'badge-info',
        departed: 'badge-info',
        pending: 'badge-warning',
        cancelled: 'badge-danger',
        retired: 'badge-danger',
    };

    const badgeClass = badges[status] || 'badge-info';
    return `<span class="badge ${badgeClass}">${status.toUpperCase()}</span>`;
}

function closeModal(modalId) {
    document.getElementById(modalId).classList.remove('show');
}
