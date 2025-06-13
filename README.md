# jg-stress-addon
A standalone stress system, designed for JG HUD. I already like qbx_hud's stress system, but don't understand why it's built into qbx_hud, and is not a separate resource.

This is all this resource provides. qbx_hud's stress system, in a separate resource, and will work out of the box with JG HUD with no additional configuration required.

All it does is update the LocalPlayer's statebag with the `stress` key. In case you want to use this with a different HUD!

### Fetching the player's current stress level

```lua
local stress = LocalPlayer.state?.stress or 0
```
