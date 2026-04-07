return function(getStress, isJobWhitelisted, Config)
  local function getBlurIntensity(stresslevel)
    for _, v in pairs(Config.Stress.blurIntensity) do
      if lib.math.clamp(stresslevel, v.min, v.max) == stresslevel then
        DebugPrint('Blur intensity matched for stress %s: %s', stresslevel, v.intensity)
        return v.intensity
      end
    end
    DebugPrint('No blur match found for stress %s, defaulting', stresslevel)
    return 1500
  end

  local function getEffectInterval(stresslevel)
    for _, v in pairs(Config.Stress.effectInterval) do
      if lib.math.clamp(stresslevel, v.min, v.max) == stresslevel then
        DebugPrint('Effect interval matched for stress %s: %s', stresslevel, v.timeout)
        return v.timeout
      end
    end
    DebugPrint('No interval match found for stress %s, defaulting', stresslevel)
    return 60000
  end

  local function applyFullStressEffect(blurIntensity)
    local fallRepeat    = math.random(2, 4)
    local ragdollTimeout = fallRepeat * 1750

    TriggerScreenblurFadeIn(1000.0)
    Wait(blurIntensity)
    TriggerScreenblurFadeOut(1000.0)

    if not IsPedRagdoll(cache.ped) and IsPedOnFoot(cache.ped) and not IsPedSwimming(cache.ped) then
      local fwd = GetEntityForwardVector(cache.ped)
      DebugPrint('Applying ragdoll fall effect')
      SetPedToRagdollWithFall(cache.ped, ragdollTimeout, ragdollTimeout, 1, fwd.x, fwd.y, fwd.z, 1.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0)
    end

    Wait(1000)
    for _ = 1, fallRepeat do
      Wait(750)
      DoScreenFadeOut(200)
      Wait(1000)
      DoScreenFadeIn(200)
      TriggerScreenblurFadeIn(1000.0)
      Wait(blurIntensity)
      TriggerScreenblurFadeOut(1000.0)
    end
  end

  local function applyBlurEffect(blurIntensity)
    TriggerScreenblurFadeIn(1000.0)
    Wait(blurIntensity)
    TriggerScreenblurFadeOut(1000.0)
  end

  CreateThread(function()
    DebugPrint('Starting stress effects loop')
    while true do
      local stress         = getStress()
      local effectInterval = getEffectInterval(stress)

      if not isJobWhitelisted() then
        local blurIntensity = getBlurIntensity(stress)
        if stress >= 100 then
          DebugPrint('Stress >= 100, triggering full effect')
          applyFullStressEffect(blurIntensity)
        elseif stress >= Config.Stress.minForShaking then
          DebugPrint('Stress >= %s, applying screen blur only', Config.Stress.minForShaking)
          applyBlurEffect(blurIntensity)
        end
      else
        DebugPrint('Player is whitelisted, skipping visual effects')
      end

      Wait(effectInterval)
    end
  end)
end
