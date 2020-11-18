import UIKit

public protocol SideMenuPresenting {
  func setup(in viewController: UIViewController)
  func present(from viewController: UIViewController)
}

public final class SideMenuPresenter: NSObject,
                                      SideMenuPresenting,
                                      UIViewControllerTransitioningDelegate {
  public init(
    menuViewControllerFactory: @escaping () -> UIViewController,
    presentInteractor: SideMenuPresentInteracting = SideMenuPresentInteractor(),
    dismissInteractor: SideMenuDismissInteracting = SideMenuDismissInteractor(),
    menuAnimator: SideMenuAnimating = SideMenuAnimator(),
    viewAnimator: UIViewAnimating.Type = UIView.self
  ) {
    self.menuViewControllerFactory = menuViewControllerFactory
    self.presentInteractor = presentInteractor
    self.dismissInteractor = dismissInteractor
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  let menuViewControllerFactory: () -> UIViewController
  let presentInteractor: SideMenuPresentInteracting
  let dismissInteractor: SideMenuDismissInteracting
  let menuAnimator: SideMenuAnimating
  let viewAnimator: UIViewAnimating.Type

  // MARK: - SideMenuPresenting

  public func setup(in viewController: UIViewController) {
    presentInteractor.setup(
      view: viewController.view,
      action: { [weak self] in
        self?.present(from: viewController)
      }
    )
  }

  public func present(from viewController: UIViewController) {
    let menuViewController = menuViewControllerFactory()
    menuViewController.modalPresentationStyle = .overFullScreen
    menuViewController.transitioningDelegate = self
    viewController.present(menuViewController, animated: true)
  }

  // MARK: - UIViewControllerTransitioningDelegate

  public func animationController(
    forPresented presented: UIViewController,
    presenting: UIViewController,
    source: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SideMenuPresentTransition(
      dismissInteractor: dismissInteractor,
      menuAnimator: menuAnimator,
      viewAnimator: viewAnimator
    )
  }

  public func animationController(
    forDismissed dismissed: UIViewController
  ) -> UIViewControllerAnimatedTransitioning? {
    SideMenuDismissTransition(
      menuAnimator: menuAnimator,
      viewAnimator: viewAnimator
    )
  }

  public func interactionControllerForPresentation(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    presentInteractor.interactionInProgress ? presentInteractor : nil
  }

  public func interactionControllerForDismissal(
    using animator: UIViewControllerAnimatedTransitioning
  ) -> UIViewControllerInteractiveTransitioning? {
    dismissInteractor.interactionInProgress ? dismissInteractor.percentDrivenInteractiveTransition : nil
  }
}
