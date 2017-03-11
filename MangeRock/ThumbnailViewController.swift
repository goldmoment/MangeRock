//
//  ThumbnailViewController.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/9/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit

protocol ThumbnailViewControllerDelegate {
    func reloadAt(_ jsonFile: JsonFile?)
}

class ThumbnailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var jsonFile: JsonFile? = nil
    var delegate: ThumbnailViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = jsonFile?.name
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .plain, target: self, action: #selector(didTapRedo))
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    func didTapRedo(_ sender: UIBarButtonItem) {
        delegate?.reloadAt(jsonFile)
    }
}

extension ThumbnailViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.view.frame.width - 2 * 3) / 4
        let height = width
        return CGSize(width: width, height: height)
    }
}

extension ThumbnailViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let browserVC = self.storyboard?.instantiateViewController(withIdentifier: "BrowserViewController") as? BrowserViewController {
            browserVC.jsonFile = jsonFile
            browserVC.currentIndexPath = indexPath
            self.present(browserVC, animated: true, completion: nil)
        }
    }
}

extension ThumbnailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsonFile?.contentFiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "thumbnailCell", for: indexPath) as! ThumbnailCollectionViewCell
        cell.updateCell(jsonFile: jsonFile, index: indexPath.row)
        return cell
    }
}
