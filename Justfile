uuid := "ssm-gnome@lgiki.net"
src  := justfile_directory() / "src"
zip  := justfile_directory() / uuid + ".shell-extension.zip"
dest := env("XDG_DATA_HOME", env("HOME") / ".local/share") / "gnome-shell/extensions" / uuid

default:
    @just --list

# Compile the GSettings schemas
schemas:
    glib-compile-schemas "{{src}}/schemas"

# Install a packed copy into the user extensions dir and enable it.
# A copy (not a symlink) so removing the extension from GNOME can't delete src/.
install: pack
    #!/usr/bin/env bash
    set -euo pipefail
    if [ -L "{{dest}}" ]; then
        rm -f "{{dest}}"
    fi
    gnome-extensions install --force "{{zip}}"
    echo "installed {{uuid}} into {{dest}}"
    gnome-extensions enable "{{uuid}}" || echo "note: log out and back in so GNOME Shell picks up the extension, then run 'just enable'"

# Disable and remove the installed extension
uninstall:
    -gnome-extensions disable "{{uuid}}"
    -gnome-extensions uninstall "{{uuid}}"

# Build the distributable zip (same as build.sh, without formatting)
pack: schemas
    gnome-extensions pack "{{src}}" --extra-source=settings.js --extra-source=prefs.ui --force -o "{{justfile_directory()}}"

enable:
    gnome-extensions enable "{{uuid}}"

disable:
    gnome-extensions disable "{{uuid}}"

# Open the preferences window
prefs:
    gnome-extensions prefs "{{uuid}}"

# Show extension state
status:
    gnome-extensions info "{{uuid}}"

# Follow GNOME Shell logs
logs:
    journalctl -f -o cat /usr/bin/gnome-shell
