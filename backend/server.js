const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');

const authRoutes = require('./routes/auth');
const itemRoutes = require('./routes/items');
const claimRoutes = require('./routes/claims');
const notificationRoutes = require('./routes/notifications');
const messageRoutes = require('./routes/messages');

const app = express();

app.use(cors());
app.use(express.json({ limit: '50mb' }));

app.use('/api/auth', authRoutes);
app.use('/api/items', itemRoutes);
app.use('/api/claims', claimRoutes);
app.use('/api/notifications', notificationRoutes);
app.use('/api/messages', messageRoutes);

mongoose.connect('mongodb://localhost:27017/campus_lost_and_found')
  .then(() => {
    console.log('Connected to MongoDB');
    app.listen(3000, () => {
      console.log('Server running on http://localhost:3000');
    });
  })
  .catch((err) => {
    console.error('MongoDB connection error:', err);
  });
