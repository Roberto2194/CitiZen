//
//  PushNotificationSender.swift
//  citZen
//
//  Created by Luigi Mazzarella on 26/05/2020.
//  Copyright © 2020 Luigi Mazzarella. All rights reserved.
//

import UIKit

class PushNotificationSender {
	func sendPushNotification(to token: String, title: String, body: String) {
		let urlString = "https://fcm.googleapis.com/fcm/send"
		let url = NSURL(string: urlString)!
		let paramString: [String : Any] = ["to" : token,
										   "notification" : ["title" : title, "body" : body],
										   "data" : ["user" : "test_id"]
		]
		let request = NSMutableURLRequest(url: url as URL)
		request.httpMethod = "POST"
		request.httpBody = try? JSONSerialization.data(withJSONObject:paramString, options: [.prettyPrinted])
		request.setValue("application/json", forHTTPHeaderField: "Content-Type")
		request.setValue("AAAADmgzTWk:APA91bH4kihaK0c7Ru-jvHeG_cBzpXGAgQtY4CKPqsMFVEzH8FN_doIGNe2_epYsxWaIdFyh-7mj8PKe8ONEF1F69WvmVGOjkyx1sfkRE8OXvDC_zbrOLRDyxzpI1nIL89IzBkaoFjZ5", forHTTPHeaderField: "Authorization")
		let task =  URLSession.shared.dataTask(with: request as URLRequest)  { (data, response, error) in
			do {
				if let jsonData = data {
					if let jsonDataDict  = try JSONSerialization.jsonObject(with: jsonData, options: JSONSerialization.ReadingOptions.allowFragments) as? [String: AnyObject] {
						NSLog("Received data:\n\(jsonDataDict))")
					}
				}
			} catch let err as NSError {
				print(err.debugDescription)
			}
		}
		task.resume()
	}
}
