//
//  BrowserViewController.swift
//  MangeRock
//
//  Created by Vien Van Nguyen on 3/10/17.
//  Copyright © 2017 Vien Van Nguyen. All rights reserved.
//

import UIKit

class BrowserViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var indexLable: UILabel!
    
    var jsonFile: JsonFile? = nil
    var currentIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let indexPath = currentIndexPath else { return }
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateIndex()
    }
    
    @IBAction func didTapCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func updateIndex() {
        guard let visibleCell = collectionView.visibleCells.first else { return }
        guard let indexPath = collectionView.indexPath(for: visibleCell) else { return }
        
        indexLable.text = "\(indexPath.row + 1)/\(jsonFile?.contentFiles.count ?? 0)"
    }
}

extension BrowserViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
}

extension BrowserViewController: UICollectionViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        updateIndex()
    }
}

extension BrowserViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return jsonFile?.contentFiles.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! BrowserCollectionViewCell
        cell.updateCell(jsonFile: jsonFile, index: indexPath.row)
        return cell
    }
}
