const BaseError = require("./BaseError");

// signals a 400 bad request error (e.g., missing or invalid input)
class BadRequestError extends BaseError {
    constructor(message = "Bad Request", details = null) {
        super(message, 400, details);
    }
}

module.exports = BadRequestError;