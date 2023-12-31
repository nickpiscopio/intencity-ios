//
//  ExerciseSet.swift
//  Intencity
//
//  Created by Nick Piscopio on 6/19/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.
//

import Foundation

class ExerciseSet
{
    static let EDIT_STRING = NSLocalizedString("edit", comment: "")
    static let LBS_STRING = NSLocalizedString("title_lbs", comment: "")
    static let REPS_STRING = NSLocalizedString("title_reps", comment: "")
    static let SPACE = " "
    static let SLASH = " / "
    
    /**
     * Gets the mutable sttributed string for the set text.
     *
     * @return The mutable attributed string, boolean value whether we have a weight or a duration.
     */
    static func getSetText(_ weight: Float, duration: String, isReps: Bool) -> (mutableString: NSMutableAttributedString, hasValue: Bool)
    {
        let mutableString = NSMutableAttributedString()
        
        let addWeight = weight > 0.0
        let addDuration = duration != Constant.RETURN_NULL && Util.convertToInt(duration) > 0
        
        if (addWeight || addDuration)
        {
            if (addWeight)
            {
                mutableString.append(Util.getMutableString(String(weight), fontSize: Dimention.FONT_SIZE_MEDIUM, color: Color.secondary_light, isBold: true))
                mutableString.append(Util.getMutableString(SPACE, fontSize: Dimention.FONT_SIZE_XX_SMALL, color: Color.secondary_light, isBold: false))
                mutableString.append(Util.getMutableString(LBS_STRING, fontSize: Dimention.FONT_SIZE_SMALL, color: Color.secondary_light, isBold: false))
                
                mutableString.append(Util.getMutableString(SLASH, fontSize: Dimention.FONT_SIZE_MEDIUM, color: Color.secondary_light, isBold: false))
            }
            
            mutableString.append(Util.getMutableString(duration, fontSize: Dimention.FONT_SIZE_MEDIUM, color: Color.secondary_light, isBold: true))
            
            if (isReps)
            {
                mutableString.append(Util.getMutableString(SPACE, fontSize: Dimention.FONT_SIZE_XX_SMALL, color: Color.secondary_light, isBold: false))
                mutableString.append(Util.getMutableString(REPS_STRING, fontSize: Dimention.FONT_SIZE_SMALL, color: Color.secondary_light, isBold: false))
            }
        }
        else
        {
            mutableString.append(Util.getMutableString(EDIT_STRING, fontSize: Dimention.FONT_SIZE_MEDIUM, color: Color.secondary_light, isBold: true))
        }
        
        return (mutableString, addWeight || addDuration)
    }
}
