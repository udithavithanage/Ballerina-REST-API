import ballerina/sql;

isolated function addRecord(string name, string email) returns sql:ParameterizedQuery {
    return `INSERT INTO users (name, email) VALUES (${name}, ${email})`;
};


isolated function getById(int id) returns sql:ParameterizedQuery {
    return `SELECT id, name, email FROM users WHERE id = ${id}`;
};
isolated function searchRecords(string name) returns sql:ParameterizedQuery {
    return `SELECT id, name, email FROM users WHERE name = ${name}`;
};
isolated function updateRecord(string name, string email, int id) returns sql:ParameterizedQuery {
    return `UPDATE users SET name = ${name}, email = ${email} WHERE id = ${id}`;
};
isolated function deleteRecord(int id) returns sql:ParameterizedQuery {
    return `DELETE FROM users WHERE id = ${id}`;
};


