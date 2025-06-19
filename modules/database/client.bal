import ballerinax/mysql;
import ballerina/sql;

configurable string host = ?;
configurable int port = ?;
configurable string user = ?;
configurable string password  = ?;
configurable string database = ?;

public final mysql:Client dbClient = check new (
    host = host,
    port = port,
    user = user,
    password = password,
    database = database
);

// Function to create the users table
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

