//
//  CollectionViewController.swift
//  URLSession
//
//  Created by Payal Gupta on 03/06/18.
//  Copyright © 2018 Payal Gupta. All rights reserved.
//

import UIKit

class Image
{
    var urlString: String
    var task: URLSessionDataTask?
    
    init(_ urlString: String)
    {
        self.urlString = urlString
    }
}

class CollectionViewController: UICollectionViewController
{
    var images = [
        Image("https://images.pexels.com/photos/590471/pexels-photo-590471.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
        Image("https://images.pexels.com/photos/574282/pexels-photo-574282.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
        Image("https://images.pexels.com/photos/395132/pexels-photo-395132.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
        Image("https://images.pexels.com/photos/906100/pexels-photo-906100.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"),
        Image("https://images.pexels.com/photos/395134/pexels-photo-395134.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350"),
        Image("https://images.pexels.com/photos/1115680/pexels-photo-1115680.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350"),
        Image("https://images.pexels.com/photos/1125032/pexels-photo-1125032.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350"),
        Image("https://images.pexels.com/photos/929032/pexels-photo-929032.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350"),
        Image("https://images.pexels.com/photos/965157/pexels-photo-965157.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350"),
        Image("https://images.pexels.com/photos/1121782/pexels-photo-1121782.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=350")
    ]
    
    lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad
        let session = URLSession(configuration: config)
        return session
    }()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
    }
    
    deinit
    {
        self.session.invalidateAndCancel()
    }
    
    // MARK: UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return self.images.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CustomCell
        cell.configure(with: self.images[indexPath.row], session: self.session)
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath)
    {
        let image = self.images[indexPath.row]
        if image.task?.state == .running
        {
            image.task?.cancel()
        }
    }
}

class CustomCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    
    func configure(with image: Image, session: URLSession)
    {
        if let url = URL(string: image.urlString)
        {
            image.task = session.dataTask(with: url, completionHandler: { (data, response, error) in
                guard let data = data, let img = UIImage.init(data: data) else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = img
                }
            })
            image.task?.resume()
        }
    }
}
