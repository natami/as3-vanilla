package org.osflash.vanilla {
import flash.utils.getQualifiedClassName;

import org.as3commons.lang.ClassUtils;
import org.as3commons.lang.ObjectUtils;
import org.as3commons.reflect.Accessor;
import org.as3commons.reflect.Field;
import org.as3commons.reflect.Metadata;
import org.as3commons.reflect.MetadataArgument;
import org.as3commons.reflect.Method;
import org.as3commons.reflect.Parameter;
import org.as3commons.reflect.Type;
import org.as3commons.reflect.Variable;

public class Vanilla {
    private static const ENUM_TAG:String = "Enum";
    private static const METADATA_TAG:String = "Marshall";
    private static const METADATA_FIELD_KEY:String = "field";
    private static const METADATA_TYPE_KEY:String = "type";


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
        const injectionMap:InjectionMap = new InjectionMap();
        const reflectionMap:Type = Type.forClass(targetType);
        addReflectedRules(injectionMap, reflectionMap);

        // Create a new isntance of the targetType; and then inject the values from the source object into it
        const target:* = instantiate(targetType, fetchConstructorArgs(source, injectionMap.getConstructorFields()));
        if (!isEnum(reflectionMap)) {
            injectFields(source, target, injectionMap);
            injectMethods(source, target, injectionMap);
        }

        return target;
    }


    private function fetchConstructorArgs(source:Object, constructorFields:Array):Array {
        const result:Array = [];
        for (var i:uint = 0; i < constructorFields.length; i++) {
            result.push(extractValue(source, constructorFields[i]));
        }
        return result;
    }


    private function injectFields(source:Object, target:*, injectionMap:InjectionMap):void {
        const fieldNames:Array = injectionMap.getFieldNames();
        for each (var fieldName:String in fieldNames) {
            target[fieldName] = extractValue(source, injectionMap.getField(fieldName));
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


    private static function instantiate(targetType:Class, ctorArgs:Array):* {
        return ClassUtils.newInstance(targetType, ctorArgs);
    }


    private static function addReflectedRules(injectionMap:InjectionMap, reflectionMap:Type):void {
        addReflectedConstructorRules(injectionMap, reflectionMap);
        addReflectedFieldRules(injectionMap, reflectionMap.fields);
        addReflectedSetterRules(injectionMap, reflectionMap.methods);
    }


    private static function addReflectedConstructorRules(injectionMap:InjectionMap, reflectionMap:Type):void {
        const clazzMarshallingMetadata:Array = reflectionMap.getMetadata(METADATA_TAG);
        if (!clazzMarshallingMetadata) {
            return;
        }

        const marshallingMetadata:Metadata = clazzMarshallingMetadata[0];
        const numArgs:uint = marshallingMetadata.arguments.length;

        for (var i:uint = 0; i < numArgs; i++) {
            var argument:MetadataArgument = marshallingMetadata.arguments[i];
            if (argument.key == METADATA_FIELD_KEY) {
                const param:Parameter = reflectionMap.constructor.parameters[i];
                const arrayTypeHint:Class = extractArrayTypeHint(param.type);
                injectionMap.addConstructorField(new InjectionDetail(argument.value, param.type.clazz, true, arrayTypeHint));
            }
        }
    }


    private static function addReflectedFieldRules(injectionMap:InjectionMap, fields:Array):void {
        for each (var field:Field in fields) {
            if (!field.hasMetadata(Metadata.TRANSIENT) && canAccess(field)) {
                const fieldMetadataEntries:Array = field.getMetadata(METADATA_TAG);
                const fieldMetadata:Metadata = (fieldMetadataEntries) ? fieldMetadataEntries[0] : null;
                const arrayTypeHint:Class = extractArrayTypeHint(field.type, fieldMetadata);
                const sourceFieldName:String = extractFieldName(field, fieldMetadata);

                injectionMap.addField(field.name, new InjectionDetail(sourceFieldName, field.type.clazz, false, arrayTypeHint));
            }
        }
    }


    private static function addReflectedSetterRules(injectionMap:InjectionMap, methods:Array):void {
        for each (var method:Method in methods) {

            const methodMarshallingMetadata:Array = method.getMetadata(METADATA_TAG);
            if (methodMarshallingMetadata == null) {
                continue;
            }

            const metadata:Metadata = methodMarshallingMetadata[0];
            const numArgs:uint = metadata.arguments.length;

            for (var i:uint = 0; i < numArgs; i++) {
                var argument:MetadataArgument = metadata.arguments[i];
                if (argument.key == METADATA_FIELD_KEY) {
                    const param:Parameter = method.parameters[i];
                    const arrayTypeHint:Class = extractArrayTypeHint(param.type, metadata);
                    injectionMap.addMethod(method.name, new InjectionDetail(argument.value, param.type.clazz, false, arrayTypeHint));
                }
            }
        }
    }


    private static function extractFieldName(field:Field, metadata:Metadata):String {
        // See if a taget fieldName has been defined in the Metadata.
        if (metadata) {
            const numArgs:uint = metadata.arguments.length;
            for (var i:uint = 0; i < numArgs; i++) {
                var argument:MetadataArgument = metadata.arguments[i];
                if (argument.key == METADATA_FIELD_KEY) {
                    return argument.value;
                }
            }
        }

        // Assume it's a 1 to 1 mapping.
        return field.name;
    }


    private static function extractArrayTypeHint(typeHint:Type, metadata:Metadata = null):Class {
        // Vectors carry their own typeHint hint.
        if (typeHint.parameters && typeHint.parameters[0] is Class) {
            return typeHint.parameters[0];
        }

        // Otherwise we will look for some "typeHint" metadata, if it was defined.
        else if (metadata) {
            const numArgs:uint = metadata.arguments.length;
            for (var i:uint = 0; i < numArgs; i++) {
                var argument:MetadataArgument = metadata.arguments[i];
                if (argument.key == METADATA_TYPE_KEY) {
                    const clazz:Class = ClassUtils.forName(argument.value);
                    return clazz;
                }
            }
        }

        // No typeHint hint.
        return null;
    }


    private static function canAccess(field:Field):Boolean {
        if (field is Variable) {
            return true;
        } else if (field is Accessor) {
            return (field as Accessor).writeable;
        }
        return false;
    }


    private static function isVector(obj:*):Boolean {
        return (getQualifiedClassName(obj).indexOf('__AS3__.vec::Vector') == 0);
    }


    private static function isEnum(reflectionMap:Type):Boolean {
        return reflectionMap.hasMetadata(ENUM_TAG);
    }
}
}