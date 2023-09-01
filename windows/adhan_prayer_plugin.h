#ifndef FLUTTER_PLUGIN_ADHAN_PRAYER_PLUGIN_H_
#define FLUTTER_PLUGIN_ADHAN_PRAYER_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace adhan_prayer {

class AdhanPrayerPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AdhanPrayerPlugin();

  virtual ~AdhanPrayerPlugin();

  // Disallow copy and assign.
  AdhanPrayerPlugin(const AdhanPrayerPlugin&) = delete;
  AdhanPrayerPlugin& operator=(const AdhanPrayerPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace adhan_prayer

#endif  // FLUTTER_PLUGIN_ADHAN_PRAYER_PLUGIN_H_
