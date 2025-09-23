local Config = lib.load('config')

local function DebugPrint(fmt, ...)
  if Config.Debug then
    print('[DEBUG]' .. string.format(fmt, ...))
  end
end

function loadframework()
  local frameworks = {
    { name = 'esx', resource = 'es_extended' },
    { name = 'qbx', resource = 'qbx_core' },
    { name = 'qb', resource = 'qb-core' }
  }

  for _, fw in ipairs(frameworks) do
    if GetResourceState(fw.resource) == 'started' then
      DebugPrint('Framework found: %s', fw.name)
      return fw.name
    end
  end

  DebugPrint('No framework detected')
end

local framework = loadframework()
local FrameworkObject = nil

if framework == 'esx' then
  DebugPrint('Loading ESX object')
  FrameworkObject = exports['es_extended']:getSharedObject()
elseif framework == 'qb' then
  DebugPrint('Loading QB-Core object')
  FrameworkObject = exports['qb-core']:GetCoreObject()
end

local speedMultiplier = Config.UseMPH and 2.23694 or 3.6
DebugPrint('Speed multiplier set to %.2f', speedMultiplier)

local function getStress()
  local val = LocalPlayer.state?.stress or 0
  DebugPrint('Current stress: %s', val)
  return val
end

local function isJobWhitelisted()
  if framework == 'esx' then
    local PlayerData = FrameworkObject.GetPlayerData()
    local currentJob = PlayerData?.job?.name
    DebugPrint('Job (esx): %s', currentJob)
    if not currentJob then return false end
    return lib.table.contains(Config.WhitelistedJobs, currentJob)
  elseif framework == 'qbx' then
    local PlayerData = exports.qbx_core:GetPlayerData()
    local currentJob = PlayerData?.job?.name
    DebugPrint('Job (qbx): %s', currentJob)
    if not currentJob then return false end
    return lib.table.contains(Config.WhitelistedJobs, currentJob)
  elseif framework == 'qb' then
    local PlayerData = FrameworkObject.Functions.GetPlayerData()
    local currentJob = PlayerData?.job?.name
    DebugPrint('Job (qb): %s', currentJob)
    if not currentJob then return false end
    return lib.table.contains(Config.WhitelistedJobs, currentJob)
  end
  DebugPrint('Job whitelist check failed, no framework matched')
  return false
end

local function gainStress(amount)
  if isJobWhitelisted() then
    DebugPrint('Skipped stress gain due to whitelist')
    return
  end

  local state = LocalPlayer.state
  if not state then
    DebugPrint('Player state not found')
    return
  end

  local newStress = getStress() + amount
  state:set('stress', newStress, true)
  DebugPrint('Stress increased by %s, new value: %s', amount, newStress)
  TriggerServerEvent('updateStress', newStress)
end

local function startVehicleStressThread()
  DebugPrint('Starting vehicle stress thread')
  CreateThread(function()
    Wait(1)
    while cache.vehicle do
      if not isJobWhitelisted() then
        local vehClass = GetVehicleClass(cache.vehicle)
        local speed = GetEntitySpeed(cache.vehicle) * speedMultiplier
        DebugPrint('Vehicle class: %s | Speed: %.2f', vehClass, speed)

        if vehClass ~= 13 and vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 and vehClass ~= 21 then
          local stressSpeed = vehClass == 8 and Config.Stress.minForSpeeding or (LocalPlayer.state?.seatbelt and Config.Stress.minForSpeeding or Config.Stress.minForSpeedingUnbuckled)
          if speed >= stressSpeed then
            DebugPrint('Speed exceeded threshold (%.2f), applying stress', stressSpeed)
            gainStress(math.random(1, 3))
          end
        end
      end
      Wait(1000)
    end
    DebugPrint('Exited vehicle stress loop')
  end)
end

lib.onCache('vehicle', function(vehicle)
  DebugPrint('Vehicle cache updated: %s', vehicle and tostring(vehicle) or 'nil')
  if not vehicle then return end
  startVehicleStressThread()
end)

CreateThread(function()
  if cache.vehicle then
    DebugPrint('Vehicle cache present at start, starting stress thread')
    startVehicleStressThread()
  end
end)

local function isWhitelistedWeaponStress(weapon)
  local result = lib.table.contains(Config.Stress.whitelistedWeapons, weapon)
  DebugPrint('Weapon whitelist check: %s -> %s', weapon, result)
  return result
end

local currentWeaponThread = nil

local function startWeaponStressThread(weapon)
  if currentWeaponThread then
    DebugPrint('Killing existing weapon stress thread')
    currentWeaponThread = nil
  end

  if isWhitelistedWeaponStress(weapon) then
    DebugPrint('Weapon %s is whitelisted, skipping thread', weapon)
    return
  end

  DebugPrint('Starting weapon stress thread for: %s', weapon)
  currentWeaponThread = CreateThread(function()
    local thisThread = currentWeaponThread
    Wait(1)
    while cache.weapon and thisThread == currentWeaponThread do
      if not isWhitelistedWeaponStress(cache.weapon) and IsPedShooting(cache.ped) and math.random() <= Config.Stress.chance then
        DebugPrint('Player shooting with non-whitelisted weapon: %s', cache.weapon)
        gainStress(math.random(1, 5))
      end
      Wait(0)
    end
    DebugPrint('Weapon stress thread exited')
  end)
end

lib.onCache('weapon', function(weapon)
  DebugPrint('Weapon cache updated: %s', weapon or 'nil')
  if not weapon then 
    currentWeaponThread = nil
    DebugPrint('Weapon cleared, killed weapon thread')
    return 
  end
  startWeaponStressThread(weapon)
end)

CreateThread(function()
  if cache.weapon then
    DebugPrint('Weapon cache present at start, starting weapon stress thread')
    startWeaponStressThread(cache.weapon)
  end
end)

local function getBlurIntensity(stresslevel)
  for _, v in pairs(Config.Stress.blurIntensity) do
    if lib.math.clamp(stresslevel, v.min, v.max) == stresslevel then
      DebugPrint('Blur intensity matched for stress %s: %s', stresslevel, v.intensity)
      return v.intensity
    end
  end
  DebugPrint('No blur match found for stress %s, defaulting', stresslevel)
  return 1500
end

local function getEffectInterval(stresslevel)
  for _, v in pairs(Config.Stress.effectInterval) do
    if lib.math.clamp(stresslevel, v.min, v.max) == stresslevel then
      DebugPrint('Effect interval matched for stress %s: %s', stresslevel, v.timeout)
      return v.timeout
    end
  end
  DebugPrint('No interval match found for stress %s, defaulting', stresslevel)
  return 60000
end

CreateThread(function()
  DebugPrint('Starting stress effects loop')
  while true do
    local stress = getStress()
    local effectInterval = getEffectInterval(stress)

    if not isJobWhitelisted() then
      if stress >= 100 then
        DebugPrint('Stress >= 100, triggering full effect')
        local blurIntensity = getBlurIntensity(stress)
        local fallRepeat = math.random(2, 4)
        local ragdollTimeout = fallRepeat * 1750

        TriggerScreenblurFadeIn(1000.0)
        Wait(blurIntensity)
        TriggerScreenblurFadeOut(1000.0)

        if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
          local forwardVector = GetEntityForwardVector(cache.ped)
          DebugPrint('Applying ragdoll fall effect')
          SetPedToRagdollWithFall(cache.ped, ragdollTimeout, ragdollTimeout, 1, forwardVector.x, forwardVector.y, forwardVector.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
        end

        Wait(1000)
        for _ = 1, fallRepeat do
          Wait(750)
          DoScreenFadeOut(200)
          Wait(1000)
          DoScreenFadeIn(200)
          TriggerScreenblurFadeIn(1000.0)
          Wait(blurIntensity)
          TriggerScreenblurFadeOut(1000.0)
        end

      elseif stress >= Config.Stress.minForShaking then
        DebugPrint('Stress >= %s, applying screen blur only', Config.Stress.minForShaking)
        local blurIntensity = getBlurIntensity(stress)
        TriggerScreenblurFadeIn(1000.0)
        Wait(blurIntensity)
        TriggerScreenblurFadeOut(1000.0)
      end
    else
      DebugPrint('Player is whitelisted, skipping visual effects')
    end

    Wait(effectInterval)
  end
end)

local function resetStress()
  DebugPrint('Resetting stress to 0')
  LocalPlayer.state:set('stress', 0, true)
end

local function SetStressLevel(amount)
  if amount < 0 then amount = 0 end
  if amount > 100 then amount = 100 end
  DebugPrint('Setting stress level to: %s', amount)
  LocalPlayer.state:set('stress', amount, true)
end


-- This will have to be use as exports['jg-stress-addon']:getStress
exports('getStress', getStress)
-- This will have to be use as exports['jg-stress-addon']:gainStress(amount)
exports('gainStress', gainStress)
-- This will have to be use as exports['jg-stress-addon']:isJobWhitelisted()
exports('isPlayerJobWhitelisted', isJobWhitelisted)
-- This will have to be use as exports['jg-stress-addon']:resetStress() 
exports('resetStress', resetStress)

-- This will have to be use as exports['jg-stress-addon']:setStressLevel(amount)
exports('setStressLevel', SetStressLevel)

-- THIS HAS NOT BEEN TESTED