module UserModel
using LibPQ, MySQL, DataFrames, Logging, Dates

# 数据库配置结构体
mutable struct DBConfig
    type::String
    host::String
    port::Int
    dbname::String
    user::String
    password::String
end

# 定义全局的数据库配置变量
const DBCONFIG = Ref{DBConfig}()

# 定义一个通用的用户模型驱动类型
abstract type UserModelDriver end

struct UserModelPGDriver <: UserModelDriver
    connection::LibPQ.Connection
    tablename::String
    function UserModelPGDriver(connection::LibPQ.Connection)
        new(connection, "public.users")
    end
end

struct UserModelMySQLDriver <: UserModelDriver
    connection::MySQL.Connection
    tablename::String
    function UserModelMySQLDriver(connection::MySQL.Connection)
        new(connection, "users")
    end
end

struct User
    userid::Int64
    loginname::String
    password::String
    email::Union{Nothing, String}
    phone::Union{Nothing, String}
    enableflag::Int64
    nickname::Union{Nothing, String}
    avatarurl::Union{Nothing, String}
    createdtime::DateTime
    deleted::Int64
end

function tableName(driver::UserModelDriver)
    return driver.tablename
end

# 生成数据库连接字符串
function get_conn_str(db_config::DBConfig)::String
    if db_config.type == "postgresql"
        return "host=$(db_config.host) port=$(db_config.port) dbname=$(db_config.dbname) user=$(db_config.user) password=$(db_config.password)"
    elseif db_config.type == "mysql"
        return "host=$(db_config.host);port=$(db_config.port);dbname=$(db_config.dbname);user=$(db_config.user);password=$(db_config.password)"
    else
        throw(ArgumentError("Unsupported database type: $(db_config.type)"))
    end
end

# 初始化和关闭数据源
function setup_model_driver(db_config::DBConfig)::UserModelDriver
    conn_str = get_conn_str(db_config)
    if db_config.type == "postgresql"
        connection = LibPQ.Connection(conn_str)
        return UserModelPGDriver(connection)
    elseif db_config.type == "mysql"
        connection = MySQL.Connection(conn_str)
        return UserModelMySQLDriver(connection)
    else
        throw(ArgumentError("Unsupported database type: $(db_config.type)"))
    end
end

function close(driver::UserModelPGDriver)
    close(driver.connection)
end

function close(driver::UserModelMySQLDriver)
    MySQL.disconnect(driver.connection)
end

# 根据用户ID删除
function delete_user(userid::Int64, driver::UserModelPGDriver)::Bool
    query = "DELETE FROM $(driver.tablename) WHERE userid = \$1"
    try
        LibPQ.execute(driver.connection, query, [userid])
        @info "Successfully deleted user with ID: $userid"
    catch e
        @error "Failed to delete user with ID: $userid. Error: $e"
        return false
    end
    return true
end

function delete_user(userid::Int64, driver::UserModelMySQLDriver)::Bool
    query = "DELETE FROM $(driver.tablename) WHERE userid = ?"
    try
        MySQL.execute(driver.connection, query, userid)
        @info "Successfully deleted user with ID: $userid"
    catch e
        @error "Failed to delete user with ID: $userid. Error: $e"
        return false
    end
    return true
end

# 根据用户ID查找单个用户
function find_one_by_userid(userid::Int64, driver::UserModelPGDriver)::Union{User, Nothing}
    query = "SELECT * FROM $(driver.tablename) WHERE userid = \$1 LIMIT 1"
    result = LibPQ.execute(driver.connection, query, [userid])

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

function find_one_by_userid(userid::Int64, driver::UserModelMySQLDriver)::Union{User, Nothing}
    query = "SELECT * FROM $(driver.tablename) WHERE userid = ? LIMIT 1"
    result = MySQL.execute(driver.connection, query, userid)

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
function find_one_by_loginname(loginname::String, driver::UserModelPGDriver)::Union{User, Nothing}
    query = "SELECT * FROM $(driver.tablename) WHERE loginname = \$1 LIMIT 1"
    result = LibPQ.execute(driver.connection, query, [loginname])

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

function find_one_by_loginname(loginname::String, driver::UserModelMySQLDriver)::Union{User, Nothing}
    query = "SELECT * FROM $(driver.tablename) WHERE loginname = ? LIMIT 1"
    result = MySQL.execute(driver.connection, query, loginname)

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
function insert_user(data::User, driver::UserModelPGDriver)::Bool
    query = "INSERT INTO $(driver.tablename) (userid, loginname, password, email, phone, enableflag, nickname, avatarurl, createdtime, deleted) " *
            "VALUES (\$1, \$2, \$3, \$4, \$5, \$6, \$7, \$8, \$9, \$10)"
    try
        LibPQ.execute(
            driver.connection, query,
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

function insert_user(data::User, driver::UserModelMySQLDriver)::Bool
    query = "INSERT INTO $(driver.tablename) (userid, loginname, password, email, phone, enableflag, nickname, avatarurl, createdtime, deleted) " *
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)"
    try
        MySQL.execute(
            driver.connection, query,
            data.userid, data.loginname, data.password, data.email,
            data.phone, data.enableflag, data.nickname, data.avatarurl,
            data.createdtime, data.deleted
        )
        @info "Successfully inserted new user with ID: $(data.userid)"
        return true
    catch e
        @error "Failed to insert new user. Error: $e"
        return false
    end
end

# 更新用户数据
function update_user(data::User, driver::UserModelPGDriver)::Bool
    query = "UPDATE $(driver.tablename) SET loginname = \$2, password = \$3, email = \$4, phone = \$5, enableflag = \$6, " *
            "nickname = \$7, avatarurl = \$8, createdtime = \$9, deleted = \$10 WHERE userid = \$1"
    try
        LibPQ.execute(
            driver.connection, query,
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

function update_user(data::User, driver::UserModelMySQLDriver)::Bool
    query = "UPDATE $(driver.tablename) SET loginname = ?, password = ?, email = ?, phone = ?, enableflag = ?, " *
            "nickname = ?, avatarurl = ?, createdtime = ?, deleted = ? WHERE userid = ?"
    try
        MySQL.execute(
            driver.connection, query,
            data.userid, data.loginname, data.password, data.email,
            data.phone, data.enableflag, data.nickname, data.avatarurl,
            data.createdtime, data.deleted
        )
        @info "Successfully updated user with ID: $(data.userid)"
        return true
    catch e
        @error "Failed to update user with ID: $(data.userid). Error: $e"
        return false
    end
end

end
