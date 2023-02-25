//
//  Cell.swift
//  ImageDownloader
//
//  Created by jk on 2023/02/22.
//

import Foundation
import UIKit

final class Cell: UICollectionViewCell {
  
  // MARK: Properties
  
  static var reuseIdentifier: String { String(describing: Cell.self) }
  
  private let imageView = UIImageView()
  private let progressBar = UIProgressView(progressViewStyle: .bar)
  private let downloadButton: UIButton = {
    let button = UIButton(configuration: .borderedTinted())
    button.setTitle("Down", for: .normal)
    return button
  }()
  private var url: URL?
  
  // MARK: Initialize
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  override init(frame: CGRect) {
    super.init(frame: frame)
    configLayout()
    downloadButton.addTarget(self, action: #selector(didButtonTapped), for: .touchUpInside)
  }
  
  // MARK: Life Cycle
  
  override func prepareForReuse() {
    super.prepareForReuse()
    reset()
  }
  
  // MARK: Logic
  
  func update(from model: Item) {
    reset()
    url = model.url
  }
  
  private func reset() {
    imageView.image = nil
    progressBar.progress = 0.0
  }
  
  @objc
  private func didButtonTapped() {
    guard let url else { return }
    reset()
    ImageDownloader(url: url) { [weak self] state in
      switch state {
      case .ready:
        break
      case .progress(let percentage):
        DispatchQueue.main.async {
          self?.progressBar.progress = Float(percentage)
        }
      case .done(let imageData):
        DispatchQueue.main.async {
          self?.imageView.image = UIImage(data: imageData)
        }
      case .failed(let error):
        debugPrint(String(describing: error))
      }
    }
    .start()
  }
  
  private func configLayout() {
    contentView.addSubview(imageView)
    contentView.addSubview(progressBar)
    contentView.addSubview(downloadButton)
    imageView.translatesAutoresizingMaskIntoConstraints = false
    progressBar.translatesAutoresizingMaskIntoConstraints = false
    downloadButton.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
      imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0),
      imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
      imageView.widthAnchor.constraint(equalTo: imageView.heightAnchor),
    ])
    
    NSLayoutConstraint.activate([
      progressBar.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      progressBar.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 15),
      progressBar.heightAnchor.constraint(equalToConstant: 20),
    ])
    
    NSLayoutConstraint.activate([
      downloadButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
      downloadButton.leadingAnchor.constraint(equalTo: progressBar.trailingAnchor, constant: 10),
      downloadButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
      downloadButton.widthAnchor.constraint(equalToConstant: 80),
      downloadButton.heightAnchor.constraint(equalToConstant: 30),
    ])
  }
}
