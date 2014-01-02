package org.osflash.vanilla {

import avmplus.getQualifiedClassName;

import org.as3commons.lang.ClassUtils;
import org.as3commons.lang.ObjectUtils;
import org.as3commons.reflect.Type;
import org.osflash.vanilla.caching.InjectionMapCache;

public class Vanilla {

    private const injectionMapCache:InjectionMapCache = InjectionMapCache.getInstance();


    /**
     * Attempts to extract properties from the supplied source object into an instance of the supplied targetType.
     *
     * @param source        Object which contains properties that you wish to transfer to a new instance of the
     *                        supplied targetType Class.
     * @param targetType    The target Class of which an instance will be returned.
     * @return                An instance of the supplied targetType containing all the properties extracted from
     *                        the supplied source object.
     */
    public function extract(source:Object, targetType:Class):* {
        // Catch the case where we've been asked to extract a value which is already of the intended targetType;
        // this can often happen when Vanilla is recursing, in which case there is nothing to do.
        if (source is targetType) {
            return source;
        }

        // Construct an InjectionMap which tells us how to inject fields from the source object into
        // the Target class.
        const injectionMap:InjectionMap = injectionMapCache.getInjectionMapForClass(targetType);

        // Create a new instance of the targetType; and then inject the values from the source object into it
        return instantiateAndInjectValues(source, targetType, injectionMap);
    }

    private function instantiateAndInjectValues(source:*, targetType:Class, injectionMap:InjectionMap):* {
        var target:*;

        if (isEnum(targetType)) {
            target = instantiateEnum(targetType, source);
        } else if (isVector(targetType)) {
            target = extractVector(source, targetType, Type.forClass(targetType).parameters[0]);
        } else {
            target = instantiateClass(targetType, fetchConstructorArgs(source, injectionMap));

            injectFields(source, target, injectionMap);
            injectMethods(source, target, injectionMap);
        }

        return target;
    }


    private function fetchConstructorArgs(source:Object, injectionMap:InjectionMap):Array {
        const result:Array = [];
        const constructorFields:Array = injectionMap.getConstructorFields();
        for (var i:uint = 0; i < constructorFields.length; i++) {
            var injectionDetail:InjectionDetail = constructorFields[i];
            result.push(extractValue(source, injectionDetail));
        }
        return result;
    }


    private function injectFields(source:Object, target:*, injectionMap:InjectionMap):void {
        const fieldNames:Array = injectionMap.getFieldNames();
        for each (var fieldName:String in fieldNames) {
            const injectionDetail:InjectionDetail = injectionMap.getField(fieldName);
            target[fieldName] = extractValue(source, injectionDetail);
        }
    }

    private function injectMethods(source:Object, target:*, injectionMap:InjectionMap):void {
        const methodNames:Array = injectionMap.getMethodsNames();
        for each (var methodName:String in methodNames) {
            const values:Array = [];
            for each (var injectionDetail:InjectionDetail in injectionMap.getMethod(methodName)) {
                values.push(extractValue(source, injectionDetail));
            }
            (target[methodName] as Function).apply(null, values);
        }
    }


    private function extractValue(source:Object, injectionDetail:InjectionDetail):* {
        var value:* = source[injectionDetail.name];

        // Is this a required injection?
        if (injectionDetail.isRequired && value === undefined) {
            throw new MarshallingError("Required value " + injectionDetail + " does not exist in the source object.", MarshallingError.MISSING_REQUIRED_FIELD);
        }

        if (value) {
            // automatically coerce simple types.
            if (!ObjectUtils.isSimple(value)) {
                value = extract(value, injectionDetail.type);
            }

            // Collections are harder, we need to coerce the contents.
            else if (value is Array) {
                if (isVector(injectionDetail.type)) {
                    value = extractVector(value, injectionDetail.type, injectionDetail.arrayTypeHint);
                } else if (injectionDetail.arrayTypeHint) {
                    value = extractTypedArray(value, injectionDetail.arrayTypeHint);
                }
            } else if (isEnum(injectionDetail.type)) {
                value = extract(value, injectionDetail.type);
            }

            // refuse to allow any automatic coercing to occur.
            if (!(value is injectionDetail.type)) {
                throw new MarshallingError("Could not coerce `" + injectionDetail.name + "` (value: " + value + " <" + Type.forInstance(value).clazz + "]>) from source object to " + injectionDetail.type + " on target object", MarshallingError.TYPE_MISMATCH);
            }
        }

        return value;
    }


    private function extractTypedArray(source:Array, targetClassType:Class):Array {
        const result:Array = new Array(source.length);
        for (var i:uint = 0; i < source.length; i++) {
            result[i] = extract(source[i], targetClassType);
        }
        return result;
    }


    private function extractVector(source:Array, targetVectorClass:Class, targetClassType:Class):* {
        const result:* = ClassUtils.newInstance(targetVectorClass);
        for (var i:uint = 0; i < source.length; i++) {
            if (isVector(targetClassType)) {
                var classType:Type = Type.forClass(targetClassType);
                result[i] = extractVector(source[i], targetClassType, classType.parameters[0]);
            } else {
                result[i] = extract(source[i], targetClassType);
            }
        }
        return result;
    }


    private static function instantiateClass(targetType:Class, ctorArgs:Array):* {
        return ClassUtils.newInstance(targetType, ctorArgs);
    }


    private static function instantiateEnum(targetType:Class, source:Object):* {
        return targetType[source];
    }


    private static function isVector(obj:*):Boolean {
        return (getQualifiedClassName(obj).indexOf('__AS3__.vec::Vector') == 0);
    }


    private static function isEnum(clazz:Class):Boolean {
        return ClassUtils.isImplementationOf(clazz, IEnum);
    }
}
}