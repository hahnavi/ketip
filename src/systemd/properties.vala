/* properties.vala
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

    [DBus (name = "org.freedesktop.DBus.Properties")]
    public interface Properties : DBusProxy {

        [DBus (name = "Get")]
        public abstract Variant get(string interface, string property) throws DBusError, IOError;

        [DBus (name = "PropertiesChanged")]
        public signal void properties_changed(string interface, HashTable<string, Variant> changed_properties, string[] invalidated_properties);
    }
}