project('ketip', ['c', 'vala'],
          version: '0.1.0',
    meson_version: '>= 0.50.0',
  default_options: [ 'warning_level=2',
                   ],
)

gnome = import('gnome')
i18n = import('i18n')

cc = meson.get_compiler ('c')

if get_option('profile') == 'development'
  name_suffix = '(Development) '
  profile = 'Devel'
else
  name_suffix = ''
  profile = ''
endif

app_id = 'com.github.hahnavi.ketip@0@'.format(profile)

conf = configuration_data()
conf.set_quoted('APP_ID', app_id)
conf.set_quoted('G_LOG_DOMAIN', 'com.github.hahnavi.ketip@0@'.format(profile))
conf.set_quoted('NAME_SUFFIX', name_suffix)
conf.set_quoted('PACKAGE_NAME', meson.project_name())
conf.set_quoted('PACKAGE_VERSION', meson.project_version())
conf.set_quoted('PROFILE', profile)
conf.set_quoted('VERSION', meson.project_version())
conf.set_quoted('DATADIR', join_paths(get_option('prefix'), get_option('datadir')))
configure_file(output: 'config.h', configuration: conf)
config_h_dir = include_directories('.')

subdir('data')
subdir('src')
subdir('po')

meson.add_install_script('build-aux/meson/postinstall.py')
