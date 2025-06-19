import ballerinax/mysql;

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