//  Notes
//
//  Created by farshad on 9/4/18.
//  Copyright © 2018 FarshadJahanmanesh. All rights reserved.
//
import Foundation
///our entities are protocls, so we can pass them every where and do not care about the properies
public protocol NoteProtocol {
    var text: String { get }
    var date: Double { get }
}
