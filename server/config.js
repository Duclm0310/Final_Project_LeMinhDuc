require("dotenv").config();
const mongoose = require("mongoose");
const { Client, Pool } = require("pg");
const { Sequelize } = require("sequelize");

// PostgreSQL database configuration
const DB_NAME = process.env.DB_NAME || "postgres"; // Database name
const DB_USERNAME = process.env.DB_USERNAME || "postgres"; // Database username
const DB_PASSWORD = process.env.DB_PASSWORD || "password"; // Database password
const DB_HOST = process.env.DB_HOST || "127.0.0.1"; // Host (default: 127.0.0.1)
const DB_PORT = process.env.DB_PORT || 5432; // Port (default: 5432)
const DB_DIALECT = "postgres"; // Database dialect for Sequelize
const POSTGRES_CONNECTION_STRING = process.env.POSTGRES_CONNECTION_STRING || "";

const connectToMongoDB = async () => {
    try {
        await mongoose.connect(process.env.MONGODB_URI);
        console.log("MongoDB connected successfully");
    } catch (err) {
        console.error("MongoDB connection error:", err.message);
        process.exit(1); // Exit process with failure
    }
};

const client = new Client({
    host: DB_HOST,
    user: DB_USERNAME,
    port: DB_PORT,
    password: DB_PASSWORD,
    database: "postgres",
});

const pool = "";

// const pool = new Pool({
//     connectionString: POSTGRES_CONNECTION_STRING,
//     ssl: {
//         rejectUnauthorized: false,
//     },
// });

// const getLogger = (serviceName, serviceVersion, level) => bunyan.createLogger()

const connectToPostgres = () => {
    try {
        sequelize.authenticate();
        console.log("PostgreSQL connected successfully!");
    } catch (error) {
        console.error("Unable to connect to PostgreSQL:", error.message);
        process.exit(1); // Exit with failure
    }
};

// pgadmin 
// const sequelize = new Sequelize('testdb', 'postgres', '03102003', {
//     host: 'localhost',
//     dialect: 'postgres',
//     logging: false
// });"

//neon
const sequelize = new Sequelize("neondb", "neondb_owner", "npg_NgY9hK0Dymvi", {
    host: "ep-orange-base-a1wtwz2g-pooler.ap-southeast-1.aws.neon.tech",
    port: 5432,
    dialect: DB_DIALECT,
    logging: false,
    dialectOptions: {
        ssl: {
            require: true,
            rejectUnauthorized: false,
        },
    },
});


module.exports = {
    client,
    sequelize,
    connectToPostgres,
    connectToMongoDB,
};
