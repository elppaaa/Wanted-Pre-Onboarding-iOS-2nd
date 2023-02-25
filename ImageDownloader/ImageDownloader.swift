//
//  ImageDownloader.swift
//  ImageDownloader
//
//  Created by jk on 2023/02/21.
//

import Foundation

public final class ImageDownloader: NSObject {
  public typealias Completion = (DownloadState) -> Void
  
  #if DEBUG
  deinit {
    print("🔥 ImageDownloader deinit")
  }
  #endif
  
  public init(
    configuration: URLSessionConfiguration = .default,
    workQueue queue: OperationQueue = .init(),
    url: URL,
    completionHandler: @escaping Completion) {
    self.url = url
    self.completionHandler = completionHandler
    super.init()
    self.session = URLSession(configuration: configuration, delegate: self, delegateQueue: queue)
  }
  
  private let url: URL
  private var session: URLSession!
  public var completionHandler: Completion
  
  public func start() {
    completionHandler(.ready)
    
    let request = URLRequest(url: url)
    let task = session.downloadTask(with: request)
    task.delegate = self
    task.resume()
  }
  
}



extension ImageDownloader: URLSessionDownloadDelegate {
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    do {
      let data = try Data(contentsOf: location)
      completionHandler(.done(data))
      session.finishTasksAndInvalidate()
    } catch {
      completionHandler(.failed(error))
      session.invalidateAndCancel()
    }
  }
  public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
    let percentage = Double(totalBytesWritten)/Double(totalBytesExpectedToWrite)
    print(percentage)
    completionHandler(.progress(percentage))
  }
}

public enum DownloadState {
  case done(Data)
  case progress(Double)
  case failed(Error)
  case ready
}
