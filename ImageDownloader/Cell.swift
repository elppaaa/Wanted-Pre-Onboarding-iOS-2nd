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
  
  let imageView = UIImageView()
  let progressBar = UIProgressView(progressViewStyle: .bar)
  let downloadButton: UIButton = {
    let button = UIButton(configuration: .filled())
    button.setTitle("Down", for: .normal)
    return button
  }()
  var worker: (() -> TaskCancellable?)?
  var taskCancel: TaskCancellable?
  
  
  // MARK: Initialize
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  override init(frame: CGRect) {
    super.init(frame: frame)
    configLayout()
    reset()
    downloadButton.addTarget(self, action: #selector(didButtonTapped), for: .touchUpInside)
  }
  
  // MARK: Life Cycle
  
  override func prepareForReuse() {
    super.prepareForReuse()
    reset()
    taskCancel?.cancel()
  }
  
  // MARK: Logic
  
  func downlaodImage(with downloader: ImageDownloader?, url: URL) {
    worker = { 
      downloader?.setImage(url: url) { [weak self] state in
        guard let self else { return }
        switch state {
        case .done(let data):
          self.imageView.image = UIImage(data: data)
        case .progress(let percentage):
          self.progressBar.progress = Float(percentage)
          
        default:
          break;
        }
      }
    }
  }
  
  private func reset() {
    imageView.image = UIImage(systemName: "photo")
    progressBar.progress = 0.0
  }
  
  @objc
  func didButtonTapped() {
    reset()
    taskCancel = worker?()
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
      progressBar.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
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
