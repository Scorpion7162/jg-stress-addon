local resetStress = false
local Config = lib.load('config')
local framework = loadframework()

local function DebugPrint(fmt, ...)
  if Config.Debug then
    print('[DEBUG]' .. string.format(fmt, ...))
  end
end

if framework == 'esx' then
  DebugPrint('Loading ESX object')
  FrameworkObject = exports['es_extended']:getSharedObject()
elseif framework == 'qb' then
  DebugPrint('Loading QB-Core object')
  FrameworkObject = exports['qb-core']:GetCoreObject()
elseif framework == 'qbx' then
  DebugPrint('QBX detected, no framework object needed')
end
local function GetPlayerOnServer(src)
  if framework == 'esx' then
    return FrameworkObject.GetPlayerData()
  elseif framework == 'qb' then
    return FrameworkObject.Functions.GetPlayerData()
  elseif framework == 'qbx' then
    return exports.qbx_core:GetPlayerData()
  end
end

RegisterNetEvent('hud:server:GainStress', function(amount)
    local src = source
    local player = GetPlayerOnServer(src)
    local newStress
    
    if not player or (Config.stress.disableForLEO and player.PlayerData.job.type == 'leo') then return end
    if not resetStress then
      if not player.PlayerData.metadata.stress then
        player.PlayerData.metadata.stress = 0
      end
      newStress = player.PlayerData.metadata.stress + amount
      if newStress <= 0 then newStress = 0 end
    else
      newStress = 0
    end
    if newStress > 100 then
      newStress = 100
    end

    Player(src)?.state:set('stress', newStress, true)
end)

local function getStress(src)
  return Player(src)?.state?.stress or 0
end

RegisterNetEvent('updateStress', function(newStress)
  local src = source
  if not newStress then return end
  
  if newStress < 0 then newStress = 0 end
  if newStress > 100 then newStress = 100 end
  
  local player = Player(src)
  if not player then return end
  
  player.state:set('stress', newStress, true)
end)

RegisterNetEvent('hud:server:RelieveStress', function(amount)
  local src = source
  local stress = getStress(src)
  local newStress

  if not resetStress then
    if not stress then
      stress = 0
    end
    newStress = stress - amount
    if newStress <= 0 then newStress = 0 end
  else
    newStress = 0
  end
  if newStress > 100 then
    newStress = 100
  end
  
  Player(src).state:set('stress', newStress, true)
  -- exports.qbx_core:Notify(src, locale('notify.stress_removed'), 'inform', 2500, nil, nil, {'#141517', '#ffffff'}, 'brain', '#0F52BA')
end)
