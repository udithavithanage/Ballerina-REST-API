import ballerina/http;
import ballerina/sql;
import ballerina/log;

// public final mysql:Client rawClient = check new (
//     host = "localhost",
//     port = 3306,
//     user = "root",
//     password = "root",
//     database = "userTest"    
// );

// public function initDatabase() returns error? {
//     string sqlFilePath = "./resources/db_scripts.sql";

//     // Read the entire SQL file
//     string content = check io:fileReadString(sqlFilePath);

//     sql:ParameterizedQuery query = `${content}`;
//     sql:ExecutionResult executionResult = check rawClient->execute(query);
// }

import my_crud_service.database;


service /users on new http:Listener(8080) {

    resource function post addUser(http:Caller caller, http:Request req) returns error? {
        json|error userJson = req.getJsonPayload();
        http:Response res = new;

        if userJson is json {
            string? name = userJson.name is string ? <string> check userJson.name : ();
            string? email = userJson.email is string ? <string> check userJson.email : ();

            if name is () || email is () {
                res.statusCode = http:STATUS_BAD_REQUEST;
                res.setPayload({ message: "Both 'name' and 'email' are required and must be strings." });
                check caller->respond(res);
                return;
            }

            sql:ExecutionResult result = check database:insertUser(name, email);
                
            int? id = <int?>result.lastInsertId;
            json resBody = id is int ? { id, name, email } : { name, email };
            res.statusCode = http:STATUS_CREATED;
            res.setPayload(resBody);
            check caller->respond(res);
        } else {
            res.statusCode = http:STATUS_BAD_REQUEST;
            res.setPayload({ message: "Invalid JSON payload." });
            check caller->respond(res);
        }
    }



    resource function get [int id] (http:Caller caller) returns error? {
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

    resource function get searchUsers(http:Caller caller, http:Request req) returns error? {
        // Get 'name' query param
        string nameParam = req.getQueryParamValue("name").toString();

        log:printInfo("Searching for name: " + nameParam);


        // SQL query with parameterized input
        stream<database:User, sql:Error?> result = database:searchUsersByName(nameParam);

        // Manually collect stream values into an array
        database:User[] users = [];
        error? e = result.forEach(function(database:User user) {
            users.push(user);
        });
        if e is error {
            return e;
        }

        // Return the list of users as HTTP response
        http:Response res = new;
        res.setPayload(users);
        check caller->respond(res);
    }
    resource function put updateUser/[int id](http:Caller caller, http:Request req) returns error? {
        json|error userJson = req.getJsonPayload();
        http:Response res = new;

        if userJson is json {
            string? name = userJson.name is string ? <string> check userJson.name : ();
            string? email = userJson.email is string ? <string> check userJson.email : ();

            if name is () || email is () {
                res.statusCode = http:STATUS_BAD_REQUEST;
                res.setPayload({ message: "Both 'name' and 'email' are required and must be strings." });
                check caller->respond(res);
                return;
            }

            
            sql:ExecutionResult result = check database:updateUser( id, name , email);
            
            // Check if any rows were affected
            if result.affectedRowCount == 0 {
                res.setPayload("User not found");
                res.statusCode = http:STATUS_NOT_FOUND;
                check caller->respond(res);
            } else {
                check caller->respond("User updated");
            }

        } else {
            res.statusCode = http:STATUS_BAD_REQUEST;
            res.setPayload({ message: "Invalid JSON payload." });
            check caller->respond(res);
        }
    }

    resource function delete deleteUser/[int id](http:Caller caller, http:Request req) returns error? {
        // Delete user from database
        sql:ExecutionResult result = check database:deleteUser(id);
        
        // Check if any rows were affected
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

// Main function to initialize the service
public function main() returns error? {
    log:printInfo("User service started on port 8080");
}