module UserModel
using LibPQ, DataFrames, Logging, Dates

# 数据库配置常量
const DB_CONFIG = Dict(
    "host" => "localhost",
    "port" => 5432,
    "dbname" => "ai4e-datacenter-postgres",
    "user" => "ai4e_datacenter",
    "password" => "dlgcdxlgjzdsys1234"
)

abstract type AbstractUserModel end

struct PGUsersModel <: AbstractUserModel
    connection::LibPQ.Connection
    tablename::String
    function PGUsersModel(connection::LibPQ.Connection)
        new(connection, "public.users")
    end
end

struct User
    userid::Int64
    loginname::String
    password::String
    email::Union{Nothing,String}
    phone::Union{Nothing,String}
    enableflag::Int64
    nickname::Union{Nothing,String}
    avatarurl::Union{Nothing,String}
    createdtime::DateTime
    deleted::Int64
end

function tableName(model::PGUsersModel)
    return model.tablename
end


# 初始化和关闭 PostgreSQL 数据源
function PGDataSource(db_config::Dict{String,String})
    conn_str = get_conn_str(db_config)
    connection = LibPQ.Connection(conn_str)
    return new(connection)
end

function close(datasource::PGDataSource)
    close(datasource.connection)
end

# 生成数据库连接字符串
function get_conn_str()
    return "host=$(DB_CONFIG["host"]) port=$(DB_CONFIG["port"]) dbname=$(DB_CONFIG["dbname"]) user=$(DB_CONFIG["user"]) password=$(DB_CONFIG["password"])"
end

# 获取表名称
function tableName(model::PGUsersModel)
    return model.tablename
end


# 根据用户ID删除
function delete_user(userid::Int64, model::PGUsersModel)::Bool
    query = "DELETE FROM $(model.tablename) WHERE userid = \$1"
    try
        LibPQ.execute(model.connection, query, [userid])
        @info "Successfully deleted user with ID: $userid"
    catch e
        @error "Failed to delete user with ID: $userid. Error: $e"
        return false
    end
    return true
end

# 根据用户ID查找单个用户
function find_one_by_userid(userid::Int64, model::PGUsersModel)::Union{User,Nothing}
    query = "SELECT * FROM $(model.tablename) WHERE userid = \$1 LIMIT 1"
    result = LibPQ.execute(model.connection, query, [userid])

    if nrow(result) == 0
        return nothing
    else
        row = result[1, :]
        return User(
            row.userid, row.loginname, row.password, row.email,
            row.phone, row.enableflag, row.nickname, row.avatarurl,
            row.createdtime, row.deleted
        )
    end
end

# 根据登录名查找单个用户
function find_one_by_loginname(loginname::String, model::PGUsersModel)::Union{User,Nothing}
    query = "SELECT * FROM $(model.tablename) WHERE loginname = \$1 LIMIT 1"
    result = LibPQ.execute(model.connection, query, [loginname])

    if nrow(result) == 0
        return nothing
    else
        row = result[1, :]
        return User(
            row.userid, row.loginname, row.password, row.email,
            row.phone, row.enableflag, row.nickname, row.avatarurl,
            row.createdtime, row.deleted
        )
    end
end

# 插入新的用户数据
function insert_user(data::User, model::PGUsersModel)::Bool
    query = "INSERT INTO $(model.tablename) (userid, loginname, password, email, phone, enableflag, nickname, avatarurl, createdtime, deleted) " *
            "VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10)"
    try
        LibPQ.execute(
            model.connection, query,
            [data.userid, data.loginname, data.password, data.email,
                data.phone, data.enableflag, data.nickname, data.avatarurl,
                data.createdtime, data.deleted]
        )
        @info "Successfully inserted new user with ID: $(data.userid)"
        return true
    catch e
        @error "Failed to insert new user. Error: $e"
        return false
    end
end

# 更新用户数据
function update_user(data::User, model::PGUsersModel)::Bool
    query = "UPDATE $(model.tablename) SET loginname = \$2, password = \$3, email = \$4, phone = \$5, enableflag = \$6, " *
            "nickname = \$7, avatarurl = \$8, createdtime = \$9, deleted = \$10 WHERE userid = \$1"
    try
        LibPQ.execute(
            model.connection, query,
            [data.userid, data.loginname, data.password, data.email,
                data.phone, data.enableflag, data.nickname, data.avatarurl,
                data.createdtime, data.deleted]
        )
        @info "Successfully updated user with ID: $(data.userid)"
        return true
    catch e
        @error "Failed to update user with ID: $(data.userid). Error: $e"
        return false
    end
end
end
