//
//  PhotoGridCell.swift
//  GaleryProject
//
//  Created by Dmitro Levkutnyk on 01.02.2025.
//

import UIKit

class PhotoGridCell: UICollectionViewCell {
  
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    contentView.addSubview(imageView)
    imageView.frame = contentView.bounds
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
}

