import XCTest

@testable import SideMenuTransition

final class SideMenuPresenterTests: XCTestCase {
  var sut: SideMenuPresenter!
  private let presentInteractor = MockSideMenuPresentInteractor()
  private let dismissInteractor = MockSideMenuDismissalInteractor()
  private let menuAnimator = MockSideMenuAnimator()
  private let menuViewController = UIViewController()

  override func setUp() {
    sut = SideMenuPresenter(
      menuViewControllerFactory: { self.menuViewController },
      presentInteractor: presentInteractor,
      dismissInteractor: dismissInteractor,
      menuAnimator: menuAnimator,
      viewAnimator: UIView.self
    )
  }

  override func tearDown() {
    sut = nil
  }

  func test_setupAndPresent() {
    let parent = UIViewController()
    sut.setup(in: parent)
    XCTAssert(parent.view === presentInteractor.didSetupWithView)
  }
}

private final class MockSideMenuPresentInteractor: SideMenuPresentInteracting {
  var didSetupWithView: UIView?
  var interactionInProgress: Bool { true }
  var percentDrivenInteractiveTransition = UIPercentDrivenInteractiveTransition()

  func setup(view: UIView, action: @escaping () -> Void) {
    didSetupWithView = view
    action()
  }
}

private final class MockSideMenuDismissalInteractor: SideMenuDismissInteracting {
  var didSetupWithView: UIView?
  var interactionInProgress: Bool { true }
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
