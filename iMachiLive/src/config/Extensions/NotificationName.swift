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
    // ログインについて
    static let LoginstateChange = Notification.Name("loginstate_change")
    static let LoginstateChanged = Notification.Name("loginstate_changed")
    // ユーザ情報について
    static let UserInfoUpdate = Notification.Name("username_update")
    // MachiLive!について
    static let MachiLiveStatusChanged = Notification.Name("machilive_status_changed")
    // アノテーションの操作について
    static let AnnotationAdd = Notification.Name("annotation_add")
    static let AnnotationAdded = Notification.Name("annotation_added")
    static let AnnotationEdit = Notification.Name("annotation_edit")
    static let AnnotationEdited = Notification.Name("annotation_edited")
    static let AnnotationAddedOrEdited = Notification.Name("annotation_added_or_edded")
    static let AnnotationRemove = Notification.Name("annotation_remove")
    static let AnnotationRemoved = Notification.Name("annotation_removed")
    static let AnnotationShare = Notification.Name("annotation_share")
    static let AnnotationShared = Notification.Name("annotation_shared")
}
