local Config = lib.require('config')

local framework = InitFramework()
local FrameworkObject

if framework == 'esx' then
  DebugPrint('Loading ESX object')
  FrameworkObject = exports['es_extended']:getSharedObject()
elseif framework == 'qb' then
  DebugPrint('Loading QB-Core object')
  FrameworkObject = exports['qb-core']:GetCoreObject()
end

local speedMultiplier = Config.UseMPH and 2.23694 or 3.6
DebugPrint('Speed multiplier set to %.2f', speedMultiplier)

local Whitelist = lib.load('client/whitelist')(framework, FrameworkObject, Config)
local Stress    = lib.load('client/stress')(Whitelist.isJobWhitelisted, Config)

lib.load('client/vehicle')(Stress.gainStress, Whitelist.isJobWhitelisted, speedMultiplier, Config)
lib.load('client/weapon')(Stress.gainStress, Config)
lib.load('client/effects')(Stress.getStress, Whitelist.isJobWhitelisted, Config)

exports('getStress',              Stress.getStress)
exports('gainStress',             Stress.gainStress)
exports('isPlayerJobWhitelisted', Whitelist.isJobWhitelisted)
exports('resetStress',            Stress.resetStress)
exports('setStressLevel',         Stress.setStressLevel)
