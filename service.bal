import my_crud_service.database;

import ballerina/http;
import ballerina/log;
import ballerina/sql;

@http:ServiceConfig {
    cors: {
        allowOrigins: ["http://localhost:5173"],
        allowCredentials: false,
        allowHeaders: ["CORELATION_ID"],
        exposeHeaders: ["X-CUSTOM-HEADER"],
        maxAge: 84900
    }
}

service /users on new http:Listener(8080) {

    # Creates a new user in the database.
    # + caller - HTTP caller to send the response
    # + req - HTTP request containing user data (name and email)
    # + return - Error if operation fails | nil on success
    resource function post addUser(http:Caller caller, http:Request req) returns error? {
        json|error userJson = req.getJsonPayload();
        http:Response res = new;

        if userJson is json {
            string? name = userJson.name is string ? <string>check userJson.name : ();
            string? email = userJson.email is string ? <string>check userJson.email : ();

            if name is () || email is () {
                res.statusCode = http:STATUS_BAD_REQUEST;
                res.setPayload({message: "Both 'name' and 'email' are required and must be strings."});
                check caller->respond(res);
                return;
            }

            sql:ExecutionResult result = check database:insertUser(name, email);

            int? id = <int?>result.lastInsertId;
            json resBody = id is int ? {id, name, email} : {name, email};
            res.statusCode = http:STATUS_CREATED;
            res.setPayload(resBody);
            check caller->respond(res);
        } else {
            res.statusCode = http:STATUS_BAD_REQUEST;
            res.setPayload({message: "Invalid JSON payload."});
            check caller->respond(res);
        }
    }

    # Retrieves a user by ID from the database.
    # + caller - HTTP caller to send the response
    # + id - ID of the user to retrieve
    # + return - Error if operation fails | nil on success
    resource function get [int id](http:Caller caller) returns error? {
        // Query user from database
        database:User|sql:Error result = database:getUserById(id);

        // Prepare response
        http:Response res = new;
        if result is sql:NoRowsError {
            res.statusCode = http:STATUS_NOT_FOUND;
            res.setPayload("User not found");
        } else if result is sql:Error {
            return error("Database error", result);
        } else {
            res.setPayload(result);
        }

        check caller->respond(res);
    }

    # Searches for users by name in the database.
    # + caller - HTTP caller to send the response
    # + req - HTTP request containing the 'name' query parameter
    # + return - Error if operation fails | nil on success
    resource function get searchUsers(http:Caller caller, http:Request req) returns error? {
        string nameParam = req.getQueryParamValue("name").toString();
        stream<database:User, sql:Error?> result = database:searchUsersByName(nameParam);

        database:User[] users = [];
        error? e = result.forEach(function(database:User user) {
            users.push(user);
        });
        if e is error {
            return e;
        }

        http:Response res = new;
        res.setPayload(users);
        check caller->respond(res);
    }

    # Updates a user in the database by ID.
    # + caller - HTTP caller to send the response
    # + id - ID of the user to update
    # + req - HTTP request containing updated user data (name and email)
    # + return - Error if operation fails | nil on success
    resource function put updateUser/[int id](http:Caller caller, http:Request req) returns error? {
        json|error userJson = req.getJsonPayload();
        http:Response res = new;

        if userJson is json {
            string? name = userJson.name is string ? <string>check userJson.name : ();
            string? email = userJson.email is string ? <string>check userJson.email : ();

            if name is () || email is () {
                res.statusCode = http:STATUS_BAD_REQUEST;
                res.setPayload({message: "Both 'name' and 'email' are required and must be strings."});
                check caller->respond(res);
                return;
            }

            sql:ExecutionResult result = check database:updateUser(id, name, email);

            if result.affectedRowCount == 0 {
                res.setPayload("User not found");
                res.statusCode = http:STATUS_NOT_FOUND;
                check caller->respond(res);
            } else {
                check caller->respond("User updated");
            }

        } else {
            res.statusCode = http:STATUS_BAD_REQUEST;
            res.setPayload({message: "Invalid JSON payload."});
            check caller->respond(res);
        }
    }

    # Deletes a user from the database by ID.
    # + caller - HTTP caller to send the response
    # + id - ID of the user to delete
    # + req - HTTP request (unused in this function)
    # + return - Error if operation fails | nil on success
    resource function delete deleteUser/[int id](http:Caller caller, http:Request req) returns error? {
        sql:ExecutionResult result = check database:deleteUser(id);

        if result.affectedRowCount == 0 {
            http:Response res = new;
            res.setPayload("User not found");
            res.statusCode = http:STATUS_NOT_FOUND;
            check caller->respond(res);
        } else {
            check caller->respond("User deleted");
        }
    }
}

# Initializes the HTTP service and creates the users table in the database.
# + return - Error if operation fails | nil on success
public function main() returns error? {
    sql:ExecutionResult|error? result = database:createUsersTable();

    if result is error {
        log:printInfo("User table create fail");
    }
    log:printInfo("User service started on port 8080");
}
