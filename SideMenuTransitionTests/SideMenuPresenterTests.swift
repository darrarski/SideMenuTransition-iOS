import XCTest

@testable import SideMenuTransition

final class SideMenuPresenterTests: XCTestCase {
  var sut: SideMenuPresenter!
  private var presentInteractor: MockSideMenuPresentInteractor!
  private var dismissInteractor: MockSideMenuDismissalInteractor!
  private var menuAnimator: MockSideMenuAnimator!
  private var menuViewController: UIViewController!

  override func setUp() {
    presentInteractor = MockSideMenuPresentInteractor()
    dismissInteractor = MockSideMenuDismissalInteractor()
    menuAnimator = MockSideMenuAnimator()
    menuViewController = UIViewController()

    sut = SideMenuPresenter(
      menuViewControllerFactory: { self.menuViewController },
      presentInteractor: presentInteractor,
      dismissInteractor: dismissInteractor,
      menuAnimator: menuAnimator,
      viewAnimator: MockUIViewAnimator.self
    )
  }

  override func tearDown() {
    sut = nil
    menuViewController = nil
    presentInteractor = nil
    dismissInteractor = nil
    menuAnimator = nil
  }

  func test_SetupAndPresent() {
    let parent = ParentViewController()
    sut.setup(in: parent)

    XCTAssert(presentInteractor.didSetupWithView === parent.view)

    presentInteractor.didSetupWithAction?()

    XCTAssertEqual(menuViewController.modalPresentationStyle, .overFullScreen)
    XCTAssert(menuViewController.transitioningDelegate === sut)
    XCTAssert(parent.didPresentViewController === menuViewController)
    XCTAssert(parent.didPresentAnimated == true)
  }

  func test_Present() {
    let parent = ParentViewController()

    sut.present(from: parent)

    XCTAssertEqual(menuViewController.modalPresentationStyle, .overFullScreen)
    XCTAssert(menuViewController.transitioningDelegate === sut)
    XCTAssert(parent.didPresentViewController === menuViewController)
    XCTAssert(parent.didPresentAnimated == true)
  }

  func test_animationControllerForPresenting() {
    let animationController = sut.animationController(forPresented: UIViewController(),
                                                      presenting: UIViewController(),
                                                      source: UIViewController())

    let sideMenuPresentTransition = animationController as? SideMenuPresentTransition

    XCTAssertNotNil(sideMenuPresentTransition)
    XCTAssert((sideMenuPresentTransition?.dismissInteractor as? MockSideMenuDismissalInteractor) === dismissInteractor)
    XCTAssert((sideMenuPresentTransition?.menuAnimator as? MockSideMenuAnimator) === menuAnimator)
    XCTAssertTrue(sideMenuPresentTransition?.viewAnimator is MockUIViewAnimator.Type)
  }

  func test_animationControllerForDismissing() {
    let animationController = sut.animationController(forDismissed: UIViewController())
    let sideMenuDismissTransition = animationController as? SideMenuDismissTransition

    XCTAssertNotNil(sideMenuDismissTransition)
    XCTAssert((sideMenuDismissTransition?.menuAnimator as? MockSideMenuAnimator) === menuAnimator)
    XCTAssertTrue(sideMenuDismissTransition?.viewAnimator is MockUIViewAnimator.Type)
  }

  func test_InteractionForPresentationWhenInteractionIsInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    presentInteractor.interactionInProgress = true
    let controller = sut.interactionControllerForPresentation(using: animatedTransitioning)

    XCTAssertNotNil(controller)
    XCTAssert(controller === presentInteractor.percentDrivenInteractiveTransition)
  }

  func test_InteractionForDismissalWhenInteractionIsInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    dismissInteractor.interactionInProgress = true
    let controller = sut.interactionControllerForDismissal(using: animatedTransitioning)

    XCTAssertNotNil(controller)
    XCTAssert(controller === dismissInteractor.percentDrivenInteractiveTransition)
  }

  func test_InteractionForPresentationWhenInteractionIsNotInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    presentInteractor.interactionInProgress = false
    let controller = sut.interactionControllerForPresentation(using: animatedTransitioning)

    XCTAssertNil(controller)
  }

  func test_InteractionForDismissalWhenInteractionIsNotInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    dismissInteractor.interactionInProgress = false
    let controller = sut.interactionControllerForDismissal(using: animatedTransitioning)

    XCTAssertNil(controller)
  }
}

private final class MockViewControllerAnimatedTransitioning: NSObject,
                                                             UIViewControllerAnimatedTransitioning {
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    fatalError()
  }

  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    fatalError()
  }
}

private final class MockSideMenuPresentInteractor: SideMenuPresentInteracting {
  var didSetupWithView: UIView?
  var didSetupWithAction: (() -> Void)?
  var interactionInProgress: Bool = true
  var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

  func setup(view: UIView, action: @escaping () -> Void) {
    didSetupWithView = view
    didSetupWithAction = action
  }
}

private final class MockSideMenuDismissalInteractor: SideMenuDismissInteracting {
  var didSetupWithView: UIView?
  var didSetupWithAction: (() -> Void)?
  var interactionInProgress: Bool = true
  var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

  func setup(view: UIView, action: @escaping () -> Void) {
    didSetupWithView = view
    didSetupWithAction = action
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
  }
}

private final class ParentViewController: UIViewController {
  var didPresentViewController: UIViewController?
  var didPresentAnimated: Bool?

  override func present(
    _ viewControllerToPresent: UIViewController,
    animated flag: Bool,
    completion: (() -> Void)? = nil
  ) {
    didPresentViewController = viewControllerToPresent
    didPresentAnimated = flag
  }
}
