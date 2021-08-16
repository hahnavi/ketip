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

	[GtkTemplate (ui = "/io/github/hahnavi/Ketip/window.ui")]
	public class Window : Gtk.ApplicationWindow {

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
		private unowned Gtk.ListBox list_box_services;

		[GtkChild]
		private unowned Gtk.Popover popover_rename;

		[GtkChild]
		private unowned Gtk.Entry entry_new_service_name;

		[GtkChild]
		private unowned Gtk.Button button_rename;

		private Systemd.Manager manager;
		private Service service_to_rename;

		public Window (Gtk.Application app) {
			Object (application: app);
			try {
				manager = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					"/org/freedesktop/systemd1");
			} catch (IOError e) {
				print(e.message);
			}
			menu_main_reload_list.clicked.connect(() => {
				reload_list();
			});
			menu_main_about.clicked.connect(() => {
				string[] authors = {"Abdul Munif Hanafi"};
				Gtk.show_about_dialog (
					this,
					"authors", authors,
					"copyright", "Copyright \xc2\xa9 2021 Abdul Munif Hanafi",
					"license-type", Gtk.License.GPL_3_0,
					"program-name", "Ketip",
					"comments", "systemd Service Manager",
					"logo-icon-name", Config.APP_ID,
					"version", Config.VERSION,
					"website", "https://hahnavi.github.io/ketip/"
				);
			});
			reload_list();
			get_list_unit_files.begin((obj, res) => {
				get_list_unit_files.end(res);
			});
		}

		private async void get_list_unit_files() {
			Timeout.add(1000, () => {
				if (manager != null) {
					try {
						Systemd.Manager.UnitFile[] unit_files = manager.list_unit_files();
						foreach (var unit_file in unit_files) {
							if (unit_file.path.has_suffix(".service")) {
								var splitted = unit_file.path.split("/");
								Gtk.TreeIter iter;
								list_store_unit_files.append(out iter);
								list_store_unit_files.set(iter, 0, splitted[splitted.length - 1]);
							}
						}
					} catch (Error e) {
						show_error(e);
					}
				}
				return false;
			});
		}

		private Gtk.Widget create_list_row(Object serviceObj) {
			var service = (Service) serviceObj;
			var row = new ServiceRow(service);
			
			Systemd.Unit u = null;
			try {
				u = Bus.get_proxy_sync(
					BusType.SYSTEM,
					"org.freedesktop.systemd1",
					manager.load_unit(service.unit_name));
			} catch (Error e) {
				print(e.message);
			}

			if (u.fragment_path != "") {
				if (u.active_state == "active") {
					row.switch_service.active = true;
				} else {
					row.switch_service.active = false;
				}
				row.switch_service.notify["active"].connect(() => {
					if (row.switch_service.active) {
						start_service(u);
					} else {
						stop_service(u);
					}
				});
				row.label_service_description.set_markup(
					@"<small>$(u.description)</small>"
				);
			} else {
				row.label_service_name.set_markup(@"<i><b>$(service.name)</b></i>");
				row.label_service_unit_name.set_markup(
					@"<i><small>($(service.unit_name))</small></i>"
				);
				row.label_service_description.set_markup(
					"<i><small>(service not found)</small></i>"
				);
				row.switch_service.sensitive = false;
			}

			if (u.fragment_path != "") {
				if (u.active_state == "active") {
					row.button_restart_service.clicked.connect(() => {
						restart_service(u);
					});
					row.button_restart_service.show();
					if (u.can_reload == true) {
						row.button_reload_service.clicked.connect(() => {
							reload_service(u);
						});
						row.button_reload_service.show();
					}
					row.separator_menu_service_1.show();
				}
			}
			row.button_rename_service.clicked.connect(() => {
				service_to_rename = service;
			    popover_rename.relative_to = row.label_service_name;
                entry_new_service_name.text = service.name;
			    popover_rename.popup();
			    entry_new_service_name.is_focus = true;
			});
			row.button_delete_service.clicked.connect(() => {
				var dialog = new Gtk.MessageDialog(
					this,
					Gtk.DialogFlags.DESTROY_WITH_PARENT,
					Gtk.MessageType.QUESTION,
					Gtk.ButtonsType.YES_NO,
					@"Are you sure you want to delete '$(service.name)' from the list?"
				);
				dialog.format_secondary_text(@"($(service.unit_name))");
				var response = dialog.run();
				if (response == Gtk.ResponseType.YES) {
					App.services_model.remove(service);
					save_and_reload_list();
				}
				dialog.destroy();
			});

			return row;
		}

		private void start_service(Systemd.Unit u) {
			try {
				u.start("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void stop_service(Systemd.Unit u) {
			try {
				u.stop("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void restart_service(Systemd.Unit u) {
			try {
				u.restart("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void reload_service(Systemd.Unit u) {
			try {
				u.reload("replace");
			} catch (Error e) {
				show_error(e);
			}
		}

		public void show_error(Error e) {
			var message_dialog = new Gtk.MessageDialog(this,
				Gtk.DialogFlags.DESTROY_WITH_PARENT,
				Gtk.MessageType.ERROR,
				Gtk.ButtonsType.CLOSE, e.message);
			message_dialog.title = "Error";
			message_dialog.run();
			message_dialog.destroy();
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
						@"'$(entry_unit_name.text)' already exists."
					);
				}
				var service = new Service(
					entry_service_name.text,
					entry_unit_name.text
				);
				Systemd.Unit u = Bus.get_proxy_sync(
						BusType.SYSTEM,
						"org.freedesktop.systemd1",
						manager.load_unit(service.unit_name));
				if (u.fragment_path != "") {
					App.services_model.add(service);
					save_and_reload_list();
					popover_add_service.popdown();
					clear_form_add_service();
				} else {
					throw new DBusError.FILE_NOT_FOUND(
						@"The system cannot find '$(service.unit_name)' unit file."
					);
				}
			} catch (Error e) {
				show_error(e);
			}
		}

		private bool is_service_already_exists(string unit_name) {
			foreach (var service in App.services_model) {
				if (service.unit_name == unit_name) {
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
                var index = App.services_model.index_of(service_to_rename);
                App.services_model.remove(service_to_rename);
                service_to_rename.name = entry_new_service_name.text;
                App.services_model.insert(index, service_to_rename);
            }
            entry_new_service_name.text = "";
            save_and_reload_list();
        }

		private void clear_form_add_service() {
		    entry_service_name.text = "";
            entry_unit_name.text = "";
		}

		private void save_and_reload_list() {
			save_config_file();
			reload_list();
		}

		private void reload_list() {
			list_box_services.bind_model(App.services_model, create_list_row);
			list_box_services.show_all();
		}
	}
}