//
//  EditLocationViewController.swift
//  Intencity
//
//  Created by Greg Dalfonso on 4/8/17.
//  Copyright © 2017 Nick Piscopio. All rights reserved.
//

import Foundation
import UIKit

class EditLocationViewController: UIViewController, ServiceDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We have a generic service event because we do not have to handle multiple events in this view.
        _ = ServiceTask(event: ServiceEvent.GENERIC,
                        delegate: self,
                        serviceURL: Constant.SERVICE_STORED_PROCEDURE,
                        params: Constant.generateStoredProcedureParameters(Constant.STORED_PROCEDURE_GET_FITNESS_LOCATIONS, variables: [ "greg.dalfonso@gmail.com" ]) as NSString)
    }
    
    @IBAction func addPressed(_ sender: Any) {
        let vc = storyboard!.instantiateViewController(withIdentifier: Constant.EDIT_EQUIPMENT_VIEW_CONTROLLER) as! EditEquipmentViewController
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func onRetrievalSuccessful(_ event: Int, result: String) {
        print("The result is: \(result) and the event is: \(event)")
    }
    
    func onRetrievalFailed(_ event: Int) {
        print(event)
    }
}
