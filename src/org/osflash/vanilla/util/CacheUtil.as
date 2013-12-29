/**
 * Created by sorenjepsen on 29/12/13.
 */
package org.osflash.vanilla.util {
import flash.utils.Dictionary;

import org.as3commons.lang.IllegalArgumentError;

public class CacheUtil implements ICache {

    private var cacheDictionary:Dictionary = new Dictionary();

    public function CacheUtil() {
    }


    public function addElement(key:*, value:*):void {
        cacheDictionary[key] = value;
    }


    public function getElement(key:*):* {
        if (!hasElement(key)) {
            throw new IllegalArgumentError("No cached element found for key: " + key);
        }

        return cacheDictionary[key];
    }


    public function hasElement(key:*):Boolean {
        return cacheDictionary[key] != null;
    }
}
}
