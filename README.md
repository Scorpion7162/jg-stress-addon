# jg-stress-addon
A standalone stress system, designed to work with JG HUD out of the box. I already like qbx_hud's stress system, but don't understand why it's built into qbx_hud, and is not a separate resource.

This is all this resource provides. qbx_hud's stress system, in a separate resource, and will work out of the box with JG HUD with no additional configuration required.

All it does is update the LocalPlayer's statebag with the `stress` key. In case you want to use this with a different HUD!

qbx_hud: https://github.com/Qbox-project/qbx_hud

_This resource is standalone; and works with any framework such as Qbox, QB, ESX, ND etc, or no framework at all._

### Requirements

- OneSync Infinity

### Fetching the player's current stress level

```lua
local stress = LocalPlayer.state?.stress or 0
```

### License/Disclaimer

This repository is entirely code from qbx_hud (adapted a little bit) & JG Scripts takes absolutely no credit for it. qbx_hud doesn't seem to have a specific license attached to it to add here. If you use this code in part or in it's entirity, ensure you credit the original developer: https://github.com/Qbox-project

(c) 2025 https://github.com/Qbox-project

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

If you need to contact JG Scripts; email: hello@jgscripts.com
