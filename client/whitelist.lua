return function(framework, FrameworkObject, Config)
  local function getPlayerData()
    if framework == 'esx' and FrameworkObject then
      return FrameworkObject.GetPlayerData()
    elseif framework == 'qbx' then
      return exports.qbx_core:GetPlayerData()
    elseif framework == 'qb' and FrameworkObject then
      return FrameworkObject.Functions.GetPlayerData()
    end
  end

  local function isJobWhitelisted()
    local PlayerData = getPlayerData()
    local currentJob = PlayerData?.job?.name
    DebugPrint('Job (%s): %s', framework, currentJob)
    if not currentJob then return false end
    return lib.table.contains(Config.WhitelistedJobs, currentJob)
  end

  return { isJobWhitelisted = isJobWhitelisted }
end
