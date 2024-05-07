module FrontAPI
using Oxygen, HTTP
using StructTypes

mutable struct ServiceContext
    connection::LibPQ.Connection
    config::Dict{String, Any}
end

global SVCCONTEXT = nothing

#***********************************************************************
# 相当于go-zero中的 config 目录
#***********************************************************************
const CONFIG = Dict(
    "server" => Dict(
        "host" => "localhost",
        "port" => 8000
    ),
    "database" => Dict(
        "host" => "localhost",
        "port" => "5432",
        "dbname" => "ai4e-datacenter-postgres",
        "user" => "ai4e_datacenter",
        "password" => "dlgcdxlgjzdsys1234"
    )
)

#-----------------------------------------------------------------------
# 到此相当于 config 目录结束
#-----------------------------------------------------------------------

#***********************************************************************
# 相当于go-zero中的 models 目录
#***********************************************************************
include("UserModel.jl")
using .UserModel
#-----------------------------------------------------------------------
# 到此相当于 models 目录结束
#-----------------------------------------------------------------------


#***********************************************************************
# 相当于go-zero中的 svc 目录
#***********************************************************************
function setupconfig(config)
    # CONFIG["host"]=config["Host"]
    # CONFIG["port"]=config["Port"]
end

function setupserver(config)
    CONFIG["server"]["host"] = config["Host"]
    CONFIG["server"]["port"] = config["Port"]
end

function setupservicecontext(config)
    UserModel.DB_CONFIG["type"] = config["Database"]["Type"]
    UserModel.DB_CONFIG["host"] = config["Database"]["Host"]
    UserModel.DB_CONFIG["port"] = config["Database"]["Port"]
    UserModel.DB_CONFIG["dbname"] = config["Database"]["Dbname"]
    UserModel.DB_CONFIG["user"] = config["Database"]["User"]
    UserModel.DB_CONFIG["password"] = config["Database"]["Password"]

    connection = LibPQ.Connection("your connection string")
    config = Dict("host" => "localhost", "port" => 5432)
    global SVCCONTEXT = ServiceContext(connection, config)
end

function cleanup()
    close(SVCCONTEXT.connection)
    println("Resources cleaned up.")
end

#-----------------------------------------------------------------------
# 到此相当于 svc 目录结束
#-----------------------------------------------------------------------

#***********************************************************************
# 相当于go-zero中的 types 目录
#***********************************************************************
mutable struct UserLoginRequest
    loginname::String
    password::String
end

mutable struct UserLoginResponse
    userid::Int64
    loginname::String
    token::String
end

StructTypes.StructType(::Type{UserLoginRequest}) = StructTypes.Struct()
#-----------------------------------------------------------------------
# 到此相当于 types 目录结束
#-----------------------------------------------------------------------

#***********************************************************************
# 相当于go-zero中的 logic 目录
#***********************************************************************
function UserLoginLogic(userloginrequest)
    UserModel.FindOneByLoginRequest(userloginrequest)
    return "User logged in logic"
end
#-----------------------------------------------------------------------
# 到此相当于 logic 目录结束
#-----------------------------------------------------------------------

#***********************************************************************
# 相当于go-zero中的 routes 目录
#***********************************************************************
function UserLoginHandler(request::HTTP.Request)
    # 先做反序列化得到UserLoginRequest
    userloginrequest = json(request, UserLoginRequest)
    # 再调用UserLoginLogic处理登录逻辑
    UserLoginLogic(userloginrequest) #如果直接返回的就是UserLoginResponse类型，那就很OK了。会极大的简化代码

    #   userloginrequest
    #   dump(userloginrequest) 调试用，确保收到了userloginrequest

    # 然后返回UserLoginResponse类型
    return UserLoginResponse(1, "mingtaoli", "token")#先手动返回
end

function RegisterHandlers()
    Oxygen.route([Oxygen.POST], "/user/login", UserLoginHandler)
end
#-----------------------------------------------------------------------
# 到此相当于 routes 目录结束
#-----------------------------------------------------------------------

function serve()
    host = CONFIG["server"]["host"]
    port = CONFIG["server"]["port"]
    Oxygen.serve(host=host, port=port, async=false, show_banner=false)
end

end # module