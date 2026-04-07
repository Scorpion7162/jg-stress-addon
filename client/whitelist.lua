return function(framework, FrameworkObject, Config)
  local whitelistedJobs = {}
  for _, job in ipairs(Config.WhitelistedJobs or {}) do
    whitelistedJobs[job] = true
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

  return { isJobWhitelisted = isJobWhitelisted }
end
