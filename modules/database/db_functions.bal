import ballerina/sql;

// # Inserts a new user into the database
// # + name - Name of the user
// # + email - Email of the user
// # + return - SQL execution result or error if operation fails
public function insertUser(string name, string email) returns sql:ExecutionResult|error {
    return dbClient->execute(
        addRecord(name, email)
    );
}

// # Retrieves a user from the database by ID
// # + id - ID of the user to retrieve
// # + return - User record or SQL error if operation fails
public function getUserById(int id) returns User|sql:Error {
    return dbClient->queryRow(getById(id), User);
}

// # Searches for users in the database by name
// # + name - Name to search for
// # + return - Stream of user records or SQL error if operation fails
public function searchUsersByName(string name) returns stream<User, sql:Error?> {
    return dbClient->query(searchRecords(name), User);
}

// # Updates a user in the database by ID
// # + id - ID of the user to update
// # + name - Updated name of the user
// # + email - Updated email of the user
// # + return - SQL execution result or error if operation fails
public function updateUser(int id, string name, string email) returns sql:ExecutionResult|error {
    return dbClient->execute(
        updateRecord(name, email, id)
    );
}

// # Deletes a user from the database by ID
// # + id - ID of the user to delete
// # + return - SQL execution result or error if operation fails
public function deleteUser(int id) returns sql:ExecutionResult|error {
    return dbClient->execute(deleteRecord(id));
}