import Flutter
import UIKit
import flutter_local_notifications
@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
      //bildirim ayarı
      FlutterLocalNotificationsPlugin.setPluginRegistrantCallback{(registry) in 
      GeneratedPluginRegistrant.register(with: registry)}
      //
      
      GeneratedPluginRegistrant.register(with: self)

      //bildirim ayarı
      if #available(iOS 10.0, *) {
          UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
        }
      //
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
