import UIKit

final class SideMenuPresentTransition: NSObject,
                                       UIViewControllerAnimatedTransitioning {
  init(
    dismissInteractor: SideMenuDismissInteracting,
    menuAnimator: SideMenuAnimating,
    viewAnimator: UIViewAnimating.Type
  ) {
    self.dismissInteractor = dismissInteractor
    self.menuAnimator = menuAnimator
    self.viewAnimator = viewAnimator
    super.init()
  }

  let dismissInteractor: SideMenuDismissInteracting
  let menuAnimator: SideMenuAnimating
  let viewAnimator: UIViewAnimating.Type

  // MARK: - UIViewControllerAnimatedTransitioning

  func transitionDuration(using context: UIViewControllerContextTransitioning?) -> TimeInterval {
    0.25
  }

  func animateTransition(using context: UIViewControllerContextTransitioning) {
    guard let parentVC = context.viewController(forKey: .from),
          let menuVC = context.viewController(forKey: .to)
    else {
      context.completeTransition(false)
      return
    }

    let containerView = context.containerView

    containerView.addSubview(menuVC.view)
    menuVC.view.frame = containerView.bounds

    // move menu view below parent view
    // TODO: check if not harmful to view hierarchy
    let containerSuperview = context.containerView.superview!
    let containerIndex = containerSuperview.subviews.firstIndex(of: containerView)!
    let containerIndexBefore = containerSuperview.subviews.index(before: containerIndex)
    containerSuperview.exchangeSubview(at: containerIndex, withSubviewAt: containerIndexBefore)

    // add shadow to parent view
    // TODO: embed in another view with shadow
    parentVC.view.layer.shadowColor = UIColor.separator.cgColor
    parentVC.view.layer.shadowOpacity = 0
    parentVC.view.layer.shadowOffset = .zero
    parentVC.view.layer.shadowRadius = 32

    // add border to parent view
    // TODO: embed in another view with border
    parentVC.view.layer.borderWidth = 1
    parentVC.view.layer.borderColor = UIColor.separator.cgColor
    parentVC.view.layer.cornerRadius = 0
    parentVC.view.layer.masksToBounds = false // TODO: mask to bounds when rounding corners

    // TODO: disable interactive present gesture in parent view

    // enable interactive dismiss gesture in parent view
    dismissInteractor.setup(
      view: parentVC.view,
      action: { parentVC.dismiss(animated: true) }
    )

    // TODO: investigate safe area and navigation bar height issues
    viewAnimator.animate(
      withDuration: transitionDuration(using: context),
      animations: {
        self.menuAnimator.animate(parentView: parentVC.view, to: 1)
      },
      completion: { _ in
        let isCancelled = context.transitionWasCancelled
        context.completeTransition(isCancelled == false)
      }
    )
  }
}
