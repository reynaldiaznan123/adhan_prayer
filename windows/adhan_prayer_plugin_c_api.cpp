#include "include/adhan_prayer/adhan_prayer_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "adhan_prayer_plugin.h"

void AdhanPrayerPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  adhan_prayer::AdhanPrayerPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
