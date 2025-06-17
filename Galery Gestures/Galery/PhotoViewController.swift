//
//  PhotoViewController.swift
//  GaleryProject
//
//  Created by Dmitro Levkutnyk on 01.02.2025.
//

import UIKit

//MARK: - Просто контроллер с фоткой (используется в PageControl)
class PhotoViewController: UIViewController {
  
  let imageView = UIImageView()
  var index: Int = 0
  
  override func viewDidLoad() {
    super.view.backgroundColor = .black
    imageView.contentMode = .scaleAspectFit
    imageView.frame = view.bounds
    view.addSubview(imageView)
  }
  
  func configure(with image: UIImage) {
    imageView.image = image
  }
}
