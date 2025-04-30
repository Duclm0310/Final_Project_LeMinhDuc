const jwt = require("jsonwebtoken");
const path = require("path");
require("dotenv").config({ path: path.resolve(__dirname, "../.env") });
const {
    BaseError,
    BadRequestError,
    NotFoundError,
    UnauthorizedError,
    ValidationError,
    ForbiddenError,
    ConflictError,
} = require("../utils/errors/index");

const authMiddleware =
    (tokenType = "access") =>
        async (req, res, next) => {
            try {
                console.log("RUNNING AUTH MIDDLEWARE");
                let token;
                const authHeader =
                    req.headers.Authorization || req.headers.authorization;

                if (authHeader && authHeader.startsWith("Bearer ")) {
                    token = authHeader.split(" ")[1];
                    if (!token) {
                        throw new UnauthorizedError(
                            "A token is required for authentication"
                        );
                    }
                } else {
                    throw new UnauthorizedError(
                        "A token is required for authentication"
                    );
                }

                let secret;
                switch (tokenType) {
                    case "access":
                        secret = process.env.ACCESS_TOKEN;
                        break;
                    case "reset-password":
                        secret = process.env.PASSWORD_RESET_TOKEN;
                        break;
                    case "refresh":
                        secret = process.env.REFRESH_TOKEN;
                        break;
                    default:
                        throw new Error("Invalid token type");
                }

                let decode;
                try {
                    decode = jwt.verify(token, secret);
                } catch (err) {
                    if (err instanceof jwt.TokenExpiredError) {
                        throw new UnauthorizedError("Your token has expired");
                    } else if (err instanceof jwt.JsonWebTokenError) {
                        throw new UnauthorizedError("Your token is invalid");
                    }
                }

                if (!decode || !decode.exp) {
                    throw new UnauthorizedError("Invalid token");
                }

                const currentTime = Math.floor(Date.now() / 1000);
                if (decode.exp < currentTime) {
                    throw new UnauthorizedError("Token has expired");
                }

                if (!decode.payload) {
                    req.body.payload = decode;
                } else {
                    req.body.payload = decode.payload;
                }
                // req.user = decode;

                console.log("The decoded jwt is: ", decode);
                console.log("EXITING AUTH MIDDLEWARE");
                next();
            } catch (err) {
                console.error(err);
                next(err);
            }
        };

module.exports = authMiddleware;
