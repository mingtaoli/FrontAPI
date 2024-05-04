
module UserModel
using LibPQ
using DataFrames
const DB_CONFIG = Dict(
    "type" => "postgresql"
    "host" => "localhost",
    "port" => 5432,
    "dbname" => "ai4e-datacenter-postgres",
    "user" => "ai4e_datacenter",
    "password" => "dlgcdxlgjzdsys1234"
)


struct DatabaseObject
    conn::LibPQ.Connection
    tablename::string
end

const TableName = "users"

# 应该定义User 类型
# 然后再定义Database类型
# 然后定义函数增删改查，用多重分发，十分julian
#function Insert(databaseobject::Database,user::User)
#end

function get_conn_str()
    return "host=$(DB_CONFIG["host"]) port=$(DB_CONFIG["port"]) dbname=$(DB_CONFIG["dbname"]) user=$(DB_CONFIG["user"]) password=$(DB_CONFIG["password"])"
end

function FindOneByUserName(username)
    conn_str = get_conn_str()
    conn = LibPQ.Connection(conn_str)
    try
        query = "SELECT * FROM $TableName WHERE username = $(username)"
        result = LibPQ.execute(conn, query)
        return DataFrame(result)
    finally
        close(conn)
    end
end

end