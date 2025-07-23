#include "include/tao996/tao996_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "tao996_plugin.h"

void Tao996PluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  tao996::Tao996Plugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
