/* manager.vala
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

    [DBus (name = "org.freedesktop.systemd1.Manager")]
    public interface Manager : DBusProxy {

        public struct UnitFile {
            string path;
            string state;
        }

        [DBus (name = "LoadUnit")]
        public abstract ObjectPath load_unit(string name) throws DBusError, IOError;

        [DBus (name = "ListUnitFiles")]
        public abstract UnitFile[] list_unit_files() throws DBusError, IOError;
    }
}