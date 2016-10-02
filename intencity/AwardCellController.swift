//
//  AwardCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 3/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AwardCellController: UITableViewCell
{
    @IBOutlet weak var collectionContainer: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    static let AWARD_CELL_BOUNDS: CGFloat = 75
    
    var awards = [AwardRow]()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        let nib = UINib(nibName: Constant.AWARD_COLLECTION_VIEW_CELL, bundle: nil)
        
        collectionView.register(nib, forCellWithReuseIdentifier: Constant.AWARD_COLLECTION_VIEW_CELL)
        collectionView.backgroundColor = Color.white
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(_ collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return awards.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAtIndexPath indexPath: IndexPath) -> UICollectionViewCell
    {
        let award = awards[(indexPath as NSIndexPath).row]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constant.AWARD_COLLECTION_VIEW_CELL, for: indexPath) as! AwardViewCollectionCellController
        cell.amount.text = award.amount
        cell.setImage(award.title)
        
        cell.frame = CGRect(x: cell.frame.origin.x, y: cell.frame.origin.y, width: cell.frame.size.width, height: cell.frame.size.height)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize
    {
        return CGSize(width: AwardCellController.AWARD_CELL_BOUNDS, height: AwardCellController.AWARD_CELL_BOUNDS)
    }
}
