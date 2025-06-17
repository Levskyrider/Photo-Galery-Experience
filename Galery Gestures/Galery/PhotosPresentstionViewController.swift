//
//  TestPhotoGaleryViewController.swift
//  GaleryProject
//
//  Created by Dmitro Levkutnyk on 31.01.2025.
//

//TODO: - когда скрываю фотку - изменять прозрачность у PhotoViewController
//TODO: - Менеджмент текущей фотки

import UIKit

fileprivate enum Defaults {
  static let backgroundColor = UIColor.black
}

class PhotosPresentstionViewController: UIViewController {
  
  weak var parentGridViewController: PhotoGridViewController?
  
  //TODO: - Need View model
  private var images: [UIImage] = []
  var currentIndex: Int = 0
  
  //MARK: - UI
  private var pageViewController: UIPageViewController!
  private var thumbnailCollectionView: UICollectionView!
  
  
  //MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.clear
    
    
    setupPageViewController()
    setupThumbnailCollectionView()
    
    
    
    setupPanGesture()
    
    setupOpenThumbnailGesture()
    //TODO: - перенести в dismiss кнопку
   // setupDismissGesture()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    //MARK: - проскралливать thumbnail до нужного места
    thumbnailCollectionView.isHidden = true
    scrollToThumbnail(at: currentIndex, animated: false)
  }
  
  //TODO: - Dismiss, add close button
  @objc private func handleDismiss() {
    closeGalleryAnimation()
  }
  
  private func setupDismissGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
    view.addGestureRecognizer(tap)
  }
  
  //MARK: - Tap on photo and open thumbnail
  @objc private func handleTapOnPhoto() {
    thumbnailCollectionView.isHidden.toggle()
  }
  
  private func setupOpenThumbnailGesture() {
    let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapOnPhoto))
    view.addGestureRecognizer(tap)
  }
  
  //TODO: - может быть перенести конфигурацию в init
  
  func configure(with images: [UIImage], startIndex: Int = 0) {
    self.images = images
    self.currentIndex = startIndex
  }
  
  //MARK: - Page Control
  // Настраиваем PageViewController
  private func setupPageViewController() {
    let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    pageVC.dataSource = self
    pageVC.delegate = self
    pageVC.view.backgroundColor = UIColor.clear
    
    if let startVC = viewControllerForIndex(currentIndex) {
      pageVC.setViewControllers([startVC], direction: .forward, animated: false)
    }
    
    self.pageViewController = pageVC
    addChild(pageVC)
    view.addSubview(pageVC.view)
    pageVC.didMove(toParent: self)
  }
  
  //MARK: -  Создаём коллекцию миниатюр
  private func setupThumbnailCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .horizontal
    layout.itemSize = CGSize(width: 60, height: 60)
    layout.minimumInteritemSpacing = 10
    
    // Делаем так, чтобы первый и последний элементы были по центру
    let sideInset = (view.bounds.width - 60) / 2
    layout.sectionInset = UIEdgeInsets(top: 10, left: sideInset, bottom: 10, right: sideInset)
    
    let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .clear
    collectionView.showsHorizontalScrollIndicator = false
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(ThumbnailCell.self, forCellWithReuseIdentifier: "ThumbnailCell")
    
    self.thumbnailCollectionView = collectionView
    view.addSubview(collectionView)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
      collectionView.heightAnchor.constraint(equalToConstant: 80)
    ])
  }
  
  
  private func viewControllerForIndex(_ index: Int) -> PhotoViewController? {
    guard index >= 0, index < images.count else { return nil }
    
    let vc = PhotoViewController()
    
    vc.configure(with: images[index])
    vc.index = index
    return vc
  }
  
  
  private func scrollToThumbnail(at index: Int, animated: Bool = true) {
    guard images.count > 1 else { return }
    
    let indexPath = IndexPath(item: index, section: 0)
    
    DispatchQueue.main.async {
      if let attributes = self.thumbnailCollectionView.layoutAttributesForItem(at: indexPath) {
        let cellFrame = attributes.frame
        let collectionViewWidth = self.thumbnailCollectionView.bounds.width
        let targetX = cellFrame.midX - (collectionViewWidth / 2)
        
        // Ограничиваем смещение, чтобы не выйти за границы коллекции
        let maxOffsetX = max(0, self.thumbnailCollectionView.contentSize.width - collectionViewWidth)
        let newOffsetX = min(max(0, targetX), maxOffsetX)
        
        self.thumbnailCollectionView.setContentOffset(CGPoint(x: newOffsetX, y: 0), animated: animated)
      }
    }
  }
  
  
}

extension PhotosPresentstionViewController {
  //MARK: - интерактивно убираю фотку
  
  private func setupPanGesture() {
    let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
    view.addGestureRecognizer(panGesture)
  }
  
  @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
    guard let currentVC = pageViewController.viewControllers?.first as? PhotoViewController else { return }
    let currentImageView = currentVC.imageView
    
    let translation = gesture.translation(in: view)
    let velocity = gesture.velocity(in: view)
    
    // 🔥 Горизонтальное смещение: небольшое отклонение
    let horizontalOffset = translation.x * 0.3 // Ограничиваем движение в стороны
    
    // 🔥 Прозрачность изменяется интенсивнее
    let progress = max(0, min(1, translation.y / (view.bounds.height * 0.7)))
    
    switch gesture.state {
    case .changed:
      let scale = max(0.7, 1 - progress * 0.3) // Фото уменьшается до 70%
      let newY = translation.y * 0.8 // Немного сглаживаем перемещение вниз
      
      // 🔥 Применяем трансформацию: уменьшение, движение вниз и влево-вправо
      currentImageView.transform = CGAffineTransform(translationX: horizontalOffset, y: newY)
        .scaledBy(x: scale, y: scale)
      
      // 🔥 Фон становится прозрачнее быстрее
      let alpha = 1 - progress * 1.5
      self.view.backgroundColor = UIColor.black.withAlphaComponent(alpha)
      currentVC.view.backgroundColor = UIColor.black.withAlphaComponent(alpha)
      
      // 🔥 Скрываем UI (кроме фото)
      view.subviews.forEach { subview in
        if subview != pageViewController.view {
          subview.alpha = alpha
        }
      }
      
    case .ended:
      let shouldDismiss = progress > 0.3 || velocity.y > 500
      
      if shouldDismiss {
        closeGalleryAnimation(from: currentImageView.frame)
      } else {
        // ✅ Исправленный UIView.animate
        UIView.animate(withDuration: 0.25, delay: 0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0, options: .curveEaseOut, animations: {
          currentImageView.transform = .identity
          self.view.backgroundColor = UIColor.black
          self.view.subviews.forEach { $0.alpha = 1 } // Восстанавливаем UI
        })
      }
      
    default:
      break
    }
  }
  
  
  func closeGalleryAnimation(from currentFrame: CGRect) {
    guard let parentVC = parentGridViewController,
          let indexPath = IndexPath(item: currentIndex, section: 0) as IndexPath?,
          let startCell = parentVC.collectionView.cellForItem(at: indexPath) as? PhotoGridCell,
          let image = (currentIndex >= 0 && currentIndex < images.count) ? images[currentIndex] : nil else {
      dismiss(animated: false, completion: nil)
      return
    }
    
    let imageViewSnapshot = UIImageView(image: image)
    imageViewSnapshot.contentMode = .scaleAspectFill
    imageViewSnapshot.clipsToBounds = true
    imageViewSnapshot.frame = currentFrame // ⚡ Летим из текущего положения
    
    parentVC.view.addSubview(imageViewSnapshot)
    self.view.alpha = 0 // Полностью убираем `PhotoGalleryViewController`
    
    let targetFrame = startCell.convert(startCell.bounds, to: parentVC.view)
    
    UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 1.6, initialSpringVelocity: 0.3, animations: {
   // UIView.animate(withDuration: 0.3, animations: {
      imageViewSnapshot.frame = targetFrame
    }, completion: { _ in
      self.dismiss(animated: false) {
        imageViewSnapshot.removeFromSuperview()
        startCell.imageView.isHidden = false // Показываем фото обратно в ячейке
      }
    })
  }
  
  
}





// MARK: - UIPageViewController DataSource & Delegate
extension PhotosPresentstionViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
    guard let currentVC = viewController as? PhotoViewController, currentVC.index > 0 else { return nil }
    return viewControllerForIndex(currentVC.index - 1)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
    guard let currentVC = viewController as? PhotoViewController, currentVC.index < images.count - 1 else { return nil }
    return viewControllerForIndex(currentVC.index + 1)
  }
  
  func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
    if let currentVC = pageViewController.viewControllers?.first as? PhotoViewController {
      // currentIndex = currentVC.index
      
      photoDidSwipeTo(index: currentVC.index)
      scrollToThumbnail(at: currentVC.index)
      updateThumbnailSelection()
    }
  }
}

// MARK: - UICollectionView DataSource & Delegate
extension PhotosPresentstionViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ThumbnailCell", for: indexPath) as! ThumbnailCell
    cell.imageView.image = images[indexPath.item]
    cell.layer.borderWidth = indexPath.item == currentIndex ? 2 : 0
    cell.layer.borderColor = UIColor.white.cgColor
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    if let targetVC = viewControllerForIndex(indexPath.item) {
      let direction: UIPageViewController.NavigationDirection = indexPath.item > currentIndex ? .forward : .reverse
      pageViewController.setViewControllers([targetVC], direction: direction, animated: true)
      // currentIndex = indexPath.item
      scrollToThumbnail(at: currentIndex)
    }
  }
  
  

  
}


//MARK: - Когда нужная фотка по центру - она обводится в белую рамку
//TODO: - Повторить как в iOS галерее увелиычение превью когда выбрана нужная фотка
extension PhotosPresentstionViewController {
  private func updateThumbnailSelection() {
    for cell in thumbnailCollectionView.visibleCells {
      if let thumbnailCell = cell as? ThumbnailCell,
         let indexPath = thumbnailCollectionView.indexPath(for: thumbnailCell) {
        thumbnailCell.layer.borderWidth = indexPath.item == currentIndex ? 2 : 0
        thumbnailCell.layer.borderColor = indexPath.item == currentIndex ? UIColor.white.cgColor : nil
      }
    }
  }
}


// MARK: - PhotoViewController Delegate
//Когда фотка скроллится на этом экране, выбранные фото будут занимать актуальные положения в галерее
extension PhotosPresentstionViewController {
  func photoDidSwipeTo(index: Int) {
    guard let parentVC = parentGridViewController else { return }
    
    // ✅ **Показываем старую ячейку обратно**
    if let oldIndexPath = IndexPath(item: currentIndex, section: 0) as IndexPath?,
       let oldCell = parentVC.collectionView.cellForItem(at: oldIndexPath) as? PhotoGridCell {
      oldCell.imageView.isHidden = false
    }
    
    currentIndex = index // Обновляем индекс
    
    // ✅ **Скрываем новую ячейку**
    if let newIndexPath = IndexPath(item: currentIndex, section: 0) as IndexPath?,
       let newCell = parentVC.collectionView.cellForItem(at: newIndexPath) as? PhotoGridCell {
      newCell.imageView.isHidden = true
    }
    
    // ✅ **Автоматически скроллим таблицу**
    parentVC.scrollToGridItem(at: currentIndex)
  }
  
}





//MARK: - Back to galery
//MARK: - Хорошо с кнопкой close
extension PhotosPresentstionViewController {
  func closeGalleryAnimation() {
    guard let parentVC = parentGridViewController,
          let indexPath = IndexPath(item: currentIndex, section: 0) as IndexPath?,
          let startCell = parentVC.collectionView.cellForItem(at: indexPath) as? PhotoGridCell,
          let image = (currentIndex >= 0 && currentIndex < images.count) ? images[currentIndex] : nil
    else {
      dismiss(animated: false, completion: nil)
      return
    }
    
    // Создаём снимок текущего изображения
    let imageViewSnapshot = UIImageView(image: image)
    imageViewSnapshot.contentMode = .scaleAspectFit
    imageViewSnapshot.clipsToBounds = true
    imageViewSnapshot.frame = view.bounds//getFinalImageFrame() ?? view.bounds
    
    // Добавляем снимок поверх `PhotoGalleryViewController`
    parentVC.view.addSubview(imageViewSnapshot)
    view.backgroundColor = .clear // Скрываем фон
    view.alpha = 1
    
    let targetFrame = startCell.convert(startCell.bounds, to: parentVC.view)
    
    self.view.alpha = 0
    
    UIView.animate(withDuration: 0.3, animations: {
      imageViewSnapshot.frame = targetFrame
      // self.view.alpha = 0 // Плавно скрываем контроллер
    }, completion: { _ in
      self.dismiss(animated: false) {
        imageViewSnapshot.removeFromSuperview()
        
        // **Показываем фото обратно в ячейке**
        startCell.imageView.isHidden = false
      }
    })
  }
  
  
}
