const BaseError = require("./BaseError");

// signals a 400 Validation Error (e.g., invalid user input format)
class ValidationError extends BaseError {
    constructor(message = "Invalid input") {
        super(message, 400);
    }
}

module.exports = ValidationError;