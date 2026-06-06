return function(framework, FrameworkObject, Config)
  local whitelistedJobs = {}
  for _, job in ipairs(Config.WhitelistedJobs or {}) do
    whitelistedJobs[job] = true
  end

  local whitelistedVehicles = {}
  for _, model in ipairs(Config.WhitelistedVehicles or {}) do
    whitelistedVehicles[joaat(model)] = true
  end

  local function getPlayerData()
    if framework == 'esx' and FrameworkObject then
      return FrameworkObject.GetPlayerData()
    elseif framework == 'qbx' then
      return exports.qbx_core:GetPlayerData()
    elseif framework == 'qb' and FrameworkObject then
      return FrameworkObject.Functions.GetPlayerData()
    end
    DebugPrint('getPlayerData: no framework matched (framework=%s, FrameworkObject=%s)', framework, tostring(FrameworkObject))
  end

  local function isJobWhitelisted()
    if not next(whitelistedJobs) then return false end
    local PlayerData = getPlayerData()
    local currentJob = PlayerData?.job?.name
    DebugPrint('Job (%s): %s', framework, tostring(currentJob))
    if not currentJob then return false end
    return whitelistedJobs[currentJob] == true
  end

  local function isVehicleWhitelisted(vehicle)
    if not next(whitelistedVehicles) then return false end
    vehicle = vehicle or cache.vehicle
    if not vehicle or vehicle == 0 then return false end
    local result = whitelistedVehicles[GetEntityModel(vehicle)] == true
    DebugPrint('Vehicle whitelist check (%s): %s', vehicle, result)
    return result
  end

  return {
    isJobWhitelisted     = isJobWhitelisted,
    isVehicleWhitelisted = isVehicleWhitelisted,
  }
end
