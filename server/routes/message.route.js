const express = require("express");
const router = express.Router();
const authMiddleware = require("../middlewares/authMiddlewares");
const messageController = require("../controllers/message.controller");


router.post('/send',
  authMiddleware("access"),
  messageController.sendMessage
);


router.get('/personal/:user1/:user2',
  authMiddleware("access"),
  messageController.fetchPersonalMessages
);


router.get('/group/:groupId',
  authMiddleware("access"),
  messageController.fetchGroupMessages
);

module.exports = router;





module.exports = router;