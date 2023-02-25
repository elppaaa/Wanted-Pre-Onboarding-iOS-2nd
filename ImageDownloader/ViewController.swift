//
//  ViewController.swift
//  ImageDownloader
//
//  Created by jk on 2023/02/21.
//

import UIKit

final class ViewController: UIViewController {

  typealias DataSource = UICollectionViewDiffableDataSource<Section, Item>

  private let contentView = MainView()
  
  private var dataSource: DataSource!
  
  private let imageDownloader = ImageDownloader()
  
  override func loadView() {
    super.loadView()
    view = contentView
    self.dataSource = generateDataSource()
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    contentView.downloadAll.addTarget(self, action: #selector(didDownloadAllButtonTapped), for: .touchUpInside)
    
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
    DataSource(collectionView: contentView.collectionView) { [weak imageDownloader] collectionView, indexPath, item in
      let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier, for: indexPath) as? Cell
      guard let imageDownloader else { return cell ?? UICollectionViewCell() }
      
      let worker = imageDownloader.setImage(url: item.url) { [weak cell] state in
        guard let cell else { return }
        switch state {
        case .done(let data):
          cell.imageView.image = UIImage(data: data)
        case .progress(let percentage):
          cell.progressBar.progress = Float(percentage)
          
        default:
          break;
        }
      }
      
      cell?.worker = worker
      
      return cell
    }
  }
  
  @objc
  private func didDownloadAllButtonTapped() {
    contentView.collectionView
      .visibleCells
      .compactMap { $0 as? Cell}
      .forEach { $0.didButtonTapped() }
  }

}

enum Section { case main }
struct Item: Hashable {
  let url: URL
}
