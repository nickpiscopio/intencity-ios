//
//  AwardCellController.swift
//  Intencity
//
//  Created by Nick Piscopio on 3/29/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class AwardCellController: UITableViewCell
{
    @IBOutlet weak var collectionView: UICollectionView!
    
    var awards = [AwardRow]()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        collectionView.backgroundColor = Color.white
        
        let nib = UINib(nibName: Constant.AWARD_COLLECTION_VIEW_CELL, bundle: nil)
        
        collectionView.registerNib(nib, forCellWithReuseIdentifier: Constant.AWARD_COLLECTION_VIEW_CELL)
    }
    
    // MARK: UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return awards.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        let award = awards[indexPath.row]
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(Constant.AWARD_COLLECTION_VIEW_CELL, forIndexPath: indexPath) as! AwardViewCollectionCellController
        cell.amount.text = award.amount
        cell.setImage(award.title)
        
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, cell.frame.size.height)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        return CGSizeMake(75, 75)
    }
}