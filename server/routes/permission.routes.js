const express = require("express");
const permissionController = require("../controllers/permission.controller");
const { validatePermission } = require("../middlewares/validation");
const router = express.Router();

// GET
router.get("/", permissionController.getAllPermissions);
router.get("/:permission_id", permissionController.getPermissionById);

// POST
router.post("/", validatePermission, permissionController.createPermission);

// UPDATE
router.put(
    "/:permission_id",
    validatePermission,
    permissionController.updatePermission
);

// DELETE
router.delete("/:permission_id", permissionController.deletePermission);
router.delete("/", permissionController.deleteAllPermissions);

module.exports = router;
