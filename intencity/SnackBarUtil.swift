//
//  SnackBarUtil.swift
//  Intencity
//
//  Created by Nick Piscopio on 8/6/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import TTGSnackbar

class SnackBarUtil
{
    /**
     * Initializes the snackbar to how it should look for Intencity.
     *
     * @return The mutable attributed string, boolean value whether we have a weight or a duration.
     */
    static func initSnackbar(snackbar: TTGSnackbar)
    {
        snackbar.leftMargin = 0
        snackbar.rightMargin = 0;
        snackbar.bottomMargin = 0;
        snackbar.cornerRadius = 0;
        snackbar.actionTextColor = Color.accent
    }
}