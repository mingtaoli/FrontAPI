#using Pkg
#Pkg.activate(".")
#Pkg.instantiate()

using FrontAPI
using YAML

const CONFIG_FILE = joinpath(@__DIR__, "..", "etc", "front-api.yaml")




function main()
    config = YAML.load_file(CONFIG_FILE)
    FrontAPI.setupconfig(config)

    FrontAPI.setupserver(config)

    FrontAPI.setupservicecontext(config)
    FrontAPI.RegisterHandlers()
    host = config["Host"]
    port = config["Port"]
    println("Server will start at $host:$port...")
    FrontAPI.serve()
end

main()
