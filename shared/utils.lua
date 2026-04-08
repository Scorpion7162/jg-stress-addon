local Config = lib.load('config.config')

function InitFramework()
    if GetResourceState('qbx_core') == 'started' then
        return 'qbx'
    elseif GetResourceState('qb-core') == 'started' then
        return 'qb'
    elseif GetResourceState('es_extended') == 'started' then
        return 'esx'
    else
        return ''
    end
end

function DebugPrint(fmt, ...)
    if Config.Debug then
        print('[DEBUG]' .. string.format(fmt, ...))
    end
end

function GetPlayer(src)
    local fw = InitFramework()
    if fw == 'qbx' then
        return exports.qbx_core:GetPlayer(src)
    elseif fw == 'qb' then
        return exports['qb-core']:GetPlayer(src)
    elseif fw == 'esx' then
        local ESX = exports.es_extended:getSharedObject()
        return ESX.GetPlayerFromId(src)
    else
        return nil
    end
end
