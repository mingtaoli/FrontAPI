module UserModel
using LibPQ, DataFrames

# 数据库配置常量
const DB_CONFIG = Dict(
    "type" => "postgresql",
    "host" => "localhost",
    "port" => 5432,
    "dbname" => "ai4e-datacenter-postgres",
    "user" => "ai4e_datacenter",
    "password" => "dlgcdxlgjzdsys1234"
)

abstract type AbstractDataSource end

# 定义PostgreSQL数据源
struct PGSQL <: AbstractDataSource
    conn::LibPQ.Connection
    tablename::String
end

const TableName = "users"

# 定义用户类型
struct User
    username::String
    # 可以根据需要添加更多字段
end

# 生成数据库连接字符串
function get_conn_str()
    return "host=$(DB_CONFIG["host"]) port=$(DB_CONFIG["port"]) dbname=$(DB_CONFIG["dbname"]) user=$(DB_CONFIG["user"]) password=$(DB_CONFIG["password"])"
end

"""
    根据用户名查询用户信息
    - username::String: 用户名
    - datasource::PGSQL: 数据源
    返回值：DataFrame包含查询结果
"""
function find_one_by_username(username::String, datasource::PGSQL)
    conn_str = get_conn_str()
    conn = LibPQ.Connection(conn_str)
    try
        query = "SELECT * FROM $(datasource.tablename) WHERE username = \$1"
        result = LibPQ.execute(conn, query, [username])
        return DataFrame(result)
    finally
        close(conn)
    end
end

end
