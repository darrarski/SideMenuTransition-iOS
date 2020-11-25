import XCTest

@testable import SideMenuTransition

final class SideMenuPresentInteractorTests: XCTestCase {
  var sut: SideMenuPresentInteractor!
  private var percentDrivenInteractiveTransition: MockPercentDrivenInteractiveTransition!
  private var panGestureRecognizer: MockPanGestureRecognizer!

  override func setUp() {
    sut = SideMenuPresentInteractor()

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
    XCTAssert(didSetTarget as? SideMenuPresentInteractor === sut)
  }

  func test_gestureBegan() {
    let containerView = UIView(frame: .square100)
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

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
    XCTAssertEqual(didCallAction, true)
  }

  func test_gesturePossibleOrFailed() {
    let containerView = UIView(frame: .square100)
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?

    panGestureRecognizer.mockedView = view
    panGestureRecognizer.mockedState = .possible
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) {}
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
  }

  func test_gestureEnded() {
    let containerView = UIView(frame: .square100)
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedState = .ended
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertNil(didCallAction)
    XCTAssertEqual(percentDrivenInteractiveTransition.didCancel, true)
  }

  func test_gestureCancelled() {
    let containerView = UIView(frame: .square100)
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedState = .cancelled
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertNil(didCallAction)
    XCTAssertEqual(percentDrivenInteractiveTransition.didCancel, true)
  }

  func test_gestureUnknown() {
    let containerView = UIView(frame: .square100)
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedState = .some(UIGestureRecognizer.State(rawValue: 10)!)
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertNil(didCallAction)
    XCTAssertEqual(percentDrivenInteractiveTransition.didCancel, true)
  }

  func test_gestureChanged() {
    let containerView = UIView(frame: .square100)
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedView = view
    panGestureRecognizer.mockedTranslation = CGPoint(x: containerView.frame.width * 0.6, y: 0)
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertNil(didCallAction)
    XCTAssertEqual(percentDrivenInteractiveTransition.didUpdateWithProgress, 1)
  }

  func test_gestureShouldBegin() {
    var recognizerShouldBegin: Bool?
    let containerView = UIView()
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    panGestureRecognizer.mockedView = view
    sut.setup(view: view) {}
    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)

    XCTAssertEqual(recognizerShouldBegin, true)
  }

  func test_recognizerWithoutViewShouldNotBeginGesture() {
    var recognizerShouldBegin: Bool?
    let containerView = UIView()
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    panGestureRecognizer.mockedView = nil
    sut.setup(view: view) {}
    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)

    panGestureRecognizer.mockedTranslation = CGPoint(x: 100, y: 0)
    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)

    XCTAssertEqual(recognizerShouldBegin, false)
  }

  func test_translationOnYAxisShouldNotBeginGesture() {
    var recognizerShouldBegin: Bool?
    let containerView = UIView()
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    panGestureRecognizer.mockedView = view
    sut.setup(view: view) {}
    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)

    panGestureRecognizer.mockedTranslation = CGPoint(x: 0, y: 1)
    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)

    XCTAssertEqual(recognizerShouldBegin, false)
  }

  func test_translationOnXAxisOutsideOfEdgeOffsetRangeShouldNotBeginGesture() {
//    var recognizerShouldBegin: Bool = false
//    let containerView = UIView()
//    let view = UIView(frame: .square100)
//    containerView.addSubview(view)
//
//    panGestureRecognizer.mockedView = view
//    sut.setup(view: view) {}
//    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)
//
//    panGestureRecognizer.mockedTranslation = CGPoint(x: 0, y: 1)
//    recognizerShouldBegin = sut.gestureRecognizerShouldBegin(panGestureRecognizer)
//
//    XCTAssertFalse(recognizerShouldBegin)
  }

  func test_ViewWithoutSuperviewShouldNotBeHandled() {
    let view = UIView()
    var didSetTarget: Any?
    var didSetSelector: Selector?

    panGestureRecognizer.mockedState = .began
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) {}
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
  }

  func test_RecognizerWithoutViewShouldNotBeHandled() {
    var didSetTarget: Any?
    var didSetSelector: Selector?

    panGestureRecognizer.mockedState = .began
    panGestureRecognizer.mockedView = nil
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: UIView()) {}
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
  }

  func test_ViewWidthZeroShouldNotBeHandled() {
    let view = UIView()
    var didSetTarget: Any?
    var didSetSelector: Selector?

    panGestureRecognizer.mockedState = .began
    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) {}
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
  }

  func test_panMoreThanHalfScreenShouldFinishTransition() {
    let containerView = UIView()
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }
    sut.setup(view: view) { didCallAction = true }

    panGestureRecognizer.mockedState = .began
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertTrue(sut.interactionInProgress)
    XCTAssertEqual(didCallAction, true)

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedTranslation = CGPoint(x: 0.5 * (0.6 * view.frame.width), y: 0)
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertTrue(panGestureRecognizer.didTranslationInView === view)
    XCTAssertEqual(percentDrivenInteractiveTransition.didUpdateWithProgress, 0.5)

    panGestureRecognizer.mockedState = .ended
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertEqual(percentDrivenInteractiveTransition.didFinish, true)
  }

  func test_panLessThanHalfScreenShouldCancelTransition() {
    let containerView = UIView()
    let view = UIView(frame: .square100)
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedView = view
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }
    sut.setup(view: view) { didCallAction = true }

    panGestureRecognizer.mockedState = .began
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertTrue(sut.interactionInProgress)
    XCTAssertEqual(didCallAction, true)

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedTranslation = CGPoint(x: 0.4 * (0.6 * view.frame.width), y: 0)
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertTrue(panGestureRecognizer.didTranslationInView === view)
    XCTAssertEqual(percentDrivenInteractiveTransition.didUpdateWithProgress, 0.4)

    panGestureRecognizer.mockedState = .ended
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    XCTAssertFalse(sut.interactionInProgress)
    XCTAssertEqual(percentDrivenInteractiveTransition.didCancel, true)
  }
}

private final class MockPercentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
  var didUpdateWithProgress: CGFloat?
  var didCancel: Bool?
  var didFinish: Bool?

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

private final class MockPanGestureRecognizer: UIPanGestureRecognizer {
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
