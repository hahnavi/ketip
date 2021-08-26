/* app.vala
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

    public class App : Gtk.Application {

        public static App app;
        public static ServicesListModel services_model = new ServicesListModel ();
        public static Systemd.Manager? manager = null;
        public static Settings settings = new Settings(Config.APP_ID);

        public App() {
            application_id = Config.APP_ID;
            flags = ApplicationFlags.FLAGS_NONE;
            app = this;

            startup.connect (() => {
                File file = File.new_for_path (get_config_file_path());
                if (!file.query_exists ()) {
                    create_config_file();
                }

                load_config_file();

                try {
                    manager = Bus.get_proxy_sync(
                        BusType.SYSTEM,
                        "org.freedesktop.systemd1",
                        "/org/freedesktop/systemd1");
                } catch (IOError e) {
                    print(@"$(e.message)\n");
                }
            });

            activate.connect (() => {
                var win = app.active_window;
                if (win == null) {
                    win = new Ketip.Window (app);
                }
                win.present ();
            });
        }
    }
}