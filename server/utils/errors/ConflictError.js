const BaseError = require("./BaseError");

// signals a 409 Conflict error (e.g., duplicate data, conflicting request)
class BadRequestError extends BaseError {
    constructor(message = "Resource Conflict", details = null) {
        super(message, 409, details);
    }
}

module.exports = BadRequestError;
