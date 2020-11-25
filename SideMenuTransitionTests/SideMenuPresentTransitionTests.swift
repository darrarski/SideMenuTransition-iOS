//
//  SideMenuPresentTransitionTests.swift
//  SideMenuTransitionTests
//
//  Created by Bruno Muniz Azevedo Filho on 11/24/20.
//

import XCTest

@testable import SideMenuTransition

final class SideMenuPresentTransitionTests: XCTestCase {
  var sut: SideMenuPresentTransition!
  private let dismissInteractor = MockSideMenuDismissalInteractor()
  private let menuAnimator = MockSideMenuAnimator()

  override func setUp() {
    sut = SideMenuPresentTransition(
      dismissInteractor: dismissInteractor,
      menuAnimator: menuAnimator,
      viewAnimator: UIView.self
    )
  }

  override func tearDown() {
    sut = nil
  }

  func test_transitionDuration() {
    XCTAssertEqual(sut.transitionDuration(using: nil), 0.25)
  }

  func test_animateWithoutFromViewController() {
    let context = MockViewControllerContextTransitioning()
    context.mockViewControllerForKey[.from] = nil

    sut.animateTransition(using: context)

    XCTAssert(context.didCompleteTransition == false)
  }

  func test_animateWithoutToViewController() {
    let context = MockViewControllerContextTransitioning()
    context.mockViewControllerForKey[.to] = nil

    sut.animateTransition(using: context)

    XCTAssert(context.didCompleteTransition == false)
  }

  func test_() {
    let fromViewController = UIViewController()
    let toViewController = UIViewController()
    let context = MockViewControllerContextTransitioning()

    context.mockViewControllerForKey[.from] = fromViewController
    context.mockViewControllerForKey[.to] = toViewController

//    sut.animateTransition(using: context)
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

private final class MockViewControllerContextTransitioning: NSObject,
                                                            UIViewControllerContextTransitioning {
  var containerView: UIView {
    fatalError()
  }

  var isAnimated: Bool {
    fatalError()
  }

  var isInteractive: Bool {
    fatalError()
  }

  var transitionWasCancelled: Bool {
    fatalError()
  }

  var presentationStyle: UIModalPresentationStyle {
    fatalError()
  }

  func updateInteractiveTransition(_ percentComplete: CGFloat) {
    fatalError()
  }

  func finishInteractiveTransition() {
    fatalError()
  }

  func cancelInteractiveTransition() {
    fatalError()
  }

  func pauseInteractiveTransition() {
    fatalError()
  }

  var didCompleteTransition: Bool?

  func completeTransition(_ didComplete: Bool) {
    didCompleteTransition = didComplete
  }

  var mockViewControllerForKey = [UITransitionContextViewControllerKey: UIViewController]()

  func viewController(forKey key: UITransitionContextViewControllerKey) -> UIViewController? {
    mockViewControllerForKey[key]
  }

  func view(forKey key: UITransitionContextViewKey) -> UIView? {
    fatalError()
  }

  var targetTransform: CGAffineTransform {
    fatalError()
  }

  func initialFrame(for vc: UIViewController) -> CGRect {
    fatalError()
  }

  func finalFrame(for vc: UIViewController) -> CGRect {
    fatalError()
  }
}
