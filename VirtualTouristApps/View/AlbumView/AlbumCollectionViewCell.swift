//
//  AlbumCollectionViewCell.swift
//  VirtualTouristApps
//
//  Created by Gilang Ramadhan on 14/07/22.
//

import UIKit

class AlbumCollectionViewCell: UICollectionViewCell {
  private lazy var repository: VirtualToursitRepository = { return Injection().provideRepository() }()

  @IBOutlet weak var indicatorLoading: UIActivityIndicatorView!
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var deleteImage: UIImageView!
  func loadImage(url: String, completion: @escaping(_ image: Data) -> Void
) {
    self.indicatorLoading.hidesWhenStopped = true
    self.indicatorLoading.startAnimating()
    repository.downloadImage(url: url) { result in
      DispatchQueue.main.async {
        switch result {
        case .failure:
          self.imageView.image = UIImage(named: "broken-image")
        case .success(let photo):
          self.imageView.image = UIImage(data: photo)
        }
        if let image = self.imageView.image, let data = image.pngData() {
          completion(data)
          self.indicatorLoading.stopAnimating()
        }
      }
    }
  }
}
