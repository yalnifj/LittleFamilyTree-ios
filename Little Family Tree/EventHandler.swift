//
//  EventHandler.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class EventHandler {
    
    private static var instance:EventHandler?
    
    static func getInstance() -> EventHandler {
        if EventHandler.instance == nil {
            EventHandler.instance = EventHandler()
        }
        return EventHandler.instance!
    }
    
    var subscribers = [String: [EventListener]]()
    
    func subscribe(topic:String, var listener:EventListener) {
        var listeners = subscribers[topic]
        if (listeners == nil) {
            listeners = [EventListener]()
        }
        listeners!.append(listener)
        listener.index = (listeners?.count)! - 1
        subscribers[topic] = listeners
    }
    
    func unSubscribe(topic:String, listener:EventListener) {
        var listeners = subscribers[topic];
        if (listeners != nil && listener.index != nil) {
            listeners!.removeAtIndex(listener.index!)
            subscribers[topic] = listeners
            //-- reindex
            for i in 0..<listeners!.count {
                listeners![i].index = i
            }
        }
    }
    
    func publish(topic:String, data:NSObject?) {
        let listeners = subscribers[topic];
        if (listeners != nil) {
            for l in listeners! {
                l.onEvent(topic, data:data);
            }
        }
    }

}

protocol EventListener {
    var index:Int? { get set }
    func onEvent(topic:String, data:NSObject?)
}