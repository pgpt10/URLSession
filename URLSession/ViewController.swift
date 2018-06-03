//
//  ViewController.swift
//  URLSession
//
//  Created by Payal Gupta on 02/06/18.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        self.downloadImageUsing_DefaultSession_DataTask_Handler()
        self.downloadImageUsing_DefaultSession_DataTask_Delegate()
        self.downloadImageUsing_DefaultSession_DownloadTask_Handler()
        self.downloadImageUsing_BackgroundSession_DownloadTask_Handler()
    }
    
    //--------------------- DefaultSession -- DataTask -- Completion Handler ---------------------
    func downloadImageUsing_DefaultSession_DataTask_Handler()
    {
        let urlString = "https://images.pexels.com/photos/590471/pexels-photo-590471.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
        if let url = URL.init(string: urlString)
        {
            let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, let image = UIImage(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView1.image = image
                }
            }
            task.resume()
        }
    }
    
    //--------------------- DefaultSession -- DataTask -- Delegate ---------------------
    lazy var defaultSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    var receivedData = Data(){
        didSet{
            DispatchQueue.main.async {
                self.imageView2.image = UIImage(data: self.receivedData)
            }
        }
    }

    func downloadImageUsing_DefaultSession_DataTask_Delegate()
    {
        let urlString = "https://images.pexels.com/photos/574282/pexels-photo-574282.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
        if let url = URL.init(string: urlString)
        {
            let task = self.defaultSession.dataTask(with: url)
            task.resume()
        }
    }
    
    //--------------------- DefaultSession -- DownloadTask -- Completion Handler ---------------------
    func downloadImageUsing_DefaultSession_DownloadTask_Handler()
    {
        let urlString = "https://images.pexels.com/photos/395132/pexels-photo-395132.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
        if let url = URL(string: urlString)
        {
            let task = self.defaultSession.downloadTask(with: url) { (location, response, error) in
                let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                if let location = location, let savedURL = documentsURL?.appendingPathComponent(location.lastPathComponent)
                {
                    try? FileManager.default.moveItem(at: location, to: savedURL)
                    DispatchQueue.main.async {
                        self.imageView3.image = UIImage(contentsOfFile: savedURL.path)
                    }
                }
            }
            task.resume()
        }
    }
    
    //--------------------- BackgroundSession -- DownloadTask -- Delegate ---------------------
    lazy var backgroundSession: URLSession = {
        let configuration = URLSessionConfiguration.background(withIdentifier: "xyz")
        configuration.sessionSendsLaunchEvents = true
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }()
    
    func downloadImageUsing_BackgroundSession_DownloadTask_Handler()
    {
        let urlString = "https://images.pexels.com/photos/906100/pexels-photo-906100.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"
        if let url = URL(string: urlString)
        {
            let task = self.backgroundSession.downloadTask(with: url)
            task.earliestBeginDate = Date(timeIntervalSinceNow: 5)
            task.resume()
        }
    }
}

extension ViewController: URLSessionDataDelegate
{
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data)
    {
        self.receivedData.append(data)
    }
}

extension ViewController: URLSessionDownloadDelegate
{
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL)
    {
        let documentsURL = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        if let savedURL = documentsURL?.appendingPathComponent(location.lastPathComponent)
        {
            try? FileManager.default.moveItem(at: location, to: savedURL)
            DispatchQueue.main.async {
                self.imageView4.image = UIImage(contentsOfFile: savedURL.path)
            }
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?)
    {
        if let error = error
        {
            print(error.localizedDescription)
        }
    }
    
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession)
    {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate, let backgroundCompletionHandler = appDelegate.backgroundCompletionHandler else {
                    return
            }
            backgroundCompletionHandler()
        }
    }
}
