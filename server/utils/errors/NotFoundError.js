const BaseError = require("./BaseError");

// signals a 404 Not Found error (e.g., resource does not exist)
class NotFoundError extends BaseError {
    constructor(message = "Resource not found") {
        super(message, 404);
    }
}

module.exports = NotFoundError;
