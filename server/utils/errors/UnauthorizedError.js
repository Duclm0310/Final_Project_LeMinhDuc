const BaseError = require("./BaseError");

// signals a 401 Unauthorized error (e.g., invalid or missing authentication)
class UnauthorizedError extends BaseError {
    constructor(message = "Unauthorized: Authentication required") {
        super(message, 401);
    }
}

module.exports = UnauthorizedError;
