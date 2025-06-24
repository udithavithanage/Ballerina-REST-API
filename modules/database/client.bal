import ballerina/sql;
import ballerinax/mysql;

configurable string host = "localhost";
configurable int port = 3306;
configurable string user = ?;
configurable string password = ?;
configurable string database = ?;

# MySQL client instance for database operations
public final mysql:Client dbClient = check new (
    host = host,
    port = port,
    user = user,
    password = password,
    database = database
);

# Creates the users table in the database if it does not exist.
# + return - SQL execution result or error if operation fails | nil on success
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
