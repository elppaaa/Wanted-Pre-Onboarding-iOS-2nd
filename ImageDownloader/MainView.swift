//
//  MainView.swift
//  ImageDownloader
//
//  Created by jk on 2023/02/25.
//

import UIKit
import Foundation

final class MainView: UIView {
  
  // MARK: Properties
  
  private let buttonHeight: CGFloat = 60
  
  let downloadAll: UIButton = {
    let button = UIButton(configuration: .filled())
    button.setTitle("Load All Images", for: .normal)
    return button
  }()
  private(set) lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
  
  // MARK: Initialize
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError() }
  override init(frame: CGRect) {
    super.init(frame: frame)
    configLayout()
    registerCells()
  }
  
  // MARK: Life Cycle
  
  // MARK: Logic
  
  private func configLayout() {
    backgroundColor = .systemBackground
    
    addSubview(collectionView)
    addSubview(downloadAll)
    
    collectionView.translatesAutoresizingMaskIntoConstraints = false
    downloadAll.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      collectionView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
      collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
      collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
      collectionView.bottomAnchor.constraint(equalTo: downloadAll.topAnchor),
    ])
    
    NSLayoutConstraint.activate([
      downloadAll.leadingAnchor.constraint(equalTo: leadingAnchor),
      downloadAll.trailingAnchor.constraint(equalTo: trailingAnchor),
      downloadAll.bottomAnchor.constraint(equalTo: bottomAnchor),
      downloadAll.heightAnchor.constraint(equalToConstant: buttonHeight),
    ])
  }
  
  private func registerCells() {
    collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
  }

  private func generateLayout() -> UICollectionViewLayout {
    let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
    let item = NSCollectionLayoutItem(layoutSize: itemSize)
    
    let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
    let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
    
    let section = NSCollectionLayoutSection(group: group)
    
    section.interGroupSpacing = 10
    
    return UICollectionViewCompositionalLayout(section: section)
  }
  
}
