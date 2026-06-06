local Config = lib.require('config.config')

local MPH_MULTIPLIER = 2.23694
local KPH_MULTIPLIER = 3.6
local VEHICLE_CLASS_MOTORCYCLE = 8
local STRESS_GAIN_MIN = 1
local STRESS_GAIN_MAX = 3
-- Vehicle classes that never cause driving stress: cycles, boats, helicopters, planes, trains.
local NO_STRESS_VEHICLE_CLASSES = {
  [13] = true,
  [14] = true,
  [15] = true,
  [16] = true,
  [21] = true,
}

return function(gainStress, isJobWhitelisted, isVehicleWhitelisted)
  local speedMultiplier = Config.UseMPH and MPH_MULTIPLIER or KPH_MULTIPLIER
  local activeThreadId = 0

  local function startVehicleStressThread()
    local myThreadId = activeThreadId + 1
    activeThreadId = myThreadId
    DebugPrint('Starting vehicle stress thread')

    CreateThread(function()
      while cache.vehicle and activeThreadId == myThreadId do
        local vehicle = cache.vehicle
        if not isJobWhitelisted() and not isVehicleWhitelisted(vehicle) then
          local vehClass = GetVehicleClass(vehicle)
          if not NO_STRESS_VEHICLE_CLASSES[vehClass] then
            local speed = GetEntitySpeed(vehicle) * speedMultiplier
            local buckled = vehClass == VEHICLE_CLASS_MOTORCYCLE or LocalPlayer.state?.seatbelt
            local threshold = buckled and Config.Stress.speedThresholdBuckled or Config.Stress.speedThresholdUnbuckled
            DebugPrint('Vehicle class: %s | Speed: %.2f | Threshold: %.2f', vehClass, speed, threshold)
            if speed >= threshold then
              gainStress(math.random(STRESS_GAIN_MIN, STRESS_GAIN_MAX))
            end
          end
        end
        Wait(1000)
      end
      DebugPrint('Exited vehicle stress loop')
    end)
  end

  lib.onCache('vehicle', function(vehicle)
    if not vehicle then
      activeThreadId = activeThreadId + 1 -- invalidate any running thread
      return
    end
    startVehicleStressThread()
  end)

  if cache.vehicle then
    startVehicleStressThread()
  end
end
