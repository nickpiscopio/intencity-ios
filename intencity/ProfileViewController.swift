//
//  ProfileViewController.swift
//  Intencity
//
//  The view controller for the a user's profile.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit
import MobileCoreServices

class ProfileViewController: UIViewController, ServiceDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    @IBOutlet weak var profilePic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var points: UILabel!
    @IBOutlet weak var pointsSuffix: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var cameraButton: IntencityButtonRound!
    @IBOutlet weak var addRemoveButton: IntencityButtonRound!
    
    let AWARDS_TITLE = NSLocalizedString("awards_title", comment: "")
    let ROUTINES_TITLE =  NSLocalizedString("profile_routines_title", comment: "")
    
    var user: User!
    
    var sections = [ProfileSection]()
    
    var profileIsCurrentUser = false
    
    var index: Int!
    var originalFollowingId = Int(Constant.CODE_FAILED)
    
    var userId: String!
    
    weak var delegate: UserSearchDelegate?
    weak var imageDelegate: ImageDelegate?
    
    var newMedia: Bool?
    
    var awardCollectionHeight: CGFloat!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()

        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        userName.text = user.getName()
        points.text = String(user.earnedPoints)
        pointsSuffix.text = NSLocalizedString("points", comment: "")
        
        let image = user.profilePic
        if (image != nil)
        {
            profilePic.image = image
        }
        
        // Initialize the tableview.
        Util.initTableView(tableView, footerHeight: 0, emptyTableStringRes: "empty_profile_awards")
        
        // Load the cells we are going to use in the tableview.
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_HEADER_CELL, cellName: Constant.GENERIC_HEADER_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.AWARD_CELL, cellName: Constant.AWARD_CELL)
        Util.addUITableViewCell(tableView, nibNamed: Constant.GENERIC_CELL, cellName: Constant.GENERIC_CELL)
        
        originalFollowingId = user.followingId
        
        if (!profileIsCurrentUser)
        {
            if (originalFollowingId > 0)
            {
                setAddRemoveButtonImage(Constant.REMOVE_USER_BUTTON)
            }
            else
            {
                setAddRemoveButtonImage(Constant.ADD_USER_BUTTON)
            }
        }
        else
        {
            // Only show the camera button if the photo library is available.
            // We check for the camera if the user clicks on the camera.
            if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.savedPhotosAlbum))
            {
                cameraButton.isHidden = false
            }
            
            addRemoveButton.isHidden = true
        }

        userId = String(user.id)
        
        _ = ServiceTask(event: ServiceEvent.GET_BADGES, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_BADGES, variables: [ userId ]) as NSString)
        
        _ = ServiceTask(event: ServiceEvent.GET_LAST_WEEK_ROUTINES, delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_LAST_WEEK_ROUTINES, variables: [ userId ]) as NSString)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        // Shows the tab bar again.
        self.tabBarController?.tabBar.isHidden = true
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool)
    {
        self.navigationController?.isNavigationBarHidden = false
        
        let followingId = user.followingId
        
        if (!profileIsCurrentUser && originalFollowingId != followingId)
        {
            if (followingId < 0)
            {
                // Unfollow the user.
                _ = ServiceTask(event: ServiceEvent.UNFOLLOW, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_REMOVE_FROM_FOLLOWING, variables: [ String(originalFollowingId) ]) as NSString)
            }
            else
            {
                // Follow the user
                _ = ServiceTask(event: ServiceEvent.GENERIC, delegate: self,
                                serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                                params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_FOLLOW_USER, variables: [ Util.getEmailFromDefaults(), userId ]) as NSString)
            }
            
            delegate?.onUserAdded()
        }
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cameraClicked(_ sender: AnyObject)
    {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)
        {
            Util.displayAlert(self,
                              title: NSLocalizedString("profile_pic_dialog_title", comment: ""),
                              message: NSLocalizedString("profile_pic_dialog_message", comment: ""),
                              actions: [ UIAlertAction(title: NSLocalizedString("profile_pic_dialog_camera_button", comment: ""), style: .default, handler: self.openCamera),
                                UIAlertAction(title: NSLocalizedString("profile_pic_dialog_pictures_button", comment: ""), style: .default, handler: self.openPhotos),
                                UIAlertAction(title: NSLocalizedString("cancel", comment: ""), style: .default, handler: nil)])
        }
        else
        {
            openPhotos()
        }
    }
    
    @IBAction func addRemoveClicked(_ sender: AnyObject)
    {
        if (isUserAdded())
        {
            setAddRemoveButtonImage(Constant.REMOVE_USER_BUTTON)
            
            user.followingId = originalFollowingId > Int(Constant.CODE_FAILED) ? originalFollowingId : 1
        }
        else
        {
            setAddRemoveButtonImage(Constant.ADD_USER_BUTTON)
            
            user.followingId = Int(Constant.CODE_FAILED)
        }
    }
    
    /**
     * Navigates the user back to the previous screen.
     */
    @IBAction func goBack()
    {
        // Navigates the user back to the previous screen.
        _ = self.navigationController?.popViewController(animated: true)
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int
    {
        let sectionsTotal = sections.count
        
        tableView.backgroundView?.isHidden = sectionsTotal > 0
        
        return sectionsTotal
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        // Return the number of rows in the section.
        return sections[section].rows.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let title = sections[section].title
        if (title != "")
        {
            let  headerCell = tableView.dequeueReusableCell(withIdentifier: Constant.GENERIC_HEADER_CELL) as! GenericHeaderCellController
            headerCell.title.text = title
            return headerCell
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        return sections[section].title != "" ? Constant.GENERIC_HEADER_HEIGHT : 0
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat
    {
        let row = sections[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
        let awards = row.awards

        return (awards.count > 0) ? awardCollectionHeight : UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell
    {
        // Gets the row in the section.
        let row = sections[(indexPath as NSIndexPath).section].rows[(indexPath as NSIndexPath).row]
        let awards = row.awards
        
        if (awards.count > 0)
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.AWARD_CELL) as! AwardCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.awards = awards
            // DOCUMENTATION: http://stackoverflow.com/questions/13788522/how-to-determine-height-of-uicollectionview-with-flowlayout
            awardCollectionHeight = cell.collectionView.collectionViewLayout.collectionViewContentSize.height
            
            return cell
        }
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constant.GENERIC_CELL) as! GenericCellController
            cell.selectionStyle = UITableViewCellSelectionStyle.none
            cell.title.text = row.title
            
            return cell
        }
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String)
    {
        var sectionTitle = ""
        var rows = [ProfileRow]()
        var awards = [AwardRow]()
        
        // This gets saved as NSDictionary, so there is no order
        let json: [AnyObject] = result.parseJSONString as! [AnyObject]        
        if (json.count > 0)
        {
            switch(event)
            {
                case ServiceEvent.GET_BADGES:
                
                    for badge in json
                    {
                        let title = badge[Constant.COLUMN_BADGE_NAME] as! String
                        let amount = badge[Constant.COLUMN_TOTAL_BADGES] as! String
                    
                        awards.append(AwardRow(title: title, amount: amount))
                    }
                    
                    rows.append(ProfileRow(title: "", awards: awards))
                
                    sectionTitle = NSLocalizedString("awards_title", comment: "")
                
                    break
                case ServiceEvent.GET_LAST_WEEK_ROUTINES:
                
                    for routine in json
                    {
                        let title = routine[Constant.COLUMN_DISPLAY_NAME] as! String
                    
                        rows.append(ProfileRow(title: title, awards: []))
                    }
                
                    sectionTitle = NSLocalizedString("profile_routines_title", comment: "")
                
                    break
                case ServiceEvent.UPLOAD_IMAGE:
                    imageDelegate?.onImageRetrieved(index, image: profilePic.image!, newUpload: true)
                    break;
                default:
                    break
            }
            
            if (sectionTitle == AWARDS_TITLE)
            {
                sections.insert(ProfileSection(title: sectionTitle, rows: rows), at: 0)
            }
            else
            {
                sections.append(ProfileSection(title: sectionTitle, rows: rows))
            }
            
            tableView.reloadData()
        }
    }
    
    func onRetrievalFailed(_ event: Int)
    {
        print("failed: \(event)")
    }
    
    /**
     * DOCUMENTATION: http://www.techotopia.com/index.php/An_Example_Swift_iOS_8_iPhone_Camera_Application
     */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let mediaType = info[UIImagePickerControllerMediaType] as! String
        
        self.dismiss(animated: true, completion: nil)
        
        if mediaType == (kUTTypeImage as String)
        {
            let image = info[UIImagePickerControllerOriginalImage] as! UIImage

            profilePic.image = image
            
            _ = UploadImageTask(event: ServiceEvent.UPLOAD_IMAGE,
                                delegate: self,
                                image: image,
                                id: userId)
            
            if (newMedia == true)
            {
                UIImageWriteToSavedPhotosAlbum(image, self, nil, nil)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController)
    {
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
     * Sets the image for the addRemoveButton
     *
     * @param imageNamed    The name of the image to set.
     */
    func setAddRemoveButtonImage(_ imageNamed: String)
    {
        addRemoveButton.setImage(UIImage(named: imageNamed), for: UIControlState())
    }
    
    /**
     * Checks to see if the user is already added.
     */
    func isUserAdded() -> Bool
    {
        return addRemoveButton.currentImage!.isEqual(UIImage(named: Constant.ADD_USER_BUTTON))
    }
    
    /**
     * Open the photos.
     */
    func openPhotos()
    {
        let imagePicker = UIImagePickerController()
            
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
        imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
        imagePicker.allowsEditing = false
        self.present(imagePicker, animated: true, completion: nil)
            
        newMedia = false
    }
    
    /**
     * The action to open the photos from an alert.
     */
    func openPhotos(_ alertAction: UIAlertAction!)
    {
        openPhotos()
    }
    
    /**
     * The action to open the camera from an alert.
     */
    func openCamera(_ alertAction: UIAlertAction!)
    {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerControllerSourceType.camera
        imagePicker.cameraDevice = UIImagePickerControllerCameraDevice.front
        imagePicker.mediaTypes = [kUTTypeImage as NSString as String]
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true,
                                   completion: nil)
        newMedia = true
    }
}
