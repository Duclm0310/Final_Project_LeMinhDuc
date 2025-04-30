const { BaseError } = require("../utils/errors/index");

const errorHandler = (err, req, res, next) => {
    try {
        console.log("Error handler middleware");
        if (err instanceof BaseError) {
            return res.status(err.statusCode).json({
                status: "Error",
                message: err.message,
            });
        }

        // unexpected errors
        console.error("Unexpected error:", err);

        return res.status(500).json({
            status: "Error",
            message: "Internal Server Error",
        });
    } catch (err) {
        console.error(err);
    }
};

module.exports = errorHandler;
