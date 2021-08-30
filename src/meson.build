vapi_sources = [
  'config.vapi'
]

ketip_vala_sources = [
  'app.vala',
  'main.vala',
  'window.vala',
  'service.vala',
  'service_row.vala',
  'services_list_model.vala',
  'systemd.vala',
  'utils.vala'
]

ketip_sources = [
  vapi_sources,
  ketip_vala_sources,
  resources
]

ketip_deps = [
  dependency('gio-2.0', version: '>= 2.50'),
  dependency('gtk+-3.0', version: '>= 3.22'),
  dependency('libhandy-1')
]

ketip_vala_args = [
  '--target-glib', '2.50',
  '--gresources', resource_files,
]

executable('ketip', ketip_sources,
  include_directories: config_h_dir,
  vala_args: ketip_vala_args,
  dependencies: ketip_deps,
  install: true,
)
