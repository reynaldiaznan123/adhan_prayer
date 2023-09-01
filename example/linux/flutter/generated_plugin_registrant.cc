//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <adhan_prayer/adhan_prayer_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) adhan_prayer_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AdhanPrayerPlugin");
  adhan_prayer_plugin_register_with_registrar(adhan_prayer_registrar);
}
