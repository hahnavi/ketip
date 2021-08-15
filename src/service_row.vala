/* listrow.vala
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

	[GtkTemplate (ui = "/io/github/hahnavi/Ketip/service_row.ui")]
	public class ServiceRow : Gtk.ListBoxRow {

		[GtkChild]
		private unowned Gtk.Label label_service_name;

		[GtkChild]
		public unowned Gtk.Label label_service_description;

		[GtkChild]
		public unowned Gtk.Switch switch_service;

		[GtkChild]
		public unowned Gtk.MenuButton button_menu_service;

		public ServiceRow(Service service) {
			label_service_name.set_markup (
				@"<b>$(service.name)</b> <small>($(service.unit_name))</small>"
			);
		}
	}
}