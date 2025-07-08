local speedMultiplier = Config.UseMPH and 2.23694 or 3.6
local function getStress()
  return LocalPlayer.state?.stress or 0
end
local function gainStress(amount)
  local state = LocalPlayer.state
  if not state then return end
  state:set("stress", getStress() + amount, true)
end

-- Stress from speeding
local function startVehicleStressThread()
  CreateThread(function()
    Wait(1)
    while cache.vehicle do
      local vehClass = GetVehicleClass(cache.vehicle)
      local speed = GetEntitySpeed(cache.vehicle) * speedMultiplier
      if vehClass ~= 13 and vehClass ~= 14 and vehClass ~= 15 and vehClass ~= 16 and vehClass ~= 21 then
        local stressSpeed
        if vehClass == 8 then
          stressSpeed = Config.Stress.minForSpeeding
        else
          stressSpeed = LocalPlayer.state?.seatbelt and Config.Stress.minForSpeeding or Config.Stress.minForSpeedingUnbuckled
        end
        if speed >= stressSpeed then
          gainStress(math.random(1, 3))
        end
      end
      Wait(10000)
    end
  end)
end
lib.onCache("vehicle", function(vehicle)
  if not vehicle then return end
  startVehicleStressThread()
end)
CreateThread(function()
  if cache.vehicle then
    startVehicleStressThread()
  end
end)
local function isWhitelistedWeaponStress(weapon)
  if weapon then
    for _, v in pairs(Config.Stress.whitelistedWeapons) do
      if weapon == v then
        return true
      end
    end
  end
  
  return false
end


-- Stress from weapons
local function startWeaponStressThread(weapon)
  if isWhitelistedWeaponStress(weapon) then return end
  CreateThread(function()
    Wait(1)
    while cache.weapon do
      if IsPedShooting(cache.ped) then
        if math.random() <= Config.Stress.chance then
          gainStress(math.random(1, 5))
        end
      end
      Wait(0)
    end
  end)
end

lib.onCache("weapon", function(weapon)
  if not weapon then return end
  startWeaponStressThread(weapon)
end)
CreateThread(function()
  if cache.weapon then
    startWeaponStressThread(cache.weapon)
  end
end)

local function getBlurIntensity(stresslevel)
  for _, v in pairs(Config.Stress.blurIntensity) do
    if stresslevel >= v.min and stresslevel <= v.max then
      return v.intensity
    end
  end
  return 1500
end

local function getEffectInterval(stresslevel)
  for _, v in pairs(Config.Stress.effectInterval) do
    if stresslevel >= v.min and stresslevel <= v.max then
      return v.timeout
    end
  end
  return 60000
end

CreateThread(function()
  while true do
    local stress = getStress()
    local effectInterval = getEffectInterval(stress)
    if stress >= 100 then
      local blurIntensity = getBlurIntensity(stress)
      local fallRepeat = math.random(2, 4)
      local ragdollTimeout = fallRepeat * 1750
      TriggerScreenblurFadeIn(1000.0)
      Wait(blurIntensity)
      TriggerScreenblurFadeOut(1000.0)
      if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
        local forwardVector = GetEntityForwardVector(cache.ped)
        SetPedToRagdollWithFall(cache.ped, ragdollTimeout, ragdollTimeout, 1, forwardVector.x, forwardVector.y, forwardVector.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
      end
      Wait(1000)
      for _ = 1, fallRepeat, 1 do
        Wait(750)
        DoScreenFadeOut(200)
        Wait(1000)
        DoScreenFadeIn(200)
        TriggerScreenblurFadeIn(1000.0)
        Wait(blurIntensity)
        TriggerScreenblurFadeOut(1000.0)
      end
    elseif stress >= Config.Stress.minForShaking then
      local blurIntensity = getBlurIntensity(stress)
      TriggerScreenblurFadeIn(1000.0)
      Wait(blurIntensity)
      TriggerScreenblurFadeOut(1000.0)
    end
    Wait(effectInterval)
  end
end)