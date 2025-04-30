const BaseError = require("./BaseError");

// signals a 403 Forbidden error (e.g., insufficient permissions)
class UnauthorizedError extends BaseError {
    constructor(message = "Forbidden: Access denied") {
        super(message, 403);
    }
}

module.exports = UnauthorizedError;
