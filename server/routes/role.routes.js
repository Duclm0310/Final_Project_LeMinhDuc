const express = require("express");
const roleController = require("../controllers/role.controller");
const { validateRole } = require("../middlewares/validation");
const router = express.Router();

// get all permissions of a role
router.get("/:role_name/permissions", roleController.getRolesPermissions);
router.get("/", roleController.getAllRoles);
router.get("/:role_id", roleController.getRoleById);

// assign permissions to a role
router.post("/:role_id/assign-permission/:permission_id", roleController.assignPermissionToRole);
router.post("/:role_id/assign-permission/", roleController.assignPermissionsToRole);
router.post("/", validateRole, roleController.createRole);

router.put("/:role_id", validateRole, roleController.updateRole);

// delete ONE permission of a role
router.delete(
    "/:role_name/permissions/:permission_name",
    roleController.removePermission
);
router.delete("/:role_id", roleController.deleteRole);

module.exports = router;
