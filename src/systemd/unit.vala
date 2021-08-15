/* unit.vala
 *
 * Copyright 2021 Abdul Munif Hanafi
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

namespace Ketip.Systemd {

    [DBus (name = "org.freedesktop.systemd1.Unit", timeout = 120000)]
    public interface Unit : GLib.Object {

        [DBus (name = "Description")]
        public abstract string description { owned get; }

        [DBus (name = "ActiveState")]
        public abstract string active_state { owned get; }

        [DBus (name = "Start")]
        public abstract GLib.ObjectPath start(string mode) throws DBusError, IOError;

        [DBus (name = "Stop")]
        public abstract GLib.ObjectPath stop(string mode) throws DBusError, IOError;

        [DBus (name = "Reload")]
        public abstract GLib.ObjectPath reload(string mode) throws DBusError, IOError;

        [DBus (name = "Restart")]
        public abstract GLib.ObjectPath restart(string mode) throws DBusError, IOError;
    }
}