//
//  KolodaPhotoView.swift
//  Koloda_Example
//
//  Created by Jacob Lee on 5/4/18.
//  Copyright © 2018 CocoaPods. All rights reserved.
//

import UIKit

extension UIImageView {
    public func imageFromUrl(urlString: String) {
        if let url = NSURL(string: urlString) {
            let request = NSURLRequest(url: url as URL)
            NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: OperationQueue.main, completionHandler: {[unowned self] response, data, error in
                if let data = data {
                    self.image = UIImage(data: data)
                }
            })
        }
    }
}

class KolodaPhotoView: UIView {
    
    @IBOutlet var photoImageView: UIImageView?
    @IBOutlet var photoTitleLabel: UILabel?
    
}
