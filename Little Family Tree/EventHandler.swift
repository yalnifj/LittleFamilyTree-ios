//
//  EventHandler.swift
//  Little Family Tree
//
//  Created by Melissa on 11/25/15.
//  Copyright © 2015 Melissa. All rights reserved.
//

import Foundation

class EventHandler {
    
    fileprivate static var instance:EventHandler?
    
    static func getInstance() -> EventHandler {
        if EventHandler.instance == nil {
            EventHandler.instance = EventHandler()
        }
        return EventHandler.instance!
    }
    
    var subscribers = [String: [Int : EventListener]]()
    var counter = 1
    
    func subscribe(_ topic:String, listener:EventListener) {
        var listeners = subscribers[topic]
        if (listeners == nil) {
            listeners = [Int : EventListener]()
        }
        if listener.listenerIndex == nil {
            counter += 1
            listener.setListenerIndex(counter)
        }
        listeners![listener.listenerIndex!] = listener
        subscribers[topic] = listeners
    }
    
    func unSubscribe(_ topic:String, listener:EventListener) {
        var listeners = subscribers[topic]
        if (listeners != nil && listener.listenerIndex != nil) {
            listeners!.removeValue(forKey: listener.listenerIndex!)
            subscribers[topic] = listeners
        }
    }
    
    func publish(_ topic:String, data:NSObject?) {
        let listeners = subscribers[topic];
        if (listeners != nil) {
            for l in listeners!.values {
                l.onEvent(topic, data:data);
            }
        }
    }

}

protocol EventListener {
    var listenerIndex:Int? { get set }
    func setListenerIndex(_ index:Int)
    func onEvent(_ topic:String, data:NSObject?)
}
