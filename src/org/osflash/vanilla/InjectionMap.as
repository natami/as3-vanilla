package org.osflash.vanilla {
internal class InjectionMap {
    private var _constructorFields:Array = [];
    private var _fields:Object = {};
    private var _methods:Object = {};

    public function addConstructorField(injectionDetails:InjectionDetail):void {
        _constructorFields.push(injectionDetails);
    }

    public function getConstructorFields():Array {
        return _constructorFields;
    }

    public function addField(fieldName:String, injectionDetails:InjectionDetail):void {
        _fields[fieldName] = injectionDetails;
    }

    public function getFieldNames():Array {
        return getNames(_fields);
    }

    public function getField(fieldName:String):InjectionDetail {
        return _fields[fieldName];
    }

    public function addMethod(methodName:String, injectionDetails:InjectionDetail):void {
        _methods[methodName] ||= [];
        (_methods[methodName] as Array).push(injectionDetails);
    }

    public function getMethodsNames():Array {
        return getNames(_methods);
    }

    public function getMethod(methodName:String):Array {
        return _methods[methodName];
    }

    private static function getNames(object:Object):Array {
        const result:Array = [];
        for (var name:String in object) {
            result.push(name);
        }
        return result;
    }

    public function toString():String {
        var result:String = "[FieldMap ";

        result += "ctor:{" + _constructorFields + "}, ";
        result += "fields:{" + _fields + "}, ";

        result += "methods:{";
        for (var methodName:String in _methods) {
            result += methodName + "(" + getMethod(methodName) + "),";
        }
        result += "}";

        result += "]";
        return result;
    }
}
}
