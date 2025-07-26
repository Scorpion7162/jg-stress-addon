local resetStress = false


local function DebugPrint(fmt, ...)
  if Config.Debug then
    lib.print.debug(string.format(fmt, ...))
  end
end


local function getStress(src)
  return Player(src)?.state?.stress or 0
end

local function getFramework()
  if GetResourceState('es_extended') == 'started' then
    DebugPrint('ESX started on server side')
    return 'esx'

  elseif GetResourceState('qbx_core') == 'started' then
    DebugPrint('Qbox started on server side')
    return 'qbx'
  elseif GetResourceState('qb-core') == 'started' then
    DebugPrint('QBCore started on server side')
    return 'qb'
  end
  return nil
end

local framework = getFramework()
local QBCore = nil

if framework == 'qb' then
  QBCore = exports['qb-core']:GetCoreObject()
  DebugPrint('GetCoreObject Loaded on server side')
end

local function loadPlayerStress(src)
  local stress = 0
  
  if framework == 'esx' then
    local xPlayer = exports.es_extended:getPlayerFromId(src)
    DebugPrint('Getting player from ID: (ESX)' .. src)
    if xPlayer then
      stress = xPlayer.get('stress') or 0
    end
  elseif framework == 'qbx' then
    local player = exports.qbx_core:GetPlayer(src)
    DebugPrint('Getting player from ID: (QBX)' .. src)
    if player then
      stress = player.PlayerData.metadata.stress or 0
    end
  elseif framework == 'qb' then
    local player = QBCore.Functions.GetPlayer(src)
    if player then
      stress = player.PlayerData.metadata.stress or 0
    end
  end
  
  Player(src).state:set('stress', stress, true)
  DebugPrint('Setting stress state for: ' .. src .. ' with stress lvl' .. stress )
  TriggerClientEvent('stress:setStress', src, stress)
end

local function savePlayerStress(src, stressValue)
  if framework == 'esx' then
    local xPlayer = exports.es_extended:getPlayerFromId(src)

    if xPlayer then
      xPlayer.set('stress', stressValue)
      DebugPrint('[ESX] Stress Value = ' .. stressValue )
    end
  elseif framework == 'qbx' then
    local player = exports.qbx_core:GetPlayer(src)
    if player then
      if not player.PlayerData.metadata then
        player.PlayerData.metadata = {}
      end
      player.PlayerData.metadata.stress = stressValue
      DebugPrint('[QBX] Stress Value = ' .. stressValue )
    end
  elseif framework == 'qb' then
    local player = QBCore.Functions.GetPlayer(src)
    if player then
      if not player.PlayerData.metadata then
        player.PlayerData.metadata = {}
      end
      player.PlayerData.metadata.stress = stressValue
      DebugPrint('[QB] Stress Value = ' .. stressValue )
    end
  end
end

RegisterNetEvent('stress:requestStress', function()
  loadPlayerStress(source)
end)

RegisterNetEvent('stress:updateStress', function(newStress)
  local src = source
  if not newStress then return end
  
  if newStress < 0 then newStress = 0 end
  if newStress > 100 then newStress = 100 end
  
  local player = Player(src)
  if not player then return end
  
  player.state:set('stress', newStress, true)
  savePlayerStress(src, newStress)
  DebugPrint(src .. 'Newstress = ' .. newStress)
end)

RegisterNetEvent('updateStress', function(newStress)
  local src = source
  if not newStress then return end
  
  if newStress < 0 then newStress = 0 end
  if newStress > 100 then newStress = 100 end
  
  local player = Player(src)
  if not player then return end
  
  player.state:set('stress', newStress, true)
  savePlayerStress(src, newStress)
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
  savePlayerStress(src, newStress)
end)

AddEventHandler('QBCore:Server:PlayerLoaded', function(Player)
  loadPlayerStress(Player.PlayerData.source)
end)

AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
  loadPlayerStress(playerId)
end)