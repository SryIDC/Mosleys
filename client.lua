local civilianPeds = {
    "a_m_m_afriamer_01",
    "a_m_m_beach_01",
    "a_m_m_bevhills_01",
    "a_m_m_bevhills_02",
    "a_m_m_business_01",
    "a_m_m_eastsa_01",
    "a_m_m_eastsa_02",
    "a_m_m_farmer_01",
    "a_m_m_fatlatin_01",
    "a_m_m_genfat_01",
    "a_m_m_genfat_02",
    "a_m_m_golfer_01",
    "a_m_m_hasjew_01",
    "a_m_m_hillbilly_01",
    "a_m_m_hillbilly_02",
    "a_m_m_indian_01",
    "a_m_m_ktown_01",
    "a_m_m_malibu_01",
    "a_m_m_mexcntry_01",
    "a_m_m_mexlabor_01",
    "a_m_m_og_boss_01",
    "a_m_m_paparazzi_01",
    "a_m_m_polynesian_01",
    "a_m_m_prolhost_01",
    "a_m_m_rurmeth_01",
    "a_m_m_salton_01",
    "a_m_m_salton_02",
    "a_m_m_salton_03",
    "a_m_m_salton_04",
    "a_m_m_skater_01",
    "a_m_m_skidrow_01",
    "a_m_m_socenlat_01",
    "a_m_m_soucent_01",
    "a_m_m_soucent_02",
    "a_m_m_soucent_03",
    "a_m_m_soucent_04",
    "a_m_m_stlat_02",
    "a_m_m_tennis_01",
    "a_m_m_tourist_01",
    "a_m_m_tramp_01",
    "a_m_m_trampbeac_01",
    "a_f_m_beach_01",
    "a_f_m_bevhills_01",
    "a_f_m_bevhills_02",
    "a_f_m_bodybuild_01",
    "a_f_m_business_02",
    "a_f_m_downtown_01",
    "a_f_m_eastsa_01",
    "a_f_m_eastsa_02",
    "a_f_m_fatbla_01",
    "a_f_m_fatcult_01",
    "a_f_m_fatwhite_01",
    "a_f_m_ktown_01",
    "a_f_m_ktown_02",
    "a_f_m_prolhost_01",
    "a_f_m_salton_01",
    "a_f_m_skidrow_01",
    "a_f_m_soucentmc_01",
    "a_f_m_tourist_01",
    "a_f_m_tramp_01",
    "a_f_m_trampbeac_01",
}

local VehModels = {
    "tailgater",
    "asea",
    "emperor",
    "fugitive",
    "intruder",
    "premier",
    "primo",
    "regina",
    "stanier",
    "stratum",
    "warrener",
    "washington",
    "baller",
    "cavalcade",
    "contender",
    "fq2",
    "granger",
    "gresley",
    "habanero",
    "huntley",
    "landstalker",
    "patriot",
    "radi",
    "rocoto",
    "seminole",
    "xls",
    "sultan",
    "schafter2",
    "f620",
    "fugitive",
    "jackal",
    "tailgater2",
    "exemplar",
    "zion2",
    "oracle",
    "oracle2",
    "sentinel2",
    "brawler",
    "dubsta",
    "rebel",
    "kalahari",
    "mesa",
    "sadler",
    "rancherxl",
    "bison",
    "riata",
}


local Ped, CusPed, jobvehicle, cspawn, mosleysBlip, JobStart, PJob, jobped
local onJob, fixed, Job, Frozen, jobpedmodel = false, 0, nil, false, nil

CreateThread(function()
    JobPed()
end)

function JobPed()
    local ped = Config.Ped
    local spawn = ped.Spawn
    lib.requestModel(ped.Model, 5000)
    local hash = GetHashKey(ped.Model)
    Ped = CreatePed("PED_TYPE_CIVMALE", hash, spawn.x, spawn.y, spawn.z - 0.98, spawn.w, false, false)
    TaskSetBlockingOfNonTemporaryEvents(Ped, true)
    FreezeEntityPosition(Ped, true)
    SetEntityInvincible(Ped, true)

    jobped = AddBlipForEntity(Ped)
    SetBlipSprite(jobped, 78)
    SetBlipDisplay(jobped, 6)
    SetBlipScale(jobped, 0.8)
    SetBlipColour(jobped, 28)
    SetBlipAsShortRange(jobped, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Mosleys Job")
    EndTextCommandSetBlipName(jobped)

    exports.ox_target:addLocalEntity(Ped, {
        {
            label = "Request job",
            icon = "fa-solid fa-person",
            canInteract = function()
                if not onJob then return true end
            end,
            onSelect = function()
                local waittime = math.random(Config.WaitTime.min*1000, Config.WaitTime.max*1000)
                exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Waiting for job offer' })
                Wait(waittime)
                exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Go to the customer' })
                StartJob()
            end
        }
    })
end

function SpawnPed(type)
    lib.requestModel(jobpedmodel, 5000)
    local hash = GetHashKey(jobpedmodel)
    local vspawn = PJob.VehicleSpawn
    local randveh = math.random(1, #VehModels)
    local vehmodel = VehModels[randveh]
    lib.requestModel(vehmodel, 5000)
    CusPed = CreatePed("PED_TYPE_MISSION", hash, cspawn.x, cspawn.y, cspawn.z, cspawn.w, false, false)
    TaskSetBlockingOfNonTemporaryEvents(CusPed, true)
    SetEntityInvincible(CusPed, true)

    if type == "collect" then
        exports.ox_target:addLocalEntity(CusPed, {
            {
                label = "Inspect vehicle",
                icon = "fa-solid fa-car",
                name = "mosleys:collect",
                onSelect = function()
                    if DoesBlipExist(JobStart) then
                        RemoveBlip(JobStart)
                    end
                    local net = lib.callback.await('mosleys:server:SpawnJobVeh', false, vehmodel, vspawn)
                    jobvehicle = NetToVeh(net)
                    DamageVehicle()
                    exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = "Go back to Mosley's and fix the broken vehicle!" })
                    mosleysBlip = CreateRoute(Config.Fix, "Mosleys")
                    exports.ox_target:removeLocalEntity(CusPed, "mosleys:collect")
                    FixJob()
                    if DoesEntityExist(CusPed) then
                        Wait(20000)
                        DeleteEntity(CusPed)
                    end
                end
            }
        })
    elseif type == "deliver" then
        exports.ox_target:addLocalEntity(CusPed, {
            {
                label = "Deliver Vehicle",
                icon = "fa-solid fa-car",
                name = "mosleys:deliver",
                onSelect = function()
                    if DoesBlipExist(delBlip) then
                        RemoveBlip(delBlip)
                    end
                    if DoesEntityExist(jobvehicle) then
                        TaskEnterVehicle(CusPed, jobvehicle, 5000, 0, 2.0, 1, 0)
                        TaskVehicleDriveWander(CusPed, jobvehicle, 80 / 3.6, 0)
                        SetModelAsNoLongerNeeded(CusPed)
                        SetModelAsNoLongerNeeded(jobvehicle)
                    end
                    onJob = false
                    local reward = math.random(Config.Payment.min, Config.Payment.max)
                    TriggerServerEvent("mosleys:server:reward", reward)
                    CusPed = nil
                    jobvehicle = nil
                    exports.ox_target:removeLocalEntity(CusPed, "mosleys:deliver")
                    exports.lunar_bridge:hideTextUI()
                    ResetJob()

                end
            }
        })
    end
end

function StartJob()
    onJob = true
    local Jobs = Config.Job
    Job = math.random(1, #Jobs)
    PJob = Jobs[Job]
    cspawn = Jobs[Job].PedSpawn
    JobStart = CreateRoute(cspawn, "Customer")
    local modelr = math.random(1, #civilianPeds)
    jobpedmodel = civilianPeds[modelr]

    local playerCoords = GetEntityCoords(cache.ped)
    if #(playerCoords - vector3(cspawn.x, cspawn.y, cspawn.z)) > 200 then
        Wait(1000)
        SpawnPed("collect")
        return
    end
end

function FixJob()
    FixZone = lib.zones.box({
        coords = Config.Fix,
        size = vec3(14.0, 14.0, 10),
        rotation = 315.0,
        onEnter = function()
            if not Frozen then
                FreezeEntityPosition(jobvehicle, true)
                TaskLeaveVehicle(cache.ped, cache.vehicle, 0)
                if DoesBlipExist(mosleysBlip) then
                    RemoveBlip(mosleysBlip)
                end
                FixVehicle()
                lib.notify({ description = "Fix the vehicle!" })
                Frozen = true
            end
        end,
        onExit = function()
            if cache.vehicle then
                FixZone:remove()
            end
        end
    })
end

function FunctionFix()
    SetEntityHealth(jobvehicle, 1000)
    SetVehicleEngineHealth(jobvehicle, 1000.0)
    SetVehicleBodyHealth(jobvehicle, 1000.0)
    SetVehicleFixed(jobvehicle)
    SetVehicleDeformationFixed(jobvehicle)
end

function FixVehicle()
    lib.requestAnimDict("amb@world_human_hammering@male@base", 5000)
    if fixed < 4 then
        exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Install Part '.. fixed .. '/8' })
        exports.ox_target:addLocalEntity(jobvehicle, {
            {
                label = "Fix door",
                name = "mosleys:door",
                icon = "fa-solid fa-wrench",
                onSelect = function()
                    local item = exports.ox_inventory:Search('count', "mosleysdoor")
                    if item > 0 then
                        TriggerServerEvent("mosleys:server:removeItem", "mosleysdoor")
                        if lib.progressBar({
                                duration = 10000,
                                label = "Fixing door",
                                anim = {
                                    dict = "amb@world_human_hammering@male@base",
                                    clip = "base",
                                },
                                prop = {
                                    model = 4167227990,
                                    bone = 57005,
                                    pos = { x = 0.1, y = 0.0, z = 0.0 },
                                    rot = { x = 90.0, y = 0.0, z = 90.0 }
                                },
                                disable = {
                                    move = true,
                                    car = true
                                },
                            }) then
                            SetVehicleDoorBroken(jobvehicle, fixed, false)
                            fixed = fixed + 1
                            exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Install Part '.. fixed .. '/8' })
                            exports.ox_target:removeLocalEntity(jobvehicle, "mosleys:door")
                            lib.notify({ description = "Vehicle door repair completed. Move to the next repair!" })
                            FixVehicle()
                        end
                    else
                        lib.notify({
                            description = "You don't have a door. Go buy from Mosley's supplies!",
                            type =
                            "error"
                        })
                    end
                end
            }
        })
    elseif fixed == 4 or fixed == 5 then
        exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Install Part '.. fixed+1 .. '/8' })
        exports.ox_target:addLocalEntity(jobvehicle, {
            {
                label = "Fix window",
                name = "mosleys:sidemirror",
                icon = "fa-solid fa-wrench",
                onSelect = function()
                    local item = exports.ox_inventory:Search('count', "mosleysmirror")
                    if item > 0 then
                        TriggerServerEvent("mosleys:server:removeItem", "mosleysmirror")
                        if lib.progressBar({
                                duration = 10000,
                                label = "Fixing side mirror",
                                anim = {
                                    dict = "amb@world_human_welding@male@base",
                                    clip = "base",
                                },
                                prop = {
                                    model = 3284676632,
                                    bone = 57005,
                                    pos = { x = 0.1, y = 0.0, z = 0.0 },
                                    rot = { x = 90.0, y = 0.0, z = 0.0 }
                                },
                                disable = {
                                    move = true,
                                    car = true
                                },
                            }) then
                            fixed = fixed + 1
                            exports.ox_target:removeLocalEntity(jobvehicle, "mosleys:sidemirror")
                            lib.notify({ description = "Side mirror repair completed. Move to the next repair!" })
                            FixVehicle()
                        end
                    else
                        lib.notify({
                            description = "You don't have a mirror. Go buy from Mosley's supplies!",
                            type =
                            "error"
                        })
                    end
                end
            }
        })
    elseif fixed == 6 then
        exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Install Part '.. fixed+1 .. '/8' })
        exports.ox_target:addLocalEntity(jobvehicle, {
            {
                label = "Fix horn",
                name = "mosleys:horn",
                icon = "fa-solid fa-wrench",
                onSelect = function()
                    local item = exports.ox_inventory:Search('count', "mosleyshorn")
                    if item > 0 then
                        TriggerServerEvent("mosleys:server:removeItem", "mosleyshorn")
                        if lib.progressBar({
                                duration = 10000,
                                label = "Fixing vehicle horn",
                                anim = {
                                    dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                    clip = "machinic_loop_mechandplayer",
                                },
                                disable = {
                                    combat = true,
                                    move = true,
                                    car = true
                                },
                            }) then
                            fixed = fixed + 1
                            exports.ox_target:removeLocalEntity(jobvehicle, "mosleys:horn")
                            lib.notify({ description = "Horn repair completed. Move to the next repair!" })
                            FixVehicle()
                        end
                    else
                        lib.notify({ description = "You don't have horn. Go buy from Mosley's supplies!", type = "error" })
                    end
                end
            }
        })
    elseif fixed == 7 then
        exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Repaint Vehicle'})
        exports.ox_target:addLocalEntity(jobvehicle, {
            {
                label = "Repaint vehicle",
                name = "mosleys:repaint",
                icon = "fa-solid fa-paint-roller",
                onSelect = function()
                    local item = exports.ox_inventory:Search('count', "mosleyspaint")
                    if item > 0 then
                        TriggerServerEvent("mosleys:server:removeItem", "mosleyspaint")
                        if lib.progressBar({
                                duration = 10000,
                                label = "Repainting Vehicle...",
                                anim = {
                                    dict = "anim@amb@clubhouse@tutorial@bkr_tut_ig3@",
                                    clip = "machinic_loop_mechandplayer",
                                },
                                disable = {
                                    move = true,
                                    car = true
                                }
                            }) then
                            local color = math.random(1, 30)
                            SetVehicleColours(jobvehicle, color, color)
                            fixed = fixed + 1
                            exports.ox_target:removeLocalEntity(jobvehicle, "mosleys:repaint")
                            lib.notify({ description = "Repainted vehicle!" })
                            FixVehicle()
                        end
                    else
                        lib.notify({
                            description = "You don't have a paint. Go buy from Mosley's supplies!",
                            type =
                            "error"
                        })
                    end
                end
            }
        })
    elseif fixed == 8 then
        exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Fix vehicle engine.' })
        exports.ox_target:addLocalEntity(jobvehicle, {
            {
                label = "Fix vehicle engine",
                name = "mosleys:engine",
                icon = "fa-solid fa-car-battery",
                onSelect = function()
                    if lib.progressBar({
                            duration = 10000,
                            label = "Fixing vehicle engine...",
                            anim = {
                                dict = "mini@repair",
                                clip = "fixing_a_ped",
                            },
                            disable = {
                                combat = true,
                                move = true,
                                car = true
                            }
                        }) then
                        fixed = fixed + 1
                        exports.ox_target:removeLocalEntity(jobvehicle, "mosleys:engine")
                        lib.notify({ description = "Fixed vehicle engine!" })
                        FunctionFix()
                        FixVehicle()
                    end
                end
            }
        })
    elseif fixed == 9 then
        exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = 'Clean vehicle.' })
        exports.ox_target:addLocalEntity(jobvehicle, {
            {
                label = "Clean vehicle",
                name = "mosleys:clean",
                icon = "fa-solid fa-soap",
                onSelect = function()
                    lib.requestAnimDict("timetable@floyd@clean_kitchen@base", 5000)
                    if lib.progressBar({
                            duration = 10000,
                            label = "Cleaning Vehicle...",
                            anim = {
                                dict = "timetable@floyd@clean_kitchen@base",
                                clip = "base",
                            },
                            prop = {
                                model = "prop_sponge_01",
                                bone = 28422,
                                pos = { x = 0.0, y = 0.0, z = -0.1 },
                                rot = { x = 90.0, y = 0.0, z = 0.0 }
                            },
                            disable = {
                                move = true,
                                car = true
                            }
                        }) then
                        fixed = 0
                        exports.ox_target:removeLocalEntity(jobvehicle, "mosleys:clean")
                        lib.notify({ description = "Cleaned vehicle!" })
                        SetVehicleDirtLevel(jobvehicle, 0)
                        DeliverVehicle()
                    end
                end
            }
        })
    end
end

function DamageVehicle()
    SetEntityHealth(jobvehicle, 500)
    SetVehicleEngineHealth(jobvehicle, 300.0)
    SetVehicleBodyHealth(jobvehicle, 300.0)

    SetVehicleDoorBroken(jobvehicle, 0, true)
    SetVehicleDoorBroken(jobvehicle, 1, true)
    SetVehicleDoorBroken(jobvehicle, 2, true)
    SetVehicleDoorBroken(jobvehicle, 3, true)
    SetVehicleDoorBroken(jobvehicle, 4, true)

    SetVehicleDeformationFixed(jobvehicle)
    SetVehicleDamage(jobvehicle, 0.3, 0.3, 0.0, 200.0, 500.0, true)
    SetVehicleDamage(jobvehicle, -0.5, -0.5, 0.0, 200.0, 500.0, true)
end

function DeliverVehicle()
    exports.lunar_bridge:showTextUI({ title = 'Mosleys', description = "Deliver the vehicle to the custmer!" })
    FreezeEntityPosition(jobvehicle, false)

    delBlip = CreateRoute(cspawn, "Customer")
    local playerCoords = GetEntityCoords(cache.ped)
    if #(playerCoords - vector3(cspawn.x, cspawn.y, cspawn.z)) > 200 then
        Wait(1000)
        SpawnPed("deliver")
        return
    end
end

function ResetJob()
    if DoesEntityExist(CusPed) then
        DeleteEntity(CusPed)
    end
    if DoesBlipExist(delBlip) then
        RemoveBlip(delBlip)
    end
    if DoesBlipExist(mosleysBlip) then
        RemoveBlip(mosleysBlip)
    end
    if DoesEntityExist(jobvehicle) then
        DeleteVehicle(jobvehicle)
    end
    Frozen = false
    Fixed = 0
    jobpedmodel = nil
end

function CreateRoute(coords, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 66)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 66)
    return blip
end

AddEventHandler("onResourceStop", function()
    if DoesEntityExist(Ped) then
        DeleteEntity(Ped)
    end
    if DoesBlipExist(jobped) then
        RemoveBlip(jobped)
    end
    ResetJob()
    exports.lunar_bridge:hideTextUI()
end)