//
//  AgePicker.swift
//  citZen
//
//  Created by Luigi Mazzarella on 18/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class AgePicker: UIPickerView, UIPickerViewDelegate, UIPickerViewDataSource {
	
	var items : [String] = ["13-20","21-30","31-50","50+"]
	
	func numberOfComponents(in pickerView: UIPickerView) -> Int {
		return items.count
	}
	
	func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
		return 1
	}
	
	

}
