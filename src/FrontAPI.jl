module FrontAPI
using Oxygen, HTTP
using StructTypes
using YAML
using LibPQ
using MySQL

include("UserModel.jl")
using .UserModel

# 定义不可变的结构体
struct ServerConfig
    host::String
    port::Int
end

struct DatabaseConfig
    type::String
    host::String
    port::Int
    dbname::String
    user::String
    password::String
end

struct AppConfig
    name::String
    server::ServerConfig
    database::DatabaseConfig
end

mutable struct ServiceContext
    config::AppConfig
    oxygencontext::Oxygen.Context
    user_model_driver::UserModel.UserModelDriver
end

# 全局服务上下文变量
const SVCCONTEXT = Ref{ServiceContext}()

# 读取配置文件并初始化配置
function load_config(filename::String)::AppConfig
    config = YAML.load_file(filename)
    server_config = ServerConfig(config["Host"], config["Port"])
    database_config = DatabaseConfig(
        config["Database"]["Type"],
        config["Database"]["Host"],
        config["Database"]["Port"],
        config["Database"]["Dbname"],
        config["Database"]["User"],
        config["Database"]["Password"]
    )
    return AppConfig(config["Name"], server_config, database_config)
end

function setup_service_context(config::AppConfig)::ServiceContext
    dbconfig = DBConfig(
        config.database.type,
        config.database.host,
        config.database.port,
        config.database.dbname,
        config.database.user,
        config.database.password
    )
    UserModel.DBCONFIG[] = dbconfig
    user_model_driver = UserModel.setup_model_driver(dbconfig)
    oxygencontext=Oxygen.CONTEXT[]
    SVCCONTEXT[]=ServiceContext(config, oxygencontext, user_model_driver)
end

function serve()
    host = SVCCONTEXT[].config.server.host
    port = SVCCONTEXT[].config.server.port
    Oxygen.serve(host=host, port=port, async=false, show_banner=false)
end

function RegisterHandlers()
    Oxygen.route([Oxygen.POST], "/user/login", UserLogin)
end

function UserLogin(request::HTTP.Request)
    # 先做反序列化得到UserLoginRequest
    userloginrequest = json(request, UserLoginRequest)
    
    # 如果需要才调用外部函数处理登录逻辑 否则，直接把logic写在这里就可以了。
    response = login(userloginrequest, SVCCONTEXT[])
    
    # 返回UserLoginResponse类型
    return UserLoginResponse(response.userid, response.loginname, response.token)
end

# 这个就是类似go-zero中的logic函数，如非必要不要这个单独的userlogic，直接在handler里写就很好了。
function login(userloginrequest::UserLoginRequest, svc_ctx::ServiceContext)::UserLoginResponse
    user = UserModel.find_one_by_loginname(userloginrequest.loginname, svc_ctx.user_model_driver)
    if user !== nothing && user.password == userloginrequest.password
        token = "some_generated_token"  # 生成一个令牌
        return UserLoginResponse(user.userid, user.loginname, token)
    else
        throw(HTTP.ErrorResponse(401, "Unauthorized"))
    end
end

end # module
