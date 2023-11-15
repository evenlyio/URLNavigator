#if os(iOS) || os(visionOS) || os(tvOS)
import UIKit

extension UIViewController {
  private class var sharedApplication: UIApplication? {
    let selector = NSSelectorFromString("sharedApplication")
    return UIApplication.perform(selector)?.takeUnretainedValue() as? UIApplication
  }

  private class var keyWindow: UIWindow? {
    if #available(iOS 15.0, *) {
      return UIApplication.shared
          .connectedScenes
          .compactMap { $0 as? UIWindowScene }
          // HACK: the scene's keyWindow is not part of the windows array of a scene
          // on visionOS + SwiftUI app lifecycle.
          .filter { $0.activationState == .foregroundActive }
          .first { $0.keyWindow != nil }
          .flatMap { $0.windows.first }
    } else {
        return (self.sharedApplication?.windows ?? [])
            .first(where: { $0.isKeyWindow })
    }
  }

  /// Returns the current application's top most view controller.
  public class var topMost: UIViewController? {
    return self.topMost(of: keyWindow?.rootViewController)
  }

  /// Returns the top most view controller from given view controller's stack.
  public class func topMost(of viewController: UIViewController?) -> UIViewController? {
    // presented view controller
    if let presentedViewController = viewController?.presentedViewController {
      return self.topMost(of: presentedViewController)
    }

    // UITabBarController
    if let tabBarController = viewController as? UITabBarController,
      let selectedViewController = tabBarController.selectedViewController {
      return self.topMost(of: selectedViewController)
    }

    // UINavigationController
    if let navigationController = viewController as? UINavigationController,
      let visibleViewController = navigationController.visibleViewController {
      return self.topMost(of: visibleViewController)
    }

    // UIPageController
    if let pageViewController = viewController as? UIPageViewController,
      pageViewController.viewControllers?.count == 1 {
      return self.topMost(of: pageViewController.viewControllers?.first)
    }

    // child view controller
    for subview in viewController?.view?.subviews ?? [] {
      if let childViewController = subview.next as? UIViewController {
        return self.topMost(of: childViewController)
      }
    }

    return viewController
  }
}
#endif
