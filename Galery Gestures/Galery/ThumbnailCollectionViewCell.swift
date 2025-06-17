//
//  ThumbnailCollectionViewCell.swift
//  GaleryProject
//
//  Created by Dmitro Levkutnyk on 01.02.2025.
//

import UIKit

 // MARK: - ThumbnailCell.swift
class ThumbnailCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    imageView.contentMode = .scaleAspectFill
    imageView.clipsToBounds = true
    imageView.frame = contentView.bounds
    contentView.addSubview(imageView)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
