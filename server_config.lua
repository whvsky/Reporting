Scully = {
    HamzCad = {
        enable = false, -- Enable if you use hamz cad
        url = "https://domain.com", -- The url to your cad.
        secret = "apitest123", -- Your cads "secret" to send info using the api.
        callPanel = true, -- Keep this enabled if you have CALLPANEL911 set to 1 in your Hamz Cad config.php.
        Webhook = "paste webhook here" -- Your discord webhook for CAD logs.
    },
    DutyBlips = {
        enable = true,
        updateInterval = 3000 -- Recommended that you don't change.
    },
    InteractSound = false, -- Enable if you use interact sound, this will play sounds when cuffed. (https://github.com/plunkettscott/interact-sound)
    Webhooks = { -- Your discord webhooks for LEO logs
        Duty = "",
        Cuff = "",
        Tackle = "",
        Drag = "",
        Jail = "",
        Vehicle = "",
    }
}