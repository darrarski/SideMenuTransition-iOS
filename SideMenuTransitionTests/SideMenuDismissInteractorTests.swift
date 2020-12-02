import XCTest
import Nimble

@testable import SideMenuTransition

final class SideMenuDismissInteractorTests: XCTestCase {
  var sut: SideMenuDismissInteractor!
  private var percentDrivenInteractiveTransition: MockPercentDrivenInteractiveTransition!
  private var panGestureRecognizer: MockPanGestureRecognizer!

  override func setUp() {
    percentDrivenInteractiveTransition = MockPercentDrivenInteractiveTransition()
    panGestureRecognizer = MockPanGestureRecognizer()
    sut = SideMenuDismissInteractor()
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

    expect(view.gestureRecognizers?.count) == 1
    expect(view.gestureRecognizers?.first).to(be(panGestureRecognizer))
    expect(didSetTarget as? SideMenuDismissInteractor).to(be(sut))
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

    expect(self.sut.interactionInProgress).to(beFalse())
  }

  func test_ContainerViewWidthZeroShouldNotBeHandled() {
    let containerView = UIView()
    let view = UIView()
    containerView.addSubview(view)

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

    expect(self.sut.interactionInProgress).to(beFalse())
  }

  func test_panMoreThanHalfScreenShouldFinishTransition() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
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

    expect(self.sut.interactionInProgress).to(beTrue())
    expect(didCallAction).to(beTrue())

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedTranslation = CGPoint(x: -0.5 * (0.8 * containerView.frame.width), y: 0)
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    expect(self.panGestureRecognizer.didTranslationInView).to(be(view))
    expect(self.percentDrivenInteractiveTransition.didUpdateWithProgress) == 0.5

    panGestureRecognizer.mockedState = .ended
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(self.percentDrivenInteractiveTransition.didFinish).to(beTrue())
  }

  func test_panLessThanHalfScreenShouldCancelTransition() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
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

    expect(self.sut.interactionInProgress).to(beTrue())
    expect(didCallAction).to(beTrue())

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedTranslation = CGPoint(x: -0.4 * (0.8 * containerView.frame.width), y: 0)
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    expect(self.panGestureRecognizer.didTranslationInView).to(be(view))
    expect(self.percentDrivenInteractiveTransition.didUpdateWithProgress) == 0.4

    panGestureRecognizer.mockedState = .ended
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(self.percentDrivenInteractiveTransition.didCancel).to(beTrue())
  }

  func test_gestureBegan() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
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

    expect(self.sut.interactionInProgress).to(beTrue())
    expect(didCallAction).to(beTrue())
  }

  func test_gesturePossibleOrFailed() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedView = view
    panGestureRecognizer.mockedState = .possible
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(didCallAction).to(beNil())
  }

  func test_gestureEnded() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
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

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(didCallAction).to(beNil())
    expect(self.percentDrivenInteractiveTransition.didCancel).to(beTrue())
  }

  func test_gestureCancelled() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
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

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(didCallAction).to(beNil())
    expect(self.percentDrivenInteractiveTransition.didCancel).to(beTrue())
  }

  func test_gestureUnknown() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
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

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(didCallAction).to(beNil())
    expect(self.percentDrivenInteractiveTransition.didCancel).to(beTrue())
  }

  func test_gestureChanged() {
    let containerView = UIView(frame: .square100)
    let view = UIView()
    containerView.addSubview(view)

    var didSetTarget: Any?
    var didSetSelector: Selector?
    var didCallAction: Bool?

    panGestureRecognizer.mockedState = .changed
    panGestureRecognizer.mockedView = view
    panGestureRecognizer.mockedTranslation = CGPoint(x: -(containerView.frame.width * 0.8), y: 0)
    sut.panGestureRecognizerFactory = { target, selector in
      didSetTarget = target
      didSetSelector = selector
      return self.panGestureRecognizer
    }

    sut.setup(view: view) { didCallAction = true }
    (didSetTarget as? NSObject)!.perform(didSetSelector, with: panGestureRecognizer)

    expect(self.sut.interactionInProgress).to(beFalse())
    expect(didCallAction).to(beNil())
    expect(self.percentDrivenInteractiveTransition.didUpdateWithProgress) == 1
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
    set { fatalError() }
  }
}

private extension CGSize {
  static let square100 = Self.init(width: 100, height: 100)
}

private extension CGRect {
  static let square100 = Self.init(origin: .zero, size: .square100)
}
