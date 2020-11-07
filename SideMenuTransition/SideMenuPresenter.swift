import UIKit

final class SideMenuPresenter: NSObject, UIViewControllerTransitioningDelegate {
  let menuViewControllerFactory: () -> UIViewController = MenuViewController.init

  func present(from viewController: UIViewController) {
    let menuViewController = menuViewControllerFactory()
    menuViewController.modalPresentationStyle = .overFullScreen
    menuViewController.transitioningDelegate = self
    viewController.present(menuViewController, animated: true)
  }

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SideMenuPresentTransition()
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SideMenuDismissTransition()
  }
}
