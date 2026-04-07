return function(gainStress, Config)
  local currentWeaponThread = nil

  local function isWeaponWhitelisted(weapon)
    local result = lib.table.contains(Config.Stress.whitelistedWeapons, weapon)
    DebugPrint('Weapon whitelist check: %s -> %s', weapon, result)
    return result
  end

  local function startWeaponStressThread(weapon)
    if currentWeaponThread then
      DebugPrint('Killing existing weapon stress thread')
      currentWeaponThread = nil
    end

    if isWeaponWhitelisted(weapon) then
      DebugPrint('Weapon %s is whitelisted, skipping thread', weapon)
      return
    end

    DebugPrint('Starting weapon stress thread for: %s', weapon)
    currentWeaponThread = CreateThread(function()
      local thisThread = currentWeaponThread
      Wait(1)
      while cache.weapon and thisThread == currentWeaponThread do
        if not isWeaponWhitelisted(cache.weapon) and IsPedShooting(cache.ped) and math.random() <= Config.Stress.chance then
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
end
