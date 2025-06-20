import ballerina/sql;

# Creates a parameterized SQL query to insert a new user record
# + name - Name of the user
# + email - Email of the user
# + return - Parameterized SQL query for inserting a user
isolated function addRecord(string name, string email) returns sql:ParameterizedQuery {
    return `INSERT INTO users (name, email) VALUES (${name}, ${email})`;
}

# Creates a parameterized SQL query to retrieve a user by ID
# + id - ID of the user to retrieve
# + return - Parameterized SQL query for selecting a user
isolated function getById(int id) returns sql:ParameterizedQuery {
    return `SELECT id, name, email FROM users WHERE id = ${id}`;
}

# Creates a parameterized SQL query to search users by name
# + name - Name to search for
# + return - Parameterized SQL query for searching users
isolated function searchRecords(string name) returns sql:ParameterizedQuery {
    return `SELECT id, name, email FROM users WHERE name = ${name}`;
}

# Creates a parameterized SQL query to update a user record
# + name - Updated name of the user
# + email - Updated email of the user
# + id - ID of the user to update
# + return - Parameterized SQL query for updating a user
isolated function updateRecord(string name, string email, int id) returns sql:ParameterizedQuery {
    return `UPDATE users SET name = ${name}, email = ${email} WHERE id = ${id}`;
}

# Creates a parameterized SQL query to delete a user record
# + id - ID of the user to delete
# + return - Parameterized SQL query for deleting a user
isolated function deleteRecord(int id) returns sql:ParameterizedQuery {
    return `DELETE FROM users WHERE id = ${id}`;
}