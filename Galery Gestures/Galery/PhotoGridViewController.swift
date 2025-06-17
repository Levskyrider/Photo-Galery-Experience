//
//  TestPhotoGrid.swift
//  GaleryProject
//
//  Created by Dmitro Levkutnyk on 31.01.2025.
//

import UIKit

class PhotoGridViewController: UIViewController {
  
  private var images: [UIImage] = [UIImage(named: "test1")!, UIImage(named: "test2")!, UIImage(named: "test3")!, UIImage(named: "test4")!, UIImage(named: "test5")!, UIImage(named: "test6")!, UIImage(named: "test7")!, UIImage(named: "test8")!, UIImage(named: "test9")!, UIImage(named: "test10")!]
  
  
  public var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .black
    setupCollectionView()
  }
  
  func configure(with images: [UIImage]) {
    self.images = images
  }
  
  private func setupCollectionView() {
    let layout = UICollectionViewFlowLayout()
    layout.itemSize = CGSize(width: (view.bounds.width - 3 * 4) / 3, height: (view.bounds.width - 3 * 4) / 3) // Квадратные фото
    layout.minimumInteritemSpacing = 3
    layout.minimumLineSpacing = 3
    
    collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    collectionView.backgroundColor = .black
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.register(PhotoGridCell.self, forCellWithReuseIdentifier: "PhotoGridCell")
    
    view.addSubview(collectionView)
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
}


//MARK: - Показать детальный просмотр фотки с анимацией открытия фотки на весь экран
//TODO: - может сделать более прикольную анимацию
extension PhotoGridViewController {
  //Animation
  private func showPhotoGallery(startingFrom cell: PhotoGridCell, index: Int) {
    guard let startImage = cell.imageView.image else { return }
    
    let imageViewSnapshot = UIImageView(image: startImage)
    imageViewSnapshot.contentMode = .scaleAspectFit
    imageViewSnapshot.clipsToBounds = true
    imageViewSnapshot.frame = cell.convert(cell.bounds, to: view)
    
    let photoGalleryVC = PhotosPresentstionViewController()
    photoGalleryVC.modalPresentationStyle = .overCurrentContext
    photoGalleryVC.configure(with: images, startIndex: index)
    photoGalleryVC.parentGridViewController = self
    
    let endFrame = view.bounds
    
    view.addSubview(imageViewSnapshot)
    collectionView.isHidden = true
    
    cell.imageView.isHidden = true
    
    
    UIView.animate(withDuration: 0.3, animations: {
      imageViewSnapshot.frame = endFrame
    }, completion: { _ in
      
      self.present(photoGalleryVC, animated: false) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
          imageViewSnapshot.removeFromSuperview()
          self.collectionView.isHidden = false
        }
      }
    })
  }
  
  
}




// MARK: - UICollectionView DataSource & Delegate
extension PhotoGridViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return images.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoGridCell", for: indexPath) as! PhotoGridCell
    cell.imageView.image = images[indexPath.item]
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let cell = collectionView.cellForItem(at: indexPath) as! PhotoGridCell
    showPhotoGallery(startingFrom: cell, index: indexPath.item)
  }
  
  func scrollToGridItem(at index: Int) {
    guard index < images.count else { return }
    let indexPath = IndexPath(item: index, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredVertically, animated: true)
  }
}


