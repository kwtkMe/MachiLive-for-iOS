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
    static let AnnotationAddedOrEdited = Notification.Name("annotation_added_or_edded")
    static let AnnotationRemove = Notification.Name("annotation_remove")
    static let AnnotationRemoved = Notification.Name("annotation_removed")
    static let AnnotationShare = Notification.Name("annotation_share")
    static let AnnotationShared = Notification.Name("annotation_shared")
    static let PlayerStatusChanged = Notification.Name("player_status_changed")
    static let PlayingItemChange = Notification.Name("playing_item_change")
    static let PlayingItemChanged = Notification.Name("playing_item_changed")
}
