#import "REAInitializer.h"
#import "REAUIManager.h"

#import <React-Fabric/react/renderer/uimanager/UIManager.h> // ReanimatedListener

@interface RCTEventDispatcher (Reanimated)

- (void)setBridge:(RCTBridge *)bridge;

@end

namespace reanimated {

using namespace facebook;
using namespace react;

JSIExecutor::RuntimeInstaller REAJSIExecutorRuntimeInstaller(
    RCTBridge *bridge,
    JSIExecutor::RuntimeInstaller runtimeInstallerToWrap)
{
  /*[bridge moduleForClass:[RCTUIManager class]];
  REAUIManager *reaUiManager = [REAUIManager new];
  [reaUiManager setBridge:bridge];
  RCTUIManager *uiManager = reaUiManager;
  [bridge updateModuleWithInstance:uiManager];*/

  /*[bridge moduleForClass:[RCTEventDispatcher class]];
  RCTEventDispatcher *eventDispatcher = [REAEventDispatcher new];
#if RNVERSION >= 66
  RCTCallableJSModules *callableJSModules = [RCTCallableJSModules new];
  [bridge setValue:callableJSModules forKey:@"_callableJSModules"];
  [callableJSModules setBridge:bridge];
  [eventDispatcher setValue:callableJSModules forKey:@"_callableJSModules"];
  [eventDispatcher setValue:bridge forKey:@"_bridge"];
  [eventDispatcher initialize];
#else
  [eventDispatcher setBridge:bridge];
#endif
  [bridge updateModuleWithInstance:eventDispatcher];
  _bridge_reanimated = bridge;*/
  const auto runtimeInstaller = [bridge, runtimeInstallerToWrap](facebook::jsi::Runtime &runtime) {
    if (!bridge) {
      return;
    }

    if (runtimeInstallerToWrap) {
      runtimeInstallerToWrap(runtime);
    }

    auto reanimatedModule = reanimated::createReanimatedModule(bridge, bridge.jsCallInvoker);
    runtime.global().setProperty(
      runtime,
      "_WORKLET_RUNTIME",
      static_cast<double>(
          reinterpret_cast<std::uintptr_t>(reanimatedModule->runtime.get())));

    runtime.global().setProperty(
        runtime,
        jsi::PropNameID::forAscii(runtime, "__reanimatedModuleProxy"),
        jsi::Object::createFromHostObject(runtime, reanimatedModule));    
  };
  return runtimeInstaller;
}

}
