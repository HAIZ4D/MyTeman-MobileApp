const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
const { v4: uuidv4 } = require('uuid');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;

app.use(cors());
app.use(bodyParser.json());

// Mock database
let users = [];
let services = [];
let applications = [];

// Load seed data
const loadSeedData = () => {
  try {
    const seedData = JSON.parse(fs.readFileSync(path.join(__dirname, 'seed-data.json'), 'utf8'));
    users = seedData.users || [];
    services = seedData.services || [];
    console.log(`Loaded ${users.length} users and ${services.length} services from seed data`);
  } catch (error) {
    console.error('Error loading seed data:', error.message);
  }
};

loadSeedData();

// ==================== Health Check ====================
app.get('/api/health', (req, res) => {
  res.json({
    status: 'ok',
    message: 'MyGOV Mock API is running',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

// ==================== Services ====================

// Get all services
app.get('/api/services', (req, res) => {
  const { category, language } = req.query;

  let filteredServices = [...services];

  // Filter by category if provided
  if (category) {
    filteredServices = filteredServices.filter(s =>
      s.categories.includes(category)
    );
  }

  res.json({
    success: true,
    count: filteredServices.length,
    data: filteredServices
  });
});

// Get service by ID
app.get('/api/services/:id', (req, res) => {
  const service = services.find(s => s.serviceId === req.params.id);

  if (service) {
    res.json({ success: true, data: service });
  } else {
    res.status(404).json({
      success: false,
      message: 'Service not found',
      serviceId: req.params.id
    });
  }
});

// ==================== Users ====================

// Get user by UID
app.get('/api/users/:uid', (req, res) => {
  const user = users.find(u => u.uid === req.params.uid);

  if (user) {
    res.json({ success: true, data: user });
  } else {
    res.status(404).json({
      success: false,
      message: 'User not found',
      uid: req.params.uid
    });
  }
});

// ==================== Applications ====================

// Submit application
app.post('/api/applications', (req, res) => {
  const { serviceId, uid, filledData, status } = req.body;

  // Validate required fields
  if (!serviceId || !uid || !filledData) {
    return res.status(400).json({
      success: false,
      message: 'Missing required fields: serviceId, uid, filledData'
    });
  }

  // Verify service exists
  const service = services.find(s => s.serviceId === serviceId);
  if (!service) {
    return res.status(404).json({
      success: false,
      message: 'Service not found',
      serviceId
    });
  }

  // Verify user exists
  const user = users.find(u => u.uid === uid);
  if (!user) {
    return res.status(404).json({
      success: false,
      message: 'User not found',
      uid
    });
  }

  const application = {
    appId: uuidv4(),
    serviceId,
    uid,
    status: status || 'submitted',
    filledData,
    submittedAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
    audit: [{
      timestamp: new Date().toISOString(),
      action: 'submitted',
      details: 'Application submitted via ISN app',
      actor: uid
    }]
  };

  applications.push(application);

  console.log(`New application submitted: ${application.appId} for service ${serviceId} by user ${uid}`);

  res.status(201).json({
    success: true,
    message: 'Application submitted successfully',
    data: application
  });
});

// Get all applications for a user
app.get('/api/applications/user/:uid', (req, res) => {
  const userApps = applications.filter(app => app.uid === req.params.uid);

  res.json({
    success: true,
    count: userApps.length,
    data: userApps
  });
});

// Get application by ID
app.get('/api/applications/:appId', (req, res) => {
  const application = applications.find(app => app.appId === req.params.appId);

  if (application) {
    res.json({ success: true, data: application });
  } else {
    res.status(404).json({
      success: false,
      message: 'Application not found',
      appId: req.params.appId
    });
  }
});

// Update application status
app.patch('/api/applications/:appId/status', (req, res) => {
  const { status, details, actor } = req.body;
  const application = applications.find(app => app.appId === req.params.appId);

  if (!application) {
    return res.status(404).json({
      success: false,
      message: 'Application not found',
      appId: req.params.appId
    });
  }

  if (!status) {
    return res.status(400).json({
      success: false,
      message: 'Status is required'
    });
  }

  const previousStatus = application.status;
  application.status = status;
  application.updatedAt = new Date().toISOString();

  // Add audit entry
  application.audit.push({
    timestamp: new Date().toISOString(),
    action: 'status_changed',
    details: details || `Status changed from ${previousStatus} to ${status}`,
    actor: actor || 'system',
    previousStatus,
    newStatus: status
  });

  console.log(`Application ${application.appId} status updated: ${previousStatus} -> ${status}`);

  res.json({
    success: true,
    message: 'Application status updated',
    data: application
  });
});

// Batch submit applications (for offline sync)
app.post('/api/applications/batch', (req, res) => {
  const { applications: batchApps } = req.body;

  if (!Array.isArray(batchApps) || batchApps.length === 0) {
    return res.status(400).json({
      success: false,
      message: 'Invalid batch data. Expected array of applications.'
    });
  }

  const results = {
    total: batchApps.length,
    successful: [],
    failed: []
  };

  for (const appData of batchApps) {
    try {
      const { serviceId, uid, filledData, status, submittedAt } = appData;

      if (!serviceId || !uid || !filledData) {
        results.failed.push({
          data: appData,
          error: 'Missing required fields'
        });
        continue;
      }

      const application = {
        appId: appData.appId || uuidv4(),
        serviceId,
        uid,
        status: status || 'submitted',
        filledData,
        submittedAt: submittedAt || new Date().toISOString(),
        updatedAt: new Date().toISOString(),
        audit: appData.audit || [{
          timestamp: new Date().toISOString(),
          action: 'submitted',
          details: 'Application submitted via ISN app (offline sync)',
          actor: uid
        }]
      };

      applications.push(application);
      results.successful.push(application);

      console.log(`Batch application submitted: ${application.appId}`);
    } catch (error) {
      results.failed.push({
        data: appData,
        error: error.message
      });
    }
  }

  res.status(results.failed.length > 0 ? 207 : 201).json({
    success: results.failed.length === 0,
    message: `Processed ${results.total} applications: ${results.successful.length} successful, ${results.failed.length} failed`,
    data: results
  });
});

// ==================== Intent Recognition ====================

// Intent recognition endpoint (mock Gemini)
app.post('/api/intent', (req, res) => {
  const { transcript, language } = req.body;

  if (!transcript) {
    return res.status(400).json({
      success: false,
      message: 'Transcript is required'
    });
  }

  try {
    const patterns = JSON.parse(fs.readFileSync(path.join(__dirname, 'intent-mapping.json'), 'utf8')).patterns;
    const t = transcript.toLowerCase();

    for (const pattern of patterns) {
      const regex = new RegExp(pattern.match, 'i');
      if (regex.test(t)) {
        // Find the service to return full details
        const service = services.find(s => s.serviceId === pattern.serviceId);

        return res.json({
          success: true,
          data: {
            serviceId: pattern.serviceId,
            service: service,
            confidence: 0.9,
            language: pattern.lang,
            matchedPattern: pattern.match
          }
        });
      }
    }

    res.json({
      success: false,
      message: 'No matching service found',
      data: {
        confidence: 0.0,
        suggestions: services.slice(0, 3).map(s => s.serviceId)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: 'Error processing intent',
      error: error.message
    });
  }
});

// ==================== Statistics & Debug ====================

// Get application statistics
app.get('/api/stats', (req, res) => {
  const stats = {
    totalApplications: applications.length,
    totalUsers: users.length,
    totalServices: services.length,
    applicationsByStatus: {},
    applicationsByService: {}
  };

  // Count by status
  applications.forEach(app => {
    stats.applicationsByStatus[app.status] = (stats.applicationsByStatus[app.status] || 0) + 1;
  });

  // Count by service
  applications.forEach(app => {
    stats.applicationsByService[app.serviceId] = (stats.applicationsByService[app.serviceId] || 0) + 1;
  });

  res.json({
    success: true,
    data: stats
  });
});

// Clear all applications (for testing)
app.delete('/api/applications', (req, res) => {
  const count = applications.length;
  applications = [];

  console.log(`Cleared all ${count} applications`);

  res.json({
    success: true,
    message: `Cleared ${count} applications`
  });
});

// ==================== Error Handling ====================

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: 'Endpoint not found',
    path: req.path,
    method: req.method
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({
    success: false,
    message: 'Internal server error',
    error: process.env.NODE_ENV === 'development' ? err.message : undefined
  });
});

// ==================== Start Server ====================

app.listen(PORT, () => {
  console.log('╔═══════════════════════════════════════════════════════╗');
  console.log('║      MyGOV Mock API Server - ISN Accessible Bridge   ║');
  console.log('╚═══════════════════════════════════════════════════════╝');
  console.log('');
  console.log(`🚀 Server running on http://localhost:${PORT}`);
  console.log('');
  console.log('Available Endpoints:');
  console.log('  GET    /api/health                     - Health check');
  console.log('  GET    /api/services                   - Get all services');
  console.log('  GET    /api/services/:id               - Get service by ID');
  console.log('  GET    /api/users/:uid                 - Get user by UID');
  console.log('  POST   /api/applications               - Submit application');
  console.log('  POST   /api/applications/batch         - Batch submit');
  console.log('  GET    /api/applications/user/:uid     - Get user applications');
  console.log('  GET    /api/applications/:appId        - Get application by ID');
  console.log('  PATCH  /api/applications/:appId/status - Update status');
  console.log('  POST   /api/intent                     - Intent recognition');
  console.log('  GET    /api/stats                      - Get statistics');
  console.log('  DELETE /api/applications               - Clear all (testing)');
  console.log('');
  console.log(`📊 Loaded: ${users.length} users, ${services.length} services`);
  console.log('');
});
