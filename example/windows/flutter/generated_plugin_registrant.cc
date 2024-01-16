//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <adhan_prayer/adhan_prayer_plugin_c_api.h>
#include <geolocator_windows/geolocator_windows.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AdhanPrayerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AdhanPrayerPluginCApi"));
  GeolocatorWindowsRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("GeolocatorWindows"));
}
