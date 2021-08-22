/* utils.vala
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

    public static void load_config_file() {
        var parser = new Json.Parser();
        try {
            parser.load_from_file(get_config_file_path());
            var root = parser.get_root().get_object();
            var services = root.get_array_member("services");
            foreach (var item in services.get_elements()) {
                var service = item.get_object();
                App.services_model.add(new Service(
                    service.get_string_member("name"),
                    service.get_string_member("unit_name")
                ));
            }
        } catch (Error e) {
            print ("Unable to parse 'config.json': %s\n", e.message);
        }
    }

    public static void create_config_file() {
        try {
            var conf_dir = File.new_for_path(get_config_dir());
            if (!FileUtils.test(get_config_dir(), FileTest.EXISTS)) {
                conf_dir.make_directory_with_parents(null);
            }
            File file = File.new_for_path (get_config_file_path());
            file.create (FileCreateFlags.PRIVATE);
            var builder = new Json.Builder();
            builder.begin_object()
                .set_member_name("services")
                .begin_array()
                .end_array()
                .end_object();
            var generator = new Json.Generator ();
            var root = builder.get_root ();
            generator.set_root (root);
            FileUtils.set_contents(get_config_file_path(), generator.to_data(null));
        } catch (Error e) {
            print(e.message);
        }
    }

    public static string get_config_dir() {
        return Path.build_filename(
            Environment.get_user_config_dir(),
            Config.PACKAGE_NAME
        );
    }

    public static string get_config_file_path() {
        return Path.build_filename(
            get_config_dir(),
            "config.json"
        );
    }

    public static void save_config_file() {
        var parser = new Json.Parser();
        try {
            parser.load_from_file(get_config_file_path());
            var root = parser.get_root();
            var builder = new Json.Builder();
            builder.begin_array();
            foreach (var service in App.services_model) {
                builder.begin_object()
                    .set_member_name("name")
                    .add_string_value(service.name)
                    .set_member_name("unit_name")
                    .add_string_value(service.unit_name)
                    .end_object();
            }
            builder.end_array();
            root.get_object().get_member("services").set_array(builder.get_root().get_array());
            var generator = new Json.Generator();
            generator.set_root(root);
            FileUtils.set_contents(get_config_file_path(), generator.to_data(null));
        } catch (Error e) {
            print ("Unable to parse 'config.json': %s\n", e.message);
        }
    }

    public static void show_error_dialog(Gtk.Window window, Error e) {
        var message_dialog = new Gtk.MessageDialog(window,
            Gtk.DialogFlags.DESTROY_WITH_PARENT,
            Gtk.MessageType.ERROR,
            Gtk.ButtonsType.CLOSE, e.message);
        message_dialog.title = "Error";
        message_dialog.run();
        message_dialog.destroy();
    }

    public static void empty_handler(Object object, ParamSpec param) {}
}