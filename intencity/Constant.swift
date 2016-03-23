//
//  Constant.swift
//  Intencity
//
//  Intencity's Constants.
//
//  Created by Nick Piscopio on 2/10/16.
//  Copyright © 2016 Nick Piscopio. All rights reserved.

import Foundation
import UIKit

struct Constant
{
    // -- START iOS CONSTANTS --
    static let DEMO_STORYBOARD = "Demo"
    static let LOGIN_STORYBOARD = "Login"    
    static let MAIN_STORYBOARD = "Main"
    
    static let LOGIN_NAV_CONTROLLER = "LoginNavController"
    
    static let EXERCISE_LIST_HEADER = "ExerciseListHeader"
    static let ROUTINE_CELL = "RoutineCell"
    static let EXERCISE_CELL = "ExerciseCell"
    static let DIRECTION_CELL = "DirectionCell"
    static let SET_CELL = "SetCell"
    static let GENERIC_CELL = "GenericCell"
    static let MENU_HEADER_CELL = "MenuHeaderCell"
    static let ABOUT_CELL = "AboutCell"
    static let DESCRIPTION_FOOTER_CELL = "DescriptionFooterCell"
    static let SEARCH_EXERCISE_CELL = "SearchExerciseCell"
    static let RANKING_CELL = "RankingCell"
    static let MENU_EXERCISE_CELL = "MenuExerciseCell"
    static let EXERCISE_PRIORITY_CELL = "ExercisePriorityCell"
    static let FITNESS_RECOMMENDATION_CELL = "FitnessRecommendationCell"
    static let NOTIFICATION_CELL = "NotificationCell"
    
    static let FITNESS_RECOMMENDATION_HEADER_CELL = "FitnessRecHeaderCell"
    static let FITNESS_RECOMMENDATION_FOOTER_CELL = "FitnessRecFooterCell"
    
    static let MENU_VIEW_CONTROLLER = "MenuViewController"
    static let EXERCISE_SEARCH_VIEW_CONTROLLER = "ExerciseSearchViewController"
    static let DIRECTION_VIEW_CONTROLLER = "DirectionViewController"
    static let SEARCH_VIEW_CONTROLLER = "SearchViewController"
    static let FITNESS_RECOMMENDATION_VIEW_CONTROLLER = "FitnessRecommendationViewController"
    static let TERMS_VIEW_CONTROLLER = "TermsViewController"
    static let PRIVACY_POLICY_VIEW_CONTROLLER = "PrivacyPolicyViewController"
    static let RATE_INTENCITY = "RateIntencity"
    static let LOG_OUT = "LogOut"
    
    static let MAIN_VIEW = "IntencityTabView"
    static let DEMO_VIEW = "DemoViewController"
    static let CHECKBOX_UNCHECKED = "checkbox_unchecked"
    static let CHECKBOX_CHECKED = "checkbox_checked"
    
    static let MENU_INITIALIZED = 0
    static let MENU_NOTIFICATION_FOUND = 1
    static let MENU_NOTIFICATION_PRESENT = 2
    
    static let MENU_INITIALIZED_IMAGE = "menu"
    static let MENU_NOTIFICATION_FOUND_IMAGE = "menu_notification_"
    static let MENU_NOTIFICATION_PRESENT_IMAGE = "menu_notification_6"
    
    static let MENU_IMAGE_WIDTH: CGFloat = 27.0
    static let MENU_IMAGE_HEIGHT: CGFloat = 23.0
    // -- END iOS CONSTANTS --
    
    // -- START GENERIC CONSTANTS --
    static let CODE_FAILED: Double = -1.0;
    static let CODE_FAILED_REPOPULATE = -2;
    static let REQUIRED_PASSWORD_LENGTH = 8;
    static let TRIAL_ACCOUNT_THRESHOLD = 604800000;
    static let LOGIN_POINTS_THRESHOLD = 43200000;
    static let EXERCISE_POINTS_THRESHOLD = 60000;
    static let POINTS_LOGIN = 5;
    static let POINTS_EXERCISE = 5;
    static let POINTS_COMPLETING_WORKOUT = 10;
    static let POINTS_SHARING = 5;
    static let POINTS_FOLLOWING = 5;
    static let POINTS_AWARD = 10;
    static let TRUE = "true";
    static let DURATION_0 = "00:00:00";
    static let RETURN_NULL = "null";
    static let NEGATIVE_BUTTON = 0;
    static let POSITIVE_BUTTON = 1;
    static let SUCCESS = "SUCCESS";
    static let EMAIL_EXISTS = "Email already exists";
    static let COULD_NOT_FIND_EMAIL = "Could not find email";
    static let INVALID_PASSWORD = "Invalid password";
    static let ACCOUNT_CREATED = "Account created";
    static let SHARED_PREFERENCES = "com.intencity.intencity.shared.preferences";
    
    static let USER_ACCOUNT_ID = "com.intencity.intencity.user.id";
    static let USER_ACCOUNT_EMAIL = "com.intencity.intencity.user.email";
    static let USER_ACCOUNT_TYPE = "com.intencity.intencity.user.account.type";
    static let USER_TRIAL_CREATED_DATE = "com.intencity.intencity.user.trial.created.date";
    static let USER_LAST_LOGIN = "com.intencity.intencity.user.last.login";
    static let USER_LAST_EXERCISE_TIME = "com.intencity.intencity.user.last.exercise.time";
    
    static let TUTORIAL_SWIPE_TO_DISMISS = "com.intencity.intencity.tutorial.swipe.to.dismiss";
    static let REQUEST_CODE_STAT = 10;
    static let REQUEST_CODE_SEARCH = 20;
    static let REQUEST_CODE_TWEET = 30;
    static let REQUEST_CODE_LOG_OUT = 40;
    static let ID_FRAGMENT_EXERCISE_LIST = 1;
    static let EXTRA_DEMO_PAGE = "com.intencity.intencity.extra.demo.page";
    static let BUNDLE_SEARCH_EXERCISES = "com.intencity.intencity.bundle.search.exercises";
    static let BUNDLE_SET_NUMBER = "com.intencity.intencity.bundle.set.number";
    static let BUNDLE_DISPLAY_MUSCLE_GROUPS = "com.intencity.intencity.bundle.display.muscle.groups";
    static let BUNDLE_ROUTINE_NAME = "com.intencity.intencity.bundle.routine.name";
    static let BUNDLE_EXERCISE_LIST = "com.intencity.intencity.bundle.exercise.list";
    static let BUNDLE_EXERCISE = "com.intencity.intencity.bundle.exercise";
    static let BUNDLE_EXERCISE_POSITION = "com.intencity.intencity.bundle.exercise.position";
    static let BUNDLE_EXERCISE_SETS = "com.intencity.intencity.bundle.exercise.sets";
    static let BUNDLE_EXERCISE_LIST_INDEX = "com.intencity.intencity.bundle.exercise.list.index";
    static let BUNDLE_RECOMMENDED_ROUTINE = "com.intencity.intencity.bundle.recommended.routine";
    static let BUNDLE_EXERCISE_NAME = "com.intencity.intencity.bundle.exercise.name";
    static let BUNDLE_ID = "com.intencity.intencity.bundle.id";
    static let BUNDLE_EXERCISE_TYPE = "com.intencity.intencity.exercise.type";
    static let BUNDLE_EXERCISE_SKIPPED = "com.intencity.intencity.exercise.skipped";
    
    static let ENDPOINT = "http://www.intencityapp.com/";
    static let SERVICE_FOLDER = ENDPOINT + "dev/services/";
    static let SERVICE_FOLDER_MOBILE = SERVICE_FOLDER + "mobile/";
    static let SERVICE_VALIDATE_USER_CREDENTIALS = SERVICE_FOLDER_MOBILE + "user_credentials.php";
    static let SERVICE_CREATE_ACCOUNT = SERVICE_FOLDER_MOBILE + "account.php";
    static let SERVICE_STORED_PROCEDURE = SERVICE_FOLDER_MOBILE + "stored_procedure.php";
    static let SERVICE_COMPLEX_INSERT = SERVICE_FOLDER_MOBILE + "complex_insert.php";
    static let SERVICE_COMPLEX_UPDATE = SERVICE_FOLDER_MOBILE + "complex_update.php";
    static let SERVICE_UPDATE_EQUIPMENT = SERVICE_FOLDER_MOBILE + "update_equipment.php";
    static let SERVICE_UPDATE_EXERCISE_PRIORITY = SERVICE_FOLDER_MOBILE + "update_exercise_priority.php";
    static let SERVICE_CHANGE_PASSWORD = SERVICE_FOLDER_MOBILE + "change_password.php";
    static let SERVICE_FORGOT_PASSWORD = SERVICE_FOLDER + "forgot_password.php";
    static let PARAMETER_AMPERSAND = "&";
    static let PARAMETER_DELIMITER = ",";
    static let PARAMETER_TABLE = "table";
    static let PARAMETER_EMAIL = "email=";
    static let PARAMETER_PASSWORD = "password=";
    static let PARAMETER_CURRENT_PASSWORD = "oldPassword=";
    static let PARAMETER_DATA = "d=";
    static let PARAMETER_VARIABLE = "v=";
    static let PARAMETER_FIRST_NAME = "first_name=";
    static let PARAMETER_LAST_NAME = "last_name=";
    static let PARAMETER_ACCOUNT_TYPE = "account_type=";
    static let PARAMETER_INSERTS = "inserts=";
    
    static let STORED_PROCEDURE_GET_ALL_DISPLAY_MUSCLE_GROUPS = "getAllDisplayMuscleGroups";
    static let STORED_PROCEDURE_GET_EXERCISES_FOR_TODAY = "getExercisesForToday";
    static let STORED_PROCEDURE_SET_CURRENT_MUSCLE_GROUP = "setCurrentMuscleGroup";
    static let STORED_PROCEDURE_SET_EXERCISE_PRIORITY = "setExercisePriority";
    static let STORED_PROCEDURE_GET_FOLLOWING = "getFollowing";
    static let STORED_PROCEDURE_REMOVE_FROM_FOLLOWING = "removeFromFollowing";
    static let STORED_PROCEDURE_SEARCH_EXERCISES = "searchExercises";
    static let STORED_PROCEDURE_SEARCH_USERS = "searchUsers";
    static let STORED_PROCEDURE_FOLLOW_USER = "followUser";
    static let STORED_PROCEDURE_GET_EXERCISE_DIRECTION = "getDirection";
    static let STORED_PROCEDURE_GET_EQUIPMENT = "getEquipment";
    static let STORED_PROCEDURE_GET_EXERCISE_PRIORITIES = "getExercisePriority";
    static let STORED_PROCEDURE_GRANT_POINTS = "grantPointsToUser";
    static let STORED_PROCEDURE_GRANT_BADGE = "grantBadgeToUser";
    static let STORED_PROCEDURE_GET_INJURY_PREVENTION_WORKOUTS = "getInjuryPreventionWorkouts";
    static let STORED_PROCEDURE_EXCLUDE_EXERCISE = "excludeExercise";
    static let STORED_PROCEDURE_REMOVE_ACCOUNT = "removeAccount";
    static let ACCOUNT_TYPE_ADMIN = "A";
    static let ACCOUNT_TYPE_BETA = "B";
    static let ACCOUNT_TYPE_NORMAL = "N";
    static let ACCOUNT_TYPE_TRIAL = "T";
    static let ACCOUNT_TYPE_MOBILE_TRIAL = "M";
    static let EXERCISE_TYPE_WARM_UP = "W";
    static let EXERCISE_TYPE_STRETCH = "S";
    static let EXERCISE_TYPE_EXERCISE = "E";
    static let ROUTINE_CARDIO = "Cardio";
    static let ROUTINE_LEGS_AND_LOWER_BACK = "Legs & Lower Back";
    static let TABLE_COMPLETED_EXERCISE = "CompletedExercise";
    static let COLUMN_CURRENT_MUSCLE_GROUP = "currentMuscleGroup";
    static let COLUMN_DISPLAY_NAME = "DisplayName";
    static let COLUMN_DATE = "Date";
    static let COLUMN_TIME = "Time";
    static let COLUMN_EXERCISE_NAME = "ExerciseName";
    static let COLUMN_EXERCISE_WEIGHT = "ExerciseWeight";
    static let COLUMN_EXERCISE_REPS = "ExerciseReps";
    static let COLUMN_EXERCISE_DURATION = "ExerciseDuration";
    static let COLUMN_EXERCISE_DIFFICULTY = "ExerciseDifficulty";
    static let COLUMN_NOTES = "Notes";
    static let COLUMN_ACCOUNT_TYPE = "AccountType";
    static let COLUMN_EMAIL = "Email";
    static let COLUMN_ID = "ID";
    static let COLUMN_FIRST_NAME = "FirstName";
    static let COLUMN_LAST_NAME = "LastName";
    static let COLUMN_EARNED_POINTS = "EarnedPoints";
    static let COLUMN_TOTAL_BADGES = "TotalBadges";
    static let COLUMN_PROFILE_PICTURE_URL = "Url";
    static let COLUMN_FOLLOWING_ID = "FollowingId";
    static let COLUMN_SUBMITTED_BY = "SubmittedBy";
    static let COLUMN_VIDEO_URL = "VideoURL";
    static let COLUMN_DIRECTION = "Direction";
    static let COLUMN_EQUIPMENT_NAME = "EquipmentName";
    static let COLUMN_HAS_EQUIPMENT = "HasEquipment";
    static let COLUMN_PRIORITY = "Priority";
    static let SPACE_REGEX = "\\s";
    static let REGEX_EMAIL = "[a-zA-Z0-9]+([\\-\\.\\{\\}\\^\\+*_~]*[a-zA-Z0-9]+)*@[a-zA-Z0-9]+([\\.\\-]*[a-zA-Z0-9]+)*[\\.][a-zA-Z]{2}[A-Za-z]*";
    static let REGEX_FIELD = "[a-zA-Z0-9\\s\\-\\.\\{\\}\\^\\*\\(\\)\\[\\]\\$/;:,_~!@#%']+";
    static let REGEX_NAME_FIELD = "[a-zA-Z\\s\\-\\.']+";
    
    static func getValidateUserCredentialsServiceParameters(email: String, password: String) -> String
    {
        return PARAMETER_EMAIL + email + PARAMETER_AMPERSAND + PARAMETER_PASSWORD + password;
    }
    

    /**
     * Generates the forgot password parameter to send to the server.
     *
     * @param email     The user's email to add to the url.
     *
     * @return  The generated url parameter.
     */
    static func getForgotPasswordParameter(email: String) -> String
    {
        return PARAMETER_EMAIL + email;
    }

    /**
     * Generates the create account parameters.
     *
     * @param firstName     The first name of the user.
     * @param lastName      The last name of the user.
     * @param email         The user's email.
     * @param password      The password of the user.
     * @param accountType   The account type of the user.
     *
     * @return  The parameters for creating an account.
     */
    static func getAccountParameters(firstName: String, lastName: String, email: String, password: String, accountType: String) -> String
    {
        return PARAMETER_FIRST_NAME + firstName + PARAMETER_AMPERSAND +
                PARAMETER_LAST_NAME + lastName + PARAMETER_AMPERSAND +
                PARAMETER_EMAIL + email + PARAMETER_AMPERSAND +
                PARAMETER_PASSWORD + password + PARAMETER_AMPERSAND +
                PARAMETER_ACCOUNT_TYPE + accountType;
    }

    /**
     *  Generates the stored procedure parameters.
     *
     * @param name          The name of the stored procedure to call.
     * @param variables     The variable to send into the stored procedure.
     *
     * @return  The stored procedure method call with the parameters included.
     */
    static func generateStoredProcedureParameters(name: String, variables: Array<String>) -> String
    {
        var storedProcedureParameters = PARAMETER_DATA + name + PARAMETER_AMPERSAND + PARAMETER_VARIABLE
    
        let length = variables.count
    
        for i in 0 ..< length
        {
            storedProcedureParameters += ((i > 0) ? PARAMETER_DELIMITER : "") + variables[i]
        }

        return storedProcedureParameters;
    }

    /**
     * Generates the URL string to update the user's equipment list.
     *
     * @param email         The user's email.
     * @param variables     The list items to update.
     *
     * @return  The generated URL string.
     */
    static func generateEquipmentListVariables(email: String, variables: Array<String>) -> String
    {
        var parameters = PARAMETER_EMAIL + email
        parameters += generateListVariables(PARAMETER_AMPERSAND + PARAMETER_INSERTS, variables: variables)
        
        return parameters
    }
    
    /**
     * Generates the URL string to update the user's priority list.
     *
     * @param email         The user's email.
     * @param exercises     The list exercises to update.
     * @param priorities    The list priorities for the exercises.
     *
     * @return  The generated URL string.
     */
    static func generateExercisePriorityListVariables(email: String, exercises: Array<String>, priorities: Array<String>) -> String
    {
        let PARAMETER_EXERCISES = "&exercises=";
        let PARAMETER_PRIORITIES = "&priorities=";
        
        var parameters = PARAMETER_EMAIL + email
        parameters += generateListVariables(PARAMETER_EXERCISES, variables: exercises)
        parameters += generateListVariables(PARAMETER_PRIORITIES, variables: priorities)
        
        return parameters
    }
    
    /**
     * Generates the URL string for a list of variables.
     *
     * @param variableName  The name of the variable to add to teh URL string.
     * @param variables     The variables to add to the URL string.
     *
     * @return  The generated URL string.
     */
    static func generateListVariables(variableName: String, variables: Array<String>) -> String
    {
        var parameters = ""
        
        let length = variables.count
        for i in 0 ..< length
        {
            if (i == 0)
            {
                parameters += variableName
            }
            
            parameters += ((i > 0) ? PARAMETER_DELIMITER : "") + variables[i]
        }
        
        return parameters
    }
    
    /**
     * Generates the change password URL string.
     *
     * @param email             The user's email to change the password.
     * @param currentPassword   The user's current password.
     * @param newPassword       The user's new password.
     *
     * @return  The change password URL string.
     */
    static func generateChangePasswordVariables(email: String, currentPassword: String, newPassword: String) -> String
    {
        return PARAMETER_EMAIL + email +
                PARAMETER_AMPERSAND + PARAMETER_CURRENT_PASSWORD + currentPassword +
                PARAMETER_AMPERSAND + PARAMETER_PASSWORD + newPassword;
    }
}