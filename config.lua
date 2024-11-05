Config = {}
Config.locale = Locales["en"] -- en | es | fr | de | it | pt | ru| zh
Config.allowSavedConfigs = true

Config.neons = {
    command = false,
    commandName = "neons",
    item = true,
    itemName = "neons"
}

Config.needInstall = true -- Should neons be installed, if false then all cars can use neons without installing it
Config.installNeon = {
    command = false,
    commandName = "installneons",
    item = true,
    itemName = "neonkit",
    installTime = 3000,  -- how long it should take to install per corner
    drawDistance = 4.0,
    interactDistance = 1.5,
}

Config.mechanicOnly = {
    neonMenu = true, -- Can anyone access the neons menu or only mechanics | true = mechanic only
    installNeons = true, -- Can anyone install neons or only mechanics | true = mechanic only
    jobs = {-- List of jobs allowed
        "mechanic", 
        "another_job", 
        "yet_another_job",
    }
}
