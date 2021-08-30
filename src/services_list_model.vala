/* services_list_model.vala
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

    public class ServicesListModel : Object, ListModel {

        private ListStore store;
        private CompareDataFunc? sort_func;

        public ServicesListModel() {
            store = new ListStore(typeof (Service));
            store.items_changed.connect ((position, removed, added) => {
                items_changed (position, removed, added);
            });
        }

        public Type get_item_type () {
            return store.get_item_type ();
        }
    
        public uint get_n_items () {
            return store.get_n_items ();
        }
    
        public Object? get_item (uint position) {
            return store.get_item (position);
        }

        public void add (Service item) {
            if (sort_func == null) {
                store.append (item);
            } else {
                store.insert_sorted (item, sort_func);
            }
        }
    
        public int get_index (Service item) {
            int position = -1;
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                var compared_item = (Service) store.get_object (i);
                if (compared_item == item) {
                    position = i;
                    break;
                }
            }
            return position;
        }

        public void set_item (uint position, Service item) {
            store.insert (position, item);
            store.remove (position);
        }
    
        public void remove (Service item) {
            var index = get_index (item);
            if (index != -1) {
                store.remove (index);
            }
        }
    
        public delegate void ForeachFunc (Service item);
    
        public void foreach (ForeachFunc func) {
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                func ((Service) store.get_object (i));
            }
        }
    
        public delegate bool FindFunc (Service item);
    
        public Service? find (FindFunc func) {
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                var item = (Service) store.get_object (i);
                if (func (item)) {
                    return item;
                }
            }
            return null;
        }
    
        public void delete_item (Service item) {
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                var o = store.get_object (i);
                if (o == item) {
                    store.remove (i);
    
                    if (sort_func != null) {
                        store.sort (sort_func);
                    }
    
                    return;
                }
            }
        }
    
        public Variant serialize () {
            var builder = new GLib.VariantBuilder (new VariantType ("aa{sv}"));
            var n = store.get_n_items ();
            for (int i = 0; i < n; i++) {
                ((Service) store.get_object (i)).serialize (builder);
            }
            return builder.end ();
        }
    
        public delegate Service? DeserializeItemFunc (Variant v);
    
        public void deserialize (Variant variant, DeserializeItemFunc deserialize_item) {
            Variant item;
            var iter = variant.iterator ();
            while (iter.next ("@a{sv}", out item)) {
                Service? i = deserialize_item (item);
                if (i != null) {
                    add ((Service) i);
                }
            }
        }
    }
}