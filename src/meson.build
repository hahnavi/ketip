ketip_sources = [
  'app.vala',
  'main.vala',
  'window.vala',
  'service.vala',
  'service_row.vala',
  'services_list_model.vala',
  'systemd/manager.vala',
  'systemd/unit.vala',
  'systemd/properties.vala',
  'config.vapi',
  'utils.vala'
]

ketip_deps = [
  dependency('gee-0.8', version: '>= 0.8.0'),
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('json-glib-1.0', version: '>= 1.0.0')
]

gnome = import('gnome')

ketip_sources += gnome.compile_resources('ketip-resources',
  'ketip.gresource.xml',
  c_name: 'ketip'
)

executable('ketip', ketip_sources,
  include_directories: config_h_dir,
  vala_args: '--target-glib=2.50',  dependencies: ketip_deps,
  install: true,
)
