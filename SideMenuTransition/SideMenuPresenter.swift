import UIKit

protocol SideMenuPresenting {
  func setup(in viewController: UIViewController)
  func present(from viewController: UIViewController)
}

final class SideMenuPresenter: NSObject,
                               SideMenuPresenting,
                               UIViewControllerTransitioningDelegate {
  init(
    menuViewControllerFactory: @escaping () -> UIViewController,
    presentInteractor: SideMenuPresentInteracting = SideMenuPresentInteractor(),
    dismissInteractor: SideMenuDismissInteracting = SideMenuDismissInteractor(),
    animator: SideMenuAnimating = SideMenuAnimator()
  ) {
    self.menuViewControllerFactory = menuViewControllerFactory
    self.presentInteractor = presentInteractor
    self.dismissInteractor = dismissInteractor
    self.animator = animator
    super.init()
  }

  let menuViewControllerFactory: () -> UIViewController
  let presentInteractor: SideMenuPresentInteracting
  let dismissInteractor: SideMenuDismissInteracting
  let animator: SideMenuAnimating

  // MARK: - SideMenuPresenting

  func setup(in viewController: UIViewController) {
    presentInteractor.setup(
      view: viewController.view,
      action: { [weak self] in
        self?.present(from: viewController)
      }
    )
  }

  func present(from viewController: UIViewController) {
    let menuViewController = menuViewControllerFactory()
    menuViewController.modalPresentationStyle = .overFullScreen
    menuViewController.transitioningDelegate = self
    viewController.present(menuViewController, animated: true)
  }

  // MARK: - UIViewControllerTransitioningDelegate

  func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SideMenuPresentTransition(
      dismissInteractor: dismissInteractor,
      animator: animator
    )
  }

  func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SideMenuDismissTransition(
      animator: animator
    )
  }

  func interactionControllerForPresentation(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    presentInteractor.interactionInProgress ? presentInteractor : nil
  }

  func interactionControllerForDismissal(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    dismissInteractor.interactionInProgress ? dismissInteractor : nil
  }
}
