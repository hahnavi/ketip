/* window.vala
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

	[GtkTemplate (ui = "/com/github/hahnavi/ketip/ui/window.ui")]
	public class Window : Hdy.ApplicationWindow {

		[GtkChild]
	    private unowned Hdy.HeaderBar header_bar;

		[GtkChild]
	    private unowned Gtk.MenuButton button_add_service;

		[GtkChild]
	    private unowned Gtk.Button button_add_service_2;

	    [GtkChild]
	    private unowned Gtk.Popover popover_add_service;

		[GtkChild]
	    private unowned Gtk.Entry entry_service_name;

		[GtkChild]
	    private unowned Gtk.Entry entry_unit_name;

		[GtkChild]
		private unowned Gtk.ListStore list_store_unit_files;

		[GtkChild]
	    private unowned Gtk.Button button_add_add_service;

		[GtkChild]
		private unowned Gtk.ModelButton menu_main_reload_list;

		[GtkChild]
		private unowned Gtk.ModelButton menu_main_about;

		[GtkChild]
		private unowned Gtk.Stack stack_view;

		[GtkChild]
		private unowned Gtk.Widget empty_view;

		[GtkChild]
		private unowned Gtk.ScrolledWindow list_view;

		[GtkChild]
		private unowned Gtk.ListBox list_box_services;

		[GtkChild]
		private unowned Gtk.Popover popover_rename;

		[GtkChild]
		private unowned Gtk.Entry entry_new_service_name;

		[GtkChild]
		private unowned Gtk.Button button_rename;

		private ServicesListModel services;
		private HashTable<string, Systemd.Properties> props;
		private Service service_to_rename;

		public Window (Gtk.Application app) {
			Object (application: app);

			unowned string? use_csd = Environment.get_variable ("GTK_CSD");
			if (use_csd == "0") {
				header_bar.set_show_close_button (false);
			}

			set_default_size(App.settings.get_int("win-width"), App.settings.get_int("win-height"));
			if (App.settings.get_boolean("win-maximized")) {
				maximize();
			} else {
				move(App.settings.get_int("win-pos-x"), App.settings.get_int("win-pos-y"));
				resize(App.settings.get_int("win-width"), App.settings.get_int("win-height"));
			}

			services = new ServicesListModel();
			load();

			props = new HashTable<string, Systemd.Properties>(str_hash, str_equal);

			menu_main_reload_list.clicked.connect(() => {
				reload_list();
			});
			menu_main_about.clicked.connect(() => {
				string[] authors = { "Abdul Munif Hanafi" };
				Gtk.show_about_dialog (
					this,
					"authors", authors,
					"copyright", "Copyright \xc2\xa9 2021 Abdul Munif Hanafi",
					"license-type", Gtk.License.GPL_3_0,
					"program-name", "Ketip",
					"comments", _("systemd Service Manager"),
					"logo-icon-name", Config.APP_ID,
					"version", Config.VERSION,
					"website", "https://github.com/hahnavi/ketip"
				);
			});

			button_add_service_2.clicked.connect(() => {
				button_add_service.clicked();
			});

			services.items_changed.connect((position, removed, added) => {
				stack_view.visible_child = services.get_n_items () == 0 ? empty_view : list_view;
			});

			reload_list();

			Timeout.add(200, () => {
				get_list_unit_files();
				return false;
			});

			delete_event.connect(e => {
				return before_destroy();
			});
		}

		private void get_list_unit_files() {
			Idle.add(() => {
				if (App.manager != null) {
					try {
						Systemd.Manager.UnitFile[] unit_files = App.manager.list_unit_files();
						foreach (var unit_file in unit_files) {
							if (unit_file.path.has_suffix(".service")) {
								var splitted = unit_file.path.split("/");
								Gtk.TreeIter iter;
								list_store_unit_files.append(out iter);
								list_store_unit_files.set(iter, 0, splitted[splitted.length - 1]);
							}
						}
					} catch (Error e) {
						show_error_dialog(this, e);
					}
				}
				return Source.REMOVE;
			});
		}

		private Gtk.Widget create_list_row(Object serviceObj) {
			return new_service_row((Service) serviceObj);
		}

		private ServiceRow new_service_row(Service service) {
			var row = new ServiceRow(this, service);

			if (row.unit.fragment_path != "" && row.prop != null) {
				props.insert(service.unit_name, row.prop);
			}

			row.button_rename_service.clicked.connect(() => {
				service_to_rename = service;
			    popover_rename.relative_to = row.label_service_name;
                entry_new_service_name.text = service.name;
			    popover_rename.popup();
			    entry_new_service_name.is_focus = true;
			});
			row.button_delete_service.clicked.connect(() => {
				delete_service(row);
			});

			return row;
		}

		[GtkCallback]
		private void entry_service_name_add_service_changed(Gtk.Editable editable) {
		    if ((entry_service_name.text != "")
		            && (entry_unit_name.text != "")
		            && (entry_unit_name.text.has_suffix(".service"))) {
                button_add_add_service.sensitive = true;
		    } else {
		        button_add_add_service.sensitive = false;
		    }
		}

		[GtkCallback]
		private bool entry_add_service_key_press_event(Gdk.EventKey event) {
		    if ((event.keyval == 65293)
		            && (button_add_add_service.sensitive == true)) {
		        button_add_add_service.clicked();
		    }
		    return false;
		}

		[GtkCallback]
		private void button_cancel_add_service_clicked(Gtk.Button button) {
            popover_add_service.popdown();
            clear_form_add_service();
		}

		[GtkCallback]
		private void button_add_add_service_clicked(Gtk.Button button) {
			try {
				if (is_service_already_exists(entry_unit_name.text)) {
					throw new IOError.EXISTS(
						_("'%s' already exists.").printf(entry_unit_name.text)
					);
				}
				var service = new Service(
					entry_service_name.text,
					entry_unit_name.text
				);
				Systemd.Unit u = Bus.get_proxy_sync(
						BusType.SYSTEM,
						"org.freedesktop.systemd1",
						App.manager.load_unit(service.unit_name));
				if (u.fragment_path != "") {
					services.add(service);
					save();
					popover_add_service.popdown();
					clear_form_add_service();
					list_box_services.show_all();
				} else {
					throw new DBusError.FILE_NOT_FOUND(
						@"The system cannot find '$(service.unit_name)' unit file."
					);
				}
			} catch (Error e) {
				show_error_dialog(this, e);
			}
		}

		private bool is_service_already_exists(string unit_name) {
			var n = services.get_n_items ();
            for (int i = 0; i < n; i++) {
                var item = (Service) services.get_object (i);
                if (item.unit_name == unit_name) {
					return true;
                }
            }
			return false;
		}

		[GtkCallback]
		private void entry_new_service_name_changed(Gtk.Editable editable) {
		    if (entry_new_service_name.text != "") {
                button_rename.sensitive = true;
		    } else {
		        button_rename.sensitive = false;
		    }
		}

		[GtkCallback]
		private bool entry_rename_service_key_press_event(Gdk.EventKey event) {
		    if ((event.keyval == 65293) && (button_rename.sensitive == true)) {
		        button_rename.clicked();
		    }
		    return false;
		}

        [GtkCallback]
        private void button_rename_clicked(Gtk.Button button) {
            if (entry_new_service_name.text != service_to_rename.name) {
                var position = services.get_index(service_to_rename);
                service_to_rename.name = entry_new_service_name.text;
				services.set_item(position, service_to_rename);
				save();
				((ServiceRow) list_box_services.get_row_at_index(position))
					.reload_widget();
            }
            entry_new_service_name.text = "";
			popover_rename.popdown();
        }

		private void delete_service(ServiceRow row) {
			var dialog = new Gtk.MessageDialog(
				this,
				Gtk.DialogFlags.DESTROY_WITH_PARENT,
				Gtk.MessageType.QUESTION,
				Gtk.ButtonsType.YES_NO,
				_("Are you sure you want to delete '%s' from the list?").printf(row.service.name)
			);
			dialog.format_secondary_text(@"($(row.service.unit_name))");
			var response = dialog.run();
			if (response == Gtk.ResponseType.YES) {
				services.remove(row.service);
				save();
				props.remove(row.service.unit_name);
			}
			dialog.destroy();
		}

		private void clear_form_add_service() {
		    entry_service_name.text = "";
            entry_unit_name.text = "";
		}

		private void reload_list() {
			props.remove_all();
			stack_view.visible_child = services.get_n_items () == 0 ? empty_view : list_view;
			list_box_services.bind_model(services, create_list_row);
			list_box_services.show_all();
		}

		private void load () {
			services.deserialize (App.settings.get_value ("services"), Service.deserialize);
		}

		private void save() {
			App.settings.set_value("services", services.serialize());
		}

		private bool before_destroy() {
			if (is_maximized) {
				App.settings.set_boolean("win-maximized", true);
			} else {
				int width, height, pos_x, pos_y;

				get_size(out width, out height);
				get_position(out pos_x, out pos_y);

				App.settings.set_int("win-pos-x", pos_x);
				App.settings.set_int("win-pos-y", pos_y);
				App.settings.set_int("win-width", width);
				App.settings.set_int("win-height", height);
				App.settings.set_boolean("win-maximized", false);
			}

			return false;
		}
	}
}