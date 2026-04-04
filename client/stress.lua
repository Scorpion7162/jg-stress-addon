return function(isJobWhitelisted, Config)
  local function getStress()
    local val = LocalPlayer.state?.stress or 0
    DebugPrint('Current stress: %s', val)
    return val
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

  local function resetStress()
    DebugPrint('Resetting stress to 0')
    LocalPlayer.state:set('stress', 0, true)
  end

  local function setStressLevel(amount)
    amount = math.max(0, math.min(100, amount))
    DebugPrint('Setting stress level to: %s', amount)
    LocalPlayer.state:set('stress', amount, true)
  end

  return {
    getStress      = getStress,
    gainStress     = gainStress,
    resetStress    = resetStress,
    setStressLevel = setStressLevel,
  }
end
