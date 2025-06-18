import ballerina/sql;

public function insertUser(string name, string email) returns sql:ExecutionResult|error {
    return dbClient->execute(
        addRecord(name, email)
    );
}


public function getUserById(int id) returns User|sql:Error {
    return dbClient->queryRow(getById(id), User);
}

public function searchUsersByName(string name) returns stream<User, sql:Error?> {
    return dbClient->query(searchRecords(name), User);
}

public function updateUser(int id, string name, string email) returns sql:ExecutionResult|error {
    return dbClient->execute(
        updateRecord(name, email,id)
    );
}

public function deleteUser(int id) returns sql:ExecutionResult|error {
    return dbClient->execute(deleteRecord(id));
}