//
//  Extentions.swift
//  iMachiLive
//
//  Created by RIVER on 2019/02/06.
//  Copyright © 2019 Reverse. All rights reserved.
//

import Foundation
import UIKit

extension Notification.Name {
    static let LoginstateChanged = Notification.Name("loginstate_changed")
    static let UserInfoUpdate = Notification.Name("username_update")
    static let AnnotationAdd = Notification.Name("annotation_add")
    static let AnnotationAdded = Notification.Name("annotation_added")
    static let AnnotationEdit = Notification.Name("annotation_edit")
    static let AnnotationEdited = Notification.Name("annotation_edited")
    static let AnnotationRemoved = Notification.Name("annotation_removed")
    static let PlayingItemChanged = Notification.Name("playing_item_changed")
}
