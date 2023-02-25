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
    configuration: URLSessionConfiguration = .default) {
    super.init()
      let configuration = configuration
    configuration.requestCachePolicy = .returnCacheDataElseLoad
    self.session = URLSession(configuration: configuration, delegate: nil, delegateQueue: queue)
  }
  
  @discardableResult
  func setImage(url: URL, handler: @escaping Completion) -> Worker? {
    
    let object = Progress(
      url: url,
      workBlock: handler,
      startBlock: { [weak self] in
        guard let self else { return (nil, nil) }
        if let image = self.imageCache[url.absoluteString] {
          return (image, nil)
        }
        
        let request = URLRequest(url: url)
        let task = self.session.dataTask(with: request)
        task.delegate = self
        
        return (nil, task)
      }, cancelBlock: { [weak self] in
        self?.cancel(key: url.absoluteString)
      })
    
    progressList[url.absoluteString] = object
    
    return object
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

struct Progress {
  var data: Data = Data()
  var workBlock: Completion?
  
  fileprivate let url: URL
  fileprivate var task: URLSessionDataTask?
  
  fileprivate let startBlock: () -> (Data?, URLSessionDataTask?)
  fileprivate let cancelBlock: () -> ()
  init(
    url: URL,
    workBlock: Completion?,
    startBlock: @escaping () -> (Data?, URLSessionDataTask?),
    cancelBlock: @escaping () -> ()) {
    self.url = url
    self.startBlock = startBlock
    self.workBlock = workBlock
    self.cancelBlock = cancelBlock
  }
}

extension Progress: Worker {
  mutating func start() {
    let (data, task) = startBlock()
    if let data {
      workBlock?(.progress(1.0))
      workBlock?(.done(data))
      return
    }
    
    if let task {
      workBlock?(.ready)
      self.task = task
      task.resume()
    }
  }
  
  func cancel() {
    cancelBlock()
  }
}

