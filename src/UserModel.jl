
module UserModel
using LibPQ
const db_config=Dict(
    "host"=>"localhost",
    "port"=>"5432",
    "dbname"=>"ai4e-datacenter-postgres",
    "user"=>"ai4e_datacenter",
    "password"=>"dlgcdxlgjzdsys1234"
)

conn_str="host=$(db_config["host"]) port=$(db_config["port"]) dbname=$(db_config["dbname"]) user=$(db_config["user"]) password=$(db_config["password"])"

const conn=LibPQ.Connection(conn_str)

const tablename = "users"


result=LibPQ.execute(conn, "SELECT * from users;")
using DataFrames
tabledata=DataFrame(result)


end