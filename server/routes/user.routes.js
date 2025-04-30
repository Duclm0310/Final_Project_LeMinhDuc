const express = require("express");
const router = express.Router();
const userController = require("../controllers/user.controller");
const { resendOtp } = require("../controllers/otp.controller.js");
const authMiddleware = require("../middlewares/authMiddlewares");
const rbacMiddleware = require("../middlewares/rbacMiddlewares.js");
const { validateUser } = require("../middlewares/validation");

router.get(
    "/:user_id/roles",
    authMiddleware("access"),
    rbacMiddleware(["READ"], "USER"),
    userController.getUserRolesAndPermissions
);

router.get("/", userController.getAllUsers);

router.get("/:user_id", userController.getUserById);

router.post("/", validateUser, userController.createUser);

router.put("/:user_id", userController.updateUser);

router.delete("/:user_id", userController.deleteUser);

router.post("/token", userController.reprovideToken);

router.post("/verify-otp", userController.verifyOtp);

router.post("/resend-otp", resendOtp);
router.post(
    "/verify-password-reset-otp",
    userController.verifyPasswordResetOtp
);

router.post("/signin", userController.signinUser);

router.post("/logout", userController.logoutUser);

router.post("/request-reset-password", userController.requestPasswordReset);

router.post(
    "/reset-password",
    authMiddleware("reset-password"),
    userController.resetPassword
);

router.post("/:user_id/device/:device_id", userController.assignDevice);

router.delete("/device/:device_id", userController.unassignDevice);

router.post("/assign-role", userController.assignRole);

router.post("/unassign-role", userController.unassignRole);

router.post("/share-resource", authMiddleware("access"), userController.shareResource);

router.get(
    "/devices/my-devices",
    authMiddleware("access"),
    userController.getMyDevices
);

module.exports = router;
