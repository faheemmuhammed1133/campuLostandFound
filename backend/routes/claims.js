const express = require('express');
const router = express.Router();
const Claim = require('../models/Claim');
const Item = require('../models/Item');
const Notification = require('../models/Notification');

router.get('/', async (req, res) => {
  try {
    const { itemId } = req.query;
    const filter = itemId ? { itemId } : {};
    const claims = await Claim.find(filter).sort({ date: -1 });
    res.json(claims);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.post('/', async (req, res) => {
  try {
    const { itemId, claimerUsername, description } = req.body;
    const claim = new Claim({ itemId, claimerUsername, description });
    await claim.save();

    // Notify the claim manager (foundBy user, or poster if no finder)
    const item = await Item.findById(itemId);
    if (item) {
      const claimManager = item.foundBy || item.postedBy;
      if (claimManager !== claimerUsername) {
        await Notification.create({
          recipientUsername: claimManager,
          message: `${claimerUsername} submitted a claim on '${item.title}'`,
          itemId: item._id,
          type: 'claim_submitted',
        });
      }
    }

    res.status(201).json(claim);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id/approve', async (req, res) => {
  try {
    const claim = await Claim.findByIdAndUpdate(
      req.params.id,
      { status: 'approved' },
      { new: true }
    );
    if (!claim) return res.status(404).json({ error: 'Claim not found' });

    // Mark item as resolved
    const item = await Item.findByIdAndUpdate(
      claim.itemId,
      { status: 'resolved' },
      { new: true }
    );

    if (item) {
      // Notify the approved claimer
      await Notification.create({
        recipientUsername: claim.claimerUsername,
        message: `Your claim on '${item.title}' has been approved!`,
        itemId: item._id,
        type: 'claim_approved',
      });

      // Reject all other pending claims and notify them
      const otherPendingClaims = await Claim.find({
        itemId: claim.itemId,
        _id: { $ne: claim._id },
        status: 'pending',
      });

      for (const otherClaim of otherPendingClaims) {
        otherClaim.status = 'rejected';
        await otherClaim.save();

        await Notification.create({
          recipientUsername: otherClaim.claimerUsername,
          message: `Your claim on '${item.title}' has been rejected.`,
          itemId: item._id,
          type: 'claim_rejected',
        });
      }
    }

    res.json({ message: 'Claim approved, item resolved' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.put('/:id/reject', async (req, res) => {
  try {
    const claim = await Claim.findByIdAndUpdate(
      req.params.id,
      { status: 'rejected' },
      { new: true }
    );
    if (!claim) return res.status(404).json({ error: 'Claim not found' });

    // Notify the rejected claimer
    const item = await Item.findById(claim.itemId);
    if (item) {
      await Notification.create({
        recipientUsername: claim.claimerUsername,
        message: `Your claim on '${item.title}' has been rejected.`,
        itemId: item._id,
        type: 'claim_rejected',
      });
    }

    res.json({ message: 'Claim rejected' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
