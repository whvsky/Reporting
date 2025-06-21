Scully = {
    MenuKeybind = "f5", -- Set to "" to disable the keybind, you can find available keys here: https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard/
    HamzCadFeatures = false, -- Enable if you want the client side hamz cad features
    EnableShotSpotterAndGSR = true,
    EnableDisableDispatch = true,
    IgnoreWeapons = { -- Weapons to ignore with the shot spotter.
        `WEAPON_BZGAS`,
        `WEAPON_FLARE`,
        `WEAPON_STUNGUN`,
        `WEAPON_SNOWBALL`,
        `WEAPON_PETROLCAN`,
        `WEAPON_SMOKEGRENADE`,
        `WEAPON_FIREEXTINGUISHER`
    },
    DutyLoadout = true,
    DutyWeapons = { -- Weapons to give when going on duty.
        {
            weapon = `WEAPON_COMBATPISTOL`, -- Weapon names: (https://wiki.rage.mp/index.php?title=Weapons)
            ammo = 250,
            components = {
                `COMPONENT_AT_PI_FLSH` -- Weapon components: (https://wiki.rage.mp/index.php?title=Weapons_Components)
            }
        },
        {
            weapon = `WEAPON_PUMPSHOTGUN`,
            ammo = 250,
            components = {
                `COMPONENT_AT_AR_FLSH`
            }
        },
        {
            weapon = `WEAPON_CARBINERIFLE`,
            ammo = 250,
            components = {
                `COMPONENT_AT_AR_FLSH`,
                `COMPONENT_AT_SCOPE_MEDIUM`,
                `COMPONENT_AT_AR_AFGRIP`
            }
        },
        {
            weapon = `WEAPON_FLASHLIGHT`,
            ammo = 1,
            components = {}
        },
        {
            weapon = `WEAPON_STUNGUN`,
            ammo = 1,
            components = {}
        },
        {
            weapon = `WEAPON_NIGHTSTICK`,
            ammo = 1,
            components = {}
        }
    },
    EnablePrisonScene = true,
    TackleSystem = {
        enable = true,
        keybind = "g"
    },
    EnableDutyLocations = false, -- Enable if you want to use the duty locations below, this will make it so you need to do the below command instead.
    DutyCommand = "duty",
    DutyLocations = { -- Add more locations to sign on/off duty here, if they don't work then you added the locations wrong.
        {
            location = vector3(-450.07, 6011.41, 31.72), -- Paleto Bay, behind the reception desk.
            blip = {
                enable = true,
                title = "Law Enforcement",
                colour = 63,
                id = 60
            }
        },
    }
}