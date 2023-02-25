//
//  ImageDownloader.swift
//  ImageDownloader
//
//  Created by jk on 2023/02/21.
//

import Foundation

typealias Completion = (DownloadState) -> Void

final class ImageDownloader: NSObject {
  
  let queue: OperationQueue = .main
  private var session: URLSession!
  
  private var imageCache: [String: Data] = [:]
  private var progressList: [String: Progress] = [:]
  
  init(
    configuration: URLSessionConfiguration = .ephemeral) {
    super.init()
    self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
  }
  
  @discardableResult
  func setImage(url: URL, handler: @escaping Completion) -> TaskCancellable? {
    if let image = imageCache[url.absoluteString] {
      handler(.progress(1.0))
      handler(.done(image))
      return nil
    }
    
    let request = URLRequest(url: url)
    let task = self.session.dataTask(with: request)
    task.delegate = self

    let object = Progress(
      url: url,
      workBlock: handler)
    
    task.resume()
    
    progressList[url.absoluteString] = object
    
    return TaskCancellable { [weak self] in
      self?.cancel(key: url.absoluteString)
    }
  }
  
  private func cancel(key: String) {
    progressList[key]?.task?.cancel()
    progressList.removeValue(forKey: key)
  }
}

extension ImageDownloader: URLSessionDataDelegate {
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
    guard let key = dataTask.originalRequest?.url?.absoluteString else {
      assertionFailure("Key not found:: \(dataTask)")
      return
    }
    
    progressList[key]?.data.append(data)
    guard let expectedContentLength = dataTask.response?.expectedContentLength,
          expectedContentLength > 0,
          let size = progressList[key]?.data.count
    else { return }
    
    let percentage = Double(size)/Double(expectedContentLength)
    progressList[key]?.workBlock?(.progress(percentage))
  }
  
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard let key = task.originalRequest?.url?.absoluteString else {
      assertionFailure("Key not found:: \(task)")
      return
    }
    defer { progressList.removeValue(forKey: key) }
    
    guard let item = progressList[key] else { return }
      
    imageCache[key] = item.data
    item.workBlock?(.done(item.data))
  }
  
  func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, willCacheResponse proposedResponse: CachedURLResponse, completionHandler: @escaping (CachedURLResponse?) -> Void) {
    completionHandler(proposedResponse)
  }
}

public enum DownloadState {
  case done(Data)
  case progress(Double)
  case failed(Error)
  case ready
}

protocol Worker {
  mutating func start()
  func cancel()
}

fileprivate struct Progress {
  var data: Data = Data()
  var workBlock: Completion?
  
  fileprivate let url: URL
  fileprivate var task: URLSessionDataTask?
  
  init(
    url: URL,
    workBlock: Completion?) {
    self.url = url
    self.workBlock = workBlock
  }
}

struct TaskCancellable {
  fileprivate let cancelTask: () -> Void
  
  func cancel() {
    cancelTask()
  }
}
