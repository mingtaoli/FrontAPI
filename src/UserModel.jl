module UserModel
using LibPQ, DataFrames, Logging, Dates

# 数据库配置结构体
mutable struct DBConfig
    type::String
    host::String
    port::Int
    dbname::String
    user::String
    password::String
end

const DBCONFIG = Ref{DBConfig}()

abstract type UserModelDriver end

struct UserModelPGDriver <: UserModelDriver
    connection::LibPQ.Connection
    tablename::String
    function UserModelPGDriver(connection::LibPQ.Connection)
        new(connection, "public.users")
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

function get_conn_str()::String
    dbconfig=DBCONFIG[]
    if dbconfig.type == "postgresql"
        return "host=$(dbconfig.host) port=$(dbconfig.port) dbname=$(dbconfig.dbname) user=$(dbconfig.user) password=$(dbconfig.password)"
    else
        throw(ArgumentError("Unsupported database type: $(dbconfig.type)"))
    end
end

function setup_model_driver()::UserModelDriver
    dbconfig=DBCONFIG[]
    conn_str = get_conn_str()
    if dbconfig.type == "postgresql"
        connection = LibPQ.Connection(conn_str)
        return UserModelPGDriver(connection)
    else
        throw(ArgumentError("Unsupported database type: $(dbconfig.type)"))
    end
end

function close(driver::UserModelPGDriver)
    close(driver.connection)
end

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
end
