import ballerinax/mysql;
import ballerina/sql;

// # Configurable variable for the MySQL database host
configurable string host = ?;

// # Configurable variable for the MySQL database port
configurable int port = ?;

// # Configurable variable for the MySQL database user
configurable string user = ?;

// # Configurable variable for the MySQL database password
configurable string password = ?;

// # Configurable variable for the MySQL database name
configurable string database = ?;

// # MySQL client instance for database operations
public final mysql:Client dbClient = check new (
    host = host,
    port = port,
    user = user,
    password = password,
    database = database
);

// # Creates the users table in the database if it does not exist
// # + return - SQL execution result or error if operation fails | nil on success
public function createUsersTable() returns sql:ExecutionResult|error? {
    sql:ParameterizedQuery createTableQuery = 
        `CREATE TABLE IF NOT EXISTS users (
            id INT AUTO_INCREMENT PRIMARY KEY,
            name VARCHAR(100) NOT NULL,
            email VARCHAR(100) NOT NULL
        )`;

    sql:ExecutionResult result = check dbClient->execute(createTableQuery);

    return result;
}