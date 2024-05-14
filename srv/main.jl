using .FrontAPI

function main()
    # 获取当前工作目录
    cwd = pwd()
    println("Current working directory:", cwd)
    
    # 解析命令行参数（如果有的话）
    # 注意：Julia 中的命令行参数解析可以使用 ArgParse.jl 或其他包，这里假设你已经处理了

    # 读取配置文件并初始化配置
    const CONFIG = FrontAPI.load_config("path/to/config.yaml")
    
    # 打印配置信息
    println("App Name: ", CONFIG.name)
    println("Server Host: ", CONFIG.server.host)
    println("Server Port: ", CONFIG.server.port)
    println("Database Type: ", CONFIG.database.type)
    println("Database Name: ", CONFIG.database.dbname)

    # 初始化ServiceContext并设置全局变量
    FrontAPI.SVCCONTEXT[] = FrontAPI.new_service_context(CONFIG)
    
    # 注册路由处理程序
    FrontAPI.RegisterHandlers()

    # 启动服务器
    println("Starting server at $(CONFIG.server.host):$(CONFIG.server.port)...")
    FrontAPI.serve()
end

main()
