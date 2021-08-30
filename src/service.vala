/* service.vala
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

namespace Ketip {

	public class Service : Object {

		public string name;
		public string unit_name;

		public Service(string name, string unit_name) {
			this.name = name;
			this.unit_name = unit_name;
		}

    	public void serialize (GLib.VariantBuilder builder) {
			builder.open (new GLib.VariantType ("a{sv}"));
			builder.add ("{sv}", "name", new GLib.Variant.string ((string) name));
			builder.add ("{sv}", "unit_name", new GLib.Variant.string ((string) unit_name));
			builder.close ();
		}

		public static Service? deserialize (Variant service_variant) {
			string key;
        	Variant val;
			string? name = null;
			string? unit_name = null;
			var iter = service_variant.iterator ();
			while (iter.next ("{sv}", out key, out val)) {
				if (key == "name") {
					name = (string) val;
				} else if (key == "unit_name") {
					unit_name = (string) val;
				}
			}

			if (name != null && unit_name != null) {
				return new Service(name, unit_name);
			}

			return null;
		}
	}
}