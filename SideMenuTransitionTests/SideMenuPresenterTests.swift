import XCTest
import Nimble

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

    expect(self.presentInteractor.didSetupWithView).to(be(parent.view))

    presentInteractor.didSetupWithAction?()

    expect(self.menuViewController.modalPresentationStyle) == .overFullScreen
    expect(self.menuViewController.transitioningDelegate).to(be(sut))
    expect(parent.didPresentViewController).to(be(menuViewController))
    expect(parent.didPresentAnimated).to(beTrue())
  }

  func test_Present() {
    let parent = ParentViewController()
    sut.present(from: parent)
    expect(self.menuViewController.modalPresentationStyle) == .overFullScreen
    expect(self.menuViewController.transitioningDelegate).to(be(sut))
    expect(parent.didPresentAnimated).to(beTrue())
    expect(parent.didPresentViewController).to(be(menuViewController))
  }

  func test_animationControllerForPresenting() {
    let animationController = sut.animationController(forPresented: UIViewController(),
                                                      presenting: UIViewController(),
                                                      source: UIViewController())
    let sideMenuPresentTransition = animationController as? SideMenuPresentTransition
    expect(sideMenuPresentTransition).toNot(beNil())
    expect(sideMenuPresentTransition?.dismissInteractor as? MockSideMenuDismissalInteractor).to(be(dismissInteractor))
    expect(sideMenuPresentTransition?.menuAnimator as? MockSideMenuAnimator).to(be(menuAnimator))
    XCTAssertEqual(sideMenuPresentTransition?.viewAnimator is MockUIViewAnimator.Type, true)
  }

  func test_animationControllerForDismissing() {
    let animationController = sut.animationController(forDismissed: UIViewController())
    let sideMenuDismissTransition = animationController as? SideMenuDismissTransition
    expect(sideMenuDismissTransition).toNot(beNil())
    expect(sideMenuDismissTransition?.menuAnimator as? MockSideMenuAnimator).to(be(menuAnimator))
    expect(sideMenuDismissTransition?.viewAnimator).to(beAKindOf(MockUIViewAnimator.Type.self))
  }

  func test_InteractionForPresentationWhenInteractionIsInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    let controller = sut.interactionControllerForPresentation(using: animatedTransitioning)
    presentInteractor.interactionInProgress = true
    expect(controller).toNot(beNil())
    expect(controller).to(be(presentInteractor.percentDrivenInteractiveTransition))
  }

  func test_InteractionForDismissalWhenInteractionIsInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    let controller = sut.interactionControllerForDismissal(using: animatedTransitioning)
    dismissInteractor.interactionInProgress = true
    expect(controller).toNot(beNil())
    expect(controller).to(be(dismissInteractor.percentDrivenInteractiveTransition))
  }

  func test_InteractionForPresentationWhenInteractionIsNotInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    presentInteractor.interactionInProgress = false
    let controller = sut.interactionControllerForPresentation(using: animatedTransitioning)
    expect(controller).to(beNil())
  }

  func test_InteractionForDismissalWhenInteractionIsNotInProgress() {
    let animatedTransitioning = MockViewControllerAnimatedTransitioning()
    dismissInteractor.interactionInProgress = false
    let controller = sut.interactionControllerForDismissal(using: animatedTransitioning)
    expect(controller).to(beNil())
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
  var interactionInProgress: Bool = true
  var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

  func setup(view: UIView, action: @escaping () -> Void) {
    fatalError()
  }
}

private final class MockSideMenuAnimator: SideMenuAnimating {
  func animate(in containerView: UIView, to progress: CGFloat) {
    fatalError()
  }
}

private final class MockUIViewAnimator: SideMenuTransition.UIViewAnimating {
  static func animate(withDuration duration: TimeInterval,
                      animations: @escaping () -> Void,
                      completion: ((Bool) -> Void)?) {
    fatalError()
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
