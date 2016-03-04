//
//  FitnessRecommendationViewController.swift
//  Intencity
//
//  The view controller for the fitness recommendations.
//
//  Created by Nick Piscopio on 3/4/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import UIKit

class FitnessRecommendationViewController: UIViewController
{
    @IBOutlet weak var gainButton: UIButton!
    @IBOutlet weak var sustainButton: UIButton!
    @IBOutlet weak var loseButton: UIButton!
    @IBOutlet weak var toneButton: UIButton!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var weightTitleLabel: UILabel!
    @IBOutlet weak var weightTitleAstricks: UILabel!
    @IBOutlet weak var weightDescriptionLabel: UILabel!
    @IBOutlet weak var durationTitleLabel: UILabel!
    @IBOutlet weak var durationDescriptionLabel: UILabel!
    @IBOutlet weak var restTitleLabel: UILabel!
    @IBOutlet weak var restDescriptionLabel: UILabel!
    @IBOutlet weak var cardioTitleLabel: UILabel!
    @IBOutlet weak var cardioDescriptionLabel: UILabel!
    @IBOutlet weak var infoAstricks: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // Sets the background color of this view.
        self.view.backgroundColor = Color.page_background
        
        // Sets the title for the screen.
        self.navigationItem.title = NSLocalizedString("how_to_workout_title", comment: "")
        
        gainButton.setTitle(NSLocalizedString("gain", comment: ""), forState: .Normal)
        sustainButton.setTitle(NSLocalizedString("sustain", comment: ""), forState: .Normal)
        loseButton.setTitle(NSLocalizedString("lose", comment: ""), forState: .Normal)
        toneButton.setTitle(NSLocalizedString("tone", comment: ""), forState: .Normal)
        
        titleLabel.textColor = Color.secondary_light
        weightTitleLabel.textColor = Color.secondary_dark
        weightTitleAstricks.textColor = Color.card_button_delete_select
        weightDescriptionLabel.textColor = Color.secondary_dark
        durationTitleLabel.textColor = Color.secondary_dark
        durationDescriptionLabel.textColor = Color.secondary_dark
        restTitleLabel.textColor = Color.secondary_dark
        restDescriptionLabel.textColor = Color.secondary_dark
        cardioTitleLabel.textColor = Color.secondary_dark
        cardioDescriptionLabel.textColor = Color.secondary_dark
        infoAstricks.textColor = Color.card_button_delete_select
        infoLabel.textColor = Color.secondary_light
        
        titleLabel.text = NSLocalizedString("recommendations", comment: "")
        weightTitleAstricks.text = NSLocalizedString("asterisk", comment: "")
        infoAstricks.text = NSLocalizedString("asterisk", comment: "")
        infoLabel.text = NSLocalizedString("weight_description", comment: "")
        
        weightTitleLabel.text = NSLocalizedString("title_weight", comment: "")
        durationTitleLabel.text = NSLocalizedString("title_duration", comment: "")
        restTitleLabel.text = NSLocalizedString("rest_title", comment: "")
        cardioTitleLabel.text = NSLocalizedString("cardio_day_title", comment: "")
        
        setSelectionSustain()
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }

    @IBAction func gainClicked(sender: AnyObject)
    {
        goalSelected(gainButton, weight: "weight_gain", duration: "duration_gain", rest: "rest_gain", cardio: "cardio_day_gain")
    }
    
    @IBAction func sustainClicked(sender: AnyObject)
    {
        setSelectionSustain()
    }
    
    @IBAction func loseClicked(sender: AnyObject)
    {
        goalSelected(loseButton, weight: "weight_lose", duration: "duration_lose", rest: "rest_lose", cardio: "cardio_day_lose")
    }
    
    @IBAction func toneClicked(sender: AnyObject)
    {
        goalSelected(toneButton, weight: "weight_tone", duration: "duration_tone", rest: "rest_tone", cardio: "cardio_day_tone")
    }
    
    func setSelectionSustain()
    {
        goalSelected(sustainButton, weight: "weight_sustain", duration: "duration_sustain", rest: "rest_sustain", cardio: "cardio_day_sustain")
    }
    
    func goalSelected(button: UIButton, weight: String, duration: String, rest: String, cardio: String)
    {
        gainButton.backgroundColor = button == gainButton ? Color.shadow : Color.transparent
        sustainButton.backgroundColor = button == sustainButton ? Color.shadow : Color.transparent
        loseButton.backgroundColor = button == loseButton ? Color.shadow : Color.transparent
        toneButton.backgroundColor = button == toneButton ? Color.shadow : Color.transparent
        
        weightDescriptionLabel.text = NSLocalizedString(weight, comment: "")
        durationDescriptionLabel.text = NSLocalizedString(duration, comment: "")
        restDescriptionLabel.text = NSLocalizedString(rest, comment: "")
        cardioDescriptionLabel.text = NSLocalizedString(cardio, comment: "")
    }
}