include("../src/FrontAPI.jl")
using .FrontAPI

function main()

    # 读取配置文件并初始化配置
    const CONFIG = FrontAPI.load_config(joinpath(@__DIR__, "..", "etc", "front-api.yaml"))
 
    println("App Name: ", CONFIG.name)
    println("Server Host: ", CONFIG.server.host)
    println("Server Port: ", CONFIG.server.port)
    println("Database Type: ", CONFIG.database.type)
    println("Database Name: ", CONFIG.database.dbname)

    # 初始化ServiceContext并设置全局变量
    FrontAPI.setup_service_context(CONFIG)
    
    # 注册路由处理程序
    FrontAPI.RegisterHandlers()

    # 启动服务器
    println("Starting server at $(CONFIG.server.host):$(CONFIG.server.port)...")
    FrontAPI.serve()
end

main()
