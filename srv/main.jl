#using Pkg
#Pkg.activate(".")
#Pkg.instantiate()

using FrontAPI
using YAML

const CONFIG_FILE = joinpath(@__DIR__, "..", "etc", "juliauser-api.yaml")

function load_config(filename)
    return YAML.load_file(filename)
end

function main()
    const config = load_config(CONFIG_FILE)
    FrontAPI.setupconfig(config)

    FrontAPI.setupserver(config)

    FrontAPI.setupservicecontext(config)
    FrontAPI.RegisterHandlers()

    println("Server will start at $host:$port...")
    FrontAPI.serve()
end

main()
