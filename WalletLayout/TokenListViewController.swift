//
//  TokenListViewController.swift
//  WalletLayout
//
//  Created by kidnapper on 2020/8/27.
//  Copyright © 2020 andrew. All rights reserved.
//

import UIKit

private struct UX {
    static let cardOffset: CGFloat = 41
}

class TokenListViewController: UIViewController {

    private lazy var refreshControl: UIRefreshControl = {
        let control = UIRefreshControl()
        control.addTarget(self, action: #selector(refreshCard), for: .valueChanged)
        return control
    }()

    private var useCustomLayout: Bool = true
    private var isScrollToTop: Bool = false

    var offsetForCollectionViewCellBeingMoved: CGPoint = .zero
    var cellBeenDragged: EditCryptoCardCell?

    var dataSource: [CardModel] = [
        CardModel(movable: true, cardTitle: "Ethereum", color: .systemYellow),
        CardModel(movable: true, cardTitle: "Tron", color: .systemRed),
        CardModel(movable: false, cardTitle: "Flow", color: .systemPurple),
        CardModel(movable: false, cardTitle: "Bitcoin", color: .gray),
        CardModel(movable: false, cardTitle: "Crypto.com", color: .systemOrange)
    ]

    private lazy var flowLayout: WalletFlowLayout = WalletFlowLayout(delegate: self)

    private lazy var collectionView: UICollectionView = {
        let collectionView: UICollectionView
        if useCustomLayout {
            collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: flowLayout)
        } else {
            collectionView = UICollectionView(frame: .zero,
                                              collectionViewLayout: UICollectionViewFlowLayout())
        }
        let types: [UICollectionViewCell.Type] = [
            CryptoCardCell.self,
            EditCryptoCardCell.self
        ]
        types.forEach {
            collectionView.register($0, forCellWithReuseIdentifier: NSStringFromClass($0))
        }
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .white
        collectionView.showsVerticalScrollIndicator = false
        collectionView.refreshControl = refreshControl
        collectionView.backgroundColor = .systemGray
        return collectionView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalTo(view.safeAreaLayoutGuide)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addGesture()
    }

    private func addGesture() {
        if useCustomLayout {
            let longPressGesture: UILongPressGestureRecognizer = .init(target: self, action: #selector(handleLongPressGesture(recognizer:)))
            longPressGesture.minimumPressDuration = 0.3
            longPressGesture.delegate = self
            collectionView.addGestureRecognizer(longPressGesture)
        } else {
            let gesture: UILongPressGestureRecognizer = .init(target: self, action: #selector(handleGesture(recognizer:)))
            gesture.delegate = self
            collectionView.addGestureRecognizer(gesture)
        }

    }

    @objc
    private func purchaseOnClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "test", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }

    @objc
    private func refreshCard() {
        collectionView.isUserInteractionEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.refreshControl.endRefreshing()
            self.collectionView.isUserInteractionEnabled = true
            self.collectionView.reloadData()
        }
    }

    @objc
    private func animateLayout() {
        useCustomLayout.toggle()
        if useCustomLayout {
            collectionView.setCollectionViewLayout(flowLayout, animated: true)
        } else {
            collectionView.setCollectionViewLayout(UICollectionViewFlowLayout(), animated: true)
        }
    }

    @objc
    private func handleGesture(recognizer: UILongPressGestureRecognizer) {

        guard let selectedIndexPath = self.collectionView.indexPathForItem(at: recognizer.location(in: recognizer.view)),
            let cell: EditCryptoCardCell = collectionView.cellForItem(at: selectedIndexPath) as? EditCryptoCardCell else {
                cellBeenDragged?.updateStyle(style: .normal)
                collectionView.endInteractiveMovement()
                return
        }
        switch recognizer.state {
        case .began:
            guard cell.canDrag(by: recognizer.location(in: cell)) else { return }

            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)

            // This is the class variable I mentioned above
            offsetForCollectionViewCellBeingMoved = offsetOfTouchFrom(recognizer: recognizer, inCell: cell)

            // This is the vanilla location of the touch that alone would make the cell's center snap to your touch location
            var location = recognizer.location(in: collectionView)

            /* These two lines add the offset calculated a couple lines up to
             the normal location to make it so you can drag from any part of the
             cell and have it stay where your finger is. */

            location.x += offsetForCollectionViewCellBeingMoved.x
            location.y += offsetForCollectionViewCellBeingMoved.y

            collectionView.updateInteractiveMovementTargetPosition(location)

            guard let selectedIndexPath = self.collectionView
                .indexPathForItem(at: recognizer
                    .location(in: self.collectionView)) else { break }
            collectionView.beginInteractiveMovementForItem(at: selectedIndexPath)

        case .changed:
            //            collectionView.updateInteractiveMovementTargetPosition(offsetOfTouchFrom(recognizer: gesture, inCell: cell))
            //
            //            var location = recognizer.location(in: collectionView)
            //
            //            location.x += offsetForCollectionViewCellBeingMoved.x
            //            location.y += offsetForCollectionViewCellBeingMoved.y
            //
            //            collectionView.updateInteractiveMovementTargetPosition(location)

            var gesturePosition = recognizer.location(in: recognizer.view!)
            gesturePosition.x = collectionView.center.x


            collectionView.updateInteractiveMovementTargetPosition(recognizer.location(in: recognizer.view))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }

    @objc
    private func handleLongPressGesture(recognizer: UILongPressGestureRecognizer) {
        let location: CGPoint = recognizer.location(in: collectionView)
        guard let locationIndexPath: IndexPath = collectionView.indexPathForItem(at: location),
            let cell: CryptoCardCell = collectionView.cellForItem(at: locationIndexPath) as? CryptoCardCell else { return }

        func animate(ended: Bool) {
            UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseInOut], animations: {
                if ended {
                    cell.transform = .identity
                } else {
                    cell.transform = .init(translationX: 0, y: -20)
                }
            }, completion: { finished in

            })
        }

        switch recognizer.state {
        case .began:
            animate(ended: false)
        case .ended,
             .cancelled,
             .changed:
            animate(ended: true)
        default:
            ()
        }
    }

    private func offsetOfTouchFrom(recognizer: UIGestureRecognizer, inCell cell: UICollectionViewCell) -> CGPoint {

        let locationOfTouchInCell = recognizer.location(in: cell)

        let cellCenterX = cell.frame.width / 2
        let cellCenterY = cell.frame.height / 2

        let cellCenter = CGPoint(x: cellCenterX, y: cellCenterY)

        var offSetPoint = CGPoint.zero

        offSetPoint.y = cellCenter.y - locationOfTouchInCell.y
        offSetPoint.x = cellCenter.x - locationOfTouchInCell.x

        return offSetPoint

    }

}

extension TokenListViewController: UICollectionViewDataSource, WalletFlowLayoutDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count * 5
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if useCustomLayout {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(CryptoCardCell.self), for: indexPath)
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(EditCryptoCardCell.self), for: indexPath)
            (cell as? EditCryptoCardCell)?.updateStyle(style: dataSource[indexPath.item].movable ? .normal : .disable)
        }
        cell.contentView.backgroundColor = dataSource[indexPath.item % 5].color
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if useCustomLayout {
            cell.layer.zPosition = CGFloat(indexPath.item)
            if indexPath.item > 0 {
                cell.layer.shadowColor = UIColor.black.cgColor
                cell.layer.shadowOffset = .init(width: 0, height: -1)
                cell.layer.shadowPath = UIBezierPath(roundedRect: cell.layer.bounds, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 10, height: 10)).cgPath
                cell.layer.shadowRadius = 0.5
                cell.layer.shadowOpacity = 0.15
            }

            let numberOfItems = self.collectionView(collectionView, numberOfItemsInSection: indexPath.section)
            if indexPath.item == max(numberOfItems - 1, 0) {
                (cell as? CryptoCardCell)?.addAdditionalShadowLayer()
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionViewLayout == flowLayout {
            return CGSize(width: collectionView.bounds.width - 30,
                          height: (collectionView.bounds.width - 30) / 16 * 10)
        } else {
            return CGSize(width: collectionView.bounds.width,
                          height: 126)
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionViewLayout == flowLayout {
            return 10
        } else {
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionViewLayout == flowLayout {
            return .init(top: 40, left: 15, bottom: 50, right: 15)
        } else {
            return .zero
        }
    }

    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        if dataSource[indexPath.item].movable {
            cellBeenDragged = collectionView.cellForItem(at: indexPath) as? EditCryptoCardCell
        }
        return dataSource[indexPath.item].movable
    }

    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {

        let model: CardModel = dataSource.remove(at: sourceIndexPath.item)
        dataSource.insert(model, at: destinationIndexPath.item)

    }

    func collectionView(_ collectionView: UICollectionView, targetIndexPathForMoveFromItemAt originalIndexPath: IndexPath, toProposedIndexPath proposedIndexPath: IndexPath) -> IndexPath {
        if originalIndexPath.item == 0 {
            if proposedIndexPath.item + 1 < dataSource.count {
                if dataSource[proposedIndexPath.item + 1].movable {
                    return proposedIndexPath
                } else {
                    if proposedIndexPath.item > 0 {
                        if dataSource[proposedIndexPath.item - 1].movable {
                            return proposedIndexPath
                        } else {
                            return originalIndexPath
                        }
                    } else {
                        return proposedIndexPath
                    }
                }
            } else {
                if dataSource[proposedIndexPath.item - 1].movable {
                    return proposedIndexPath
                } else {
                    return originalIndexPath
                }
            }
        } else {
            //            let cell: EditCryptoCardCell? = collectionView.cellForItem(at: proposedIndexPath) as? EditCryptoCardCell
            if dataSource[proposedIndexPath.item].movable {
                cellBeenDragged?.updateStyle(style: .normal)
                return proposedIndexPath
            } else {
                cellBeenDragged?.updateStyle(style: .dragDisable)
                return originalIndexPath
                //                return IndexPath(item: dataSource.enumerated().first { !$1.movable }?.0 ?? 0,
                //                                 section: proposedIndexPath.section)
            }
        }

    }



    //    func collectionView(_ collectionView: UICollectionView, transitionLayoutForOldLayout fromLayout: UICollectionViewLayout, newLayout toLayout: UICollectionViewLayout) -> UICollectionViewTransitionLayout {
    //
    //    }

    // MARK: - WalletFlowLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, offsetFromPreviousCardTopAt indexPath: IndexPath) -> CGFloat {
        if indexPath.item == 0 {
            return 0
        }
        return UX.cardOffset
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: WalletFlowLayout, distanceToVisualTop: CGFloat, at indexPath: IndexPath) {
        guard indexPath.item != 0 else { return }
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.layer.shadowOpacity = Float(0.15 * min(distanceToVisualTop, UX.cardOffset) / UX.cardOffset)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        //        if velocity.y < 0 {
        //            navigationController?.setNavigationBarHidden(false, animated: true)
        //        } else {
        //            navigationController?.setNavigationBarHidden(true, animated: true)
        //        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isScrollToTop else { return }
        if scrollView.contentOffset.y < 10 {
            navigationController?.setNavigationBarHidden(false, animated: true)
        } else {
            navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }

    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        isScrollToTop = false
    }


    func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        navigationController?.setNavigationBarHidden(false, animated: true)
        isScrollToTop = true
        return true
    }

}

extension TokenListViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive press: UIPress) -> Bool {
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive event: UIEvent) -> Bool {
        return true
    }

}
