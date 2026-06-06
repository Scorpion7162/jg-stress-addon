local Config = lib.require('config.config')
if not Config.VersionCheck then return end

local resource       = GetCurrentResourceName()
local currentVersion = GetResourceMetadata(resource, 'version', 0)
local repoUrl        = GetResourceMetadata(resource, 'repository', 0)

local repo = repoUrl and repoUrl:match('github%.com[:/]+([%w._-]+/[%w._-]+)')
if repo then repo = repo:gsub('%.git$', '') end

local function parseVersion(str)
  local parts = {}
  if str then
    for n in str:gmatch('%d+') do
      parts[#parts + 1] = tonumber(n)
    end
  end
  return parts
end

local function isNewer(latest, current)
  local l, c = parseVersion(latest), parseVersion(current)
  for i = 1, math.max(#l, #c) do
    local lv, cv = l[i] or 0, c[i] or 0
    if lv ~= cv then return lv > cv end
  end
  return false
end

CreateThread(function()
  if not currentVersion then
    DebugPrint('VersionCheck: no version set in fxmanifest, skipping')
    return
  end
  if not repo then
    DebugPrint('VersionCheck: could not resolve a GitHub repo from the manifest, skipping')
    return
  end

  Wait(1000)

  PerformHttpRequest(('https://api.github.com/repos/%s/releases/latest'):format(repo), function(status, body)
    if status ~= 200 or not body then
      DebugPrint('VersionCheck: request failed (status %s)', status)
      return
    end

    local ok, data = pcall(json.decode, body)
    if not ok or type(data) ~= 'table' or not data.tag_name then
      DebugPrint('VersionCheck: could not parse release info')
      return
    end

    if not isNewer(data.tag_name, currentVersion) then
      return -- up to date (or running ahead): say nothing
    end

    print(('^3[%s]^0 An update is available! Installed: ^1%s^0  Latest: ^2%s^0'):format(resource, currentVersion, data.tag_name))
    print(('^3[%s]^0 Download: %s'):format(resource, repoUrl or ('https://github.com/' .. repo)))
  end, 'GET', '', {
    ['User-Agent'] = resource,
    ['Accept']     = 'application/vnd.github+json',
  })
end)
