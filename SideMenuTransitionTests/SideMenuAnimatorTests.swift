import XCTest

@testable import SideMenuTransition

final class SideMenuAnimatorTests: XCTestCase {
  var sut: SideMenuAnimator!

  override func  setUp() {
    sut = SideMenuAnimator()
  }

  override func tearDown() {
    sut = nil
  }

  func test_animateWithFullProgress() {
    let containerView = MockContainerView()
    let progress: CGFloat = 1

    sut.animate(in: containerView, to: progress)

    XCTAssertEqual(containerView.snapshotView.layer.cornerRadius, 48)
    XCTAssertEqual(containerView.fromView.layer.shadowOpacity, 1)

    let transform = CGAffineTransform.identity.translatedBy(x: 70, y: 0)
      .scaledBy(x: 0.8, y: 0.8)

    XCTAssertEqual(containerView.fromView.transform, transform)
  }

  func test_animateWithNoProgress() {
    let containerView = MockContainerView()
    let progress: CGFloat = 0

    sut.animate(in: containerView, to: progress)

    XCTAssertEqual(containerView.snapshotView.layer.cornerRadius, 0)
    XCTAssertEqual(containerView.fromView.layer.shadowOpacity, 0)
    XCTAssertEqual(containerView.fromView.transform, CGAffineTransform.identity)
  }

  func test_animateWithHalfProgress() {
    let containerView = MockContainerView()
    let progress: CGFloat = 0.5

    sut.animate(in: containerView, to: progress)

    XCTAssertEqual(containerView.snapshotView.layer.cornerRadius, 24)
    XCTAssertEqual(containerView.fromView.layer.shadowOpacity, 0.5)

    let transform = CGAffineTransform.identity.translatedBy(x: 35, y: 0)
      .scaledBy(x: 0.9, y: 0.9)

    XCTAssertEqual(containerView.fromView.transform, transform)
  }
}

private final class MockContainerView: UIView {
  let fromView = UIView()
  let snapshotView = UIView()

  init() {
    let size = CGSize(width: 100, height: 100)
    let frame = CGRect(origin: .zero, size: size)
    super.init(frame: frame)

    addSubview(fromView)
    fromView.addSubview(snapshotView)
    fromView.tag = SideMenuPresentTransition.fromViewTag
  }

  required init?(coder: NSCoder) { nil }
}
