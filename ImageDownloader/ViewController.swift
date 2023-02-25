//
//  ViewController.swift
//  ImageDownloader
//
//  Created by jk on 2023/02/21.
//

import UIKit

class ViewController: UIViewController {

  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

  private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: generateLayout())
  private var dataSource: DataSource!
  
  
  override func loadView() {
    super.loadView()
    view = collectionView
    self.dataSource = generateDataSource()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    let _sources = (0..<100)
      .compactMap { _ in URL(string: "https://picsum.photos/id/\(arc4random() % 500)/400") }
      .map { Item(url: $0) }
    let sources = Array(Set(_sources))
    
    var snapshot = dataSource.snapshot()
    snapshot.appendSections([.main])
    snapshot.appendItems(sources, toSection: .main)
    dataSource.apply(snapshot)
  }
  
  private func generateDataSource() -> DataSource {
    collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier)
    
    return DataSource(collectionView: collectionView) { collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell
      cell?.update(from: item)
      return cell
    }
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

enum Section { case main }
struct Item: Hashable {
  let url: URL
}
