Config = {}
Config.allowSavedConfigs = false

Config.neons = {
    command = true,
    commandName = "neons",
    item = false,
    itemName = "neons"
}

Config.needInstall = true -- should neons be installed, if false then all cars can use neons without mechanic installing it
Config.installNeon = {
    command = true,
    commandName = "installneons",
    item = false,
    itemName = "neonKit"
}

Config.mechanicOnly = {
    neonMenu = false,
    installNeons = false,
    jobs = {-- List of jobs allowed
        "mechanic", 
        "another_job", 
        "yet_another_job"
    }
}
