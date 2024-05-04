
module UserModel
using LibPQ
const DB_CONFIG = Dict(
    "host" => "localhost",
    "port" => 5432,
    "dbname" => "ai4e-datacenter-postgres",
    "user" => "ai4e_datacenter",
    "password" => "dlgcdxlgjzdsys1234"
)

#conn_str="host=$(DB_CONFIG["host"]) port=$(DB_CONFIG["port"]) dbname=$(DB_CONFIG["dbname"]) user=$(DB_CONFIG["user"]) password=$(DB_CONFIG["password"])"

#const conn=LibPQ.Connection(conn_str)

const TableName = "users"


#result=LibPQ.execute(conn, "SELECT * from users;")
#using DataFrames
#tabledata=DataFrame(result)


end