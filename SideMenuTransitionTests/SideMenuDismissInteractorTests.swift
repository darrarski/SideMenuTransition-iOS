import XCTest

@testable import SideMenuTransition

final class SideMenuDismissInteractorTests: XCTestCase {
  var sut: SideMenuDismissInteractor!
  private var percentDrivenInteractiveTransition: MockPercentDrivenInteractiveTransition!
  private var panGestureRecognizer: MockPanGestureRecognizer!

  override func setUp() {
    sut = SideMenuDismissInteractor()

    percentDrivenInteractiveTransition = MockPercentDrivenInteractiveTransition()
    panGestureRecognizer = MockPanGestureRecognizer()
    sut.percentDrivenInteractiveTransition = percentDrivenInteractiveTransition
  }

  override func tearDown() {
    sut = nil
    percentDrivenInteractiveTransition = nil
    panGestureRecognizer = nil
  }

  func test_setupGestureRecognizer() {
    let view = UIView()
    var didSetTarget: Any?

    sut.panGestureRecognizerFactory = { target, _ in
      didSetTarget = target
      return self.panGestureRecognizer
    }

    sut.setup(view: view) {}

    XCTAssertEqual(view.gestureRecognizers?.count, 1)
    XCTAssert(view.gestureRecognizers?.first === self.panGestureRecognizer)
    XCTAssert(didSetTarget as? SideMenuDismissInteractor === sut)
  }

  func test_gestureBegan() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool = false

    panGestureRecognizer.mockedState = .began
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertTrue(sut.interactionInProgress)
    XCTAssertTrue(didCallAction)
  }

  func test_gesturePossibleOrFailed() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool = false

    panGestureRecognizer.mockedView = view
    panGestureRecognizer.mockedState = .possible
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertFalse(didCallAction)
  }

  func test_gestureEnded() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didNotCallAction: Bool = true

    panGestureRecognizer.mockedState = .ended
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didNotCallAction = false }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertTrue(didNotCallAction)
    XCTAssertTrue(percentDrivenInteractiveTransition.didCancel)
  }

  func test_gestureCancelled() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didNotCallAction: Bool = true

    panGestureRecognizer.mockedState = .cancelled
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didNotCallAction = false }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertTrue(didNotCallAction)
    XCTAssertTrue(percentDrivenInteractiveTransition.didCancel)
  }

  func test_gestureUnknown() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didNotCallAction: Bool = true

    panGestureRecognizer.mockedState = .some(UIGestureRecognizer.State(rawValue: 10)!)
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didNotCallAction = false }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertTrue(didNotCallAction)
    XCTAssertTrue(percentDrivenInteractiveTransition.didCancel)
  }

  func test_gestureChanged() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didNotCallAction: Bool = true

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedView = view
    panGestureRecognizer.mockedTranslation = CGPoint(x: -(containerView.frame.width * 0.8), y: 0)
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didNotCallAction = false }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertTrue(didNotCallAction)
    XCTAssertEqual(percentDrivenInteractiveTransition.didUpdateWithProgress, 1)
  }
}

private class MockPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
  var didUpdateWithProgress: CGFloat?
  var didCancel: Bool = false
  var didFinish: Bool = false

  override func update(_ percentComplete: CGFloat) {
    didUpdateWithProgress = percentComplete
  }

  override func cancel() {
    didCancel = true
  }

  override func finish() {
    didFinish = true
  }
}

private class MockPanGestureRecognizer: UIPanGestureRecognizer {
  var mockedView: UIView?
  var mockedState: UIGestureRecognizer.State!
  var mockedTranslation: CGPoint = .zero
  var didTranslationInView: UIView?

  override var view: UIView? {
    mockedView
  }

  override func translation(in view: UIView?) -> CGPoint {
    didTranslationInView = view
    return mockedTranslation
  }

  override var state: UIGestureRecognizer.State {
    get { mockedState }
    set { mockedState = newValue }
  }
}

private extension CGSize {
  static let square100 = Self.init(width: 100, height: 100)
}

private extension CGRect {
  static let square100 = Self.init(origin: .zero, size: .square100)
}
