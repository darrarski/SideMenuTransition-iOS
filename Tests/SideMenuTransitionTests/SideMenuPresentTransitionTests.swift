import XCTest
import Nimble

@testable import SideMenuTransition

final class SideMenuPresentTransitionTests: XCTestCase {
  var sut: SideMenuPresentTransition!
  private var dismissInteractor: MockSideMenuDismissalInteractor!
  private var menuAnimator: MockSideMenuAnimator!

  override func setUp() {
    dismissInteractor = MockSideMenuDismissalInteractor()
    menuAnimator = MockSideMenuAnimator()

    sut = SideMenuPresentTransition(
      dismissInteractor: dismissInteractor,
      menuAnimator: menuAnimator,
      viewAnimator: MockUIViewAnimator.self
    )
  }

  override func tearDown() {
    sut = nil
    dismissInteractor = nil
    menuAnimator = nil
  }

  func test_transitionDuration() {
    expect(self.sut.transitionDuration(using: nil)) == 0.25
  }

  func test_animateWithoutFromViewController() {
    let context = MockViewControllerContextTransitioning()
    context.mockViewControllerForKey[.from] = nil

    sut.animateTransition(using: context)
    expect(context.didCompleteTransition).to(beFalse())
  }

  func test_animateWithoutToViewController() {
    let context = MockViewControllerContextTransitioning()
    context.mockViewControllerForKey[.to] = nil

    sut.animateTransition(using: context)
    expect(context.didCompleteTransition).to(beFalse())
  }

  func test_AnimateTransition() {
    let fromViewController = UIViewController()
    let toViewController = UIViewController()
    let context = MockViewControllerContextTransitioning()

    context.mockViewControllerForKey[.from] = fromViewController
    context.mockViewControllerForKey[.to] = toViewController

    sut.animateTransition(using: context)

    let viewsWithTag = context.containerView.subviews.filter { $0.tag == SideMenuPresentTransition.fromViewTag }
    expect(viewsWithTag.count) == 1

    let fromView = viewsWithTag[0]
    expect(fromView).toNot(beNil())
    expect(fromView.layer.shadowRadius) == 32
    expect(fromView.layer.shadowOffset) == .zero
    expect(fromView.layer.shadowColor) == UIColor.separator.cgColor
    expect(self.sut.viewAnimator).to(beAKindOf(MockUIViewAnimator.Type.self))
    expect(self.menuAnimator.didAnimateToProgress) == 1
    expect(self.menuAnimator.didAnimateInContainerView) == context.containerView

    context.mockCancelTransition = false
    expect(context.didCompleteTransition).to(beTrue())
  }
}

private final class MockSideMenuDismissalInteractor: SideMenuDismissInteracting {
  var didSetupWithView: UIView?
  var interactionInProgress: Bool { fatalError() }
  var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

  func setup(view: UIView, action: @escaping () -> Void) {
    didSetupWithView = view
    action()
  }
}

private final class MockSideMenuAnimator: SideMenuAnimating {
  var didAnimateInContainerView: UIView?
  var didAnimateToProgress: CGFloat?

  func animate(in containerView: UIView, to progress: CGFloat) {
    didAnimateInContainerView = containerView
    didAnimateToProgress = progress
  }
}

private final class MockUIViewAnimator: SideMenuTransition.UIViewAnimating {
  static var didAnimateWithDuration: TimeInterval?

  static func animate(withDuration duration: TimeInterval,
                      animations: @escaping () -> Void,
                      completion: ((Bool) -> Void)?) {
    didAnimateWithDuration = duration
    animations()
    completion?(true)
  }
}

private final class MockViewControllerContextTransitioning: NSObject,
                                                            UIViewControllerContextTransitioning {
  let mockContainerView = UIView()
  var mockCancelTransition: Bool = false

  var didCompleteTransition: Bool?
  var containerView: UIView { mockContainerView }
  var transitionWasCancelled: Bool { mockCancelTransition }

  func completeTransition(_ didComplete: Bool) {
    didCompleteTransition = didComplete
  }

  var mockViewControllerForKey = [UITransitionContextViewControllerKey: UIViewController]()

  func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
    mockViewControllerForKey[key]
  }

  var isAnimated: Bool { fatalError() }
  var isInteractive: Bool { fatalError() }
  var targetTransform: CGAffineTransform { fatalError() }
  var presentationStyle: UIModalPresentationStyle { fatalError() }

  func cancelInteractiveTransition() {fatalError() }
  func pauseInteractiveTransition() { fatalError() }
  func finishInteractiveTransition() { fatalError() }
  func finalFrame(for vc: UIViewController) -> CGRect { fatalError() }
  func initialFrame(for vc: UIViewController) -> CGRect { fatalError() }
  func view(forKey key: UITransitionContextViewKey) -> UIView? { fatalError() }
  func updateInteractiveTransition(_ percentComplete: CGFloat) { fatalError() }
}
