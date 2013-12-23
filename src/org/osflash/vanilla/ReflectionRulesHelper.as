/**
 * Created by sorenjepsen on 22/12/13.
 */
package org.osflash.vanilla {
import org.as3commons.lang.ClassUtils;
import org.as3commons.reflect.Accessor;
import org.as3commons.reflect.Field;
import org.as3commons.reflect.Metadata;
import org.as3commons.reflect.MetadataArgument;
import org.as3commons.reflect.Method;
import org.as3commons.reflect.Parameter;
import org.as3commons.reflect.Type;
import org.as3commons.reflect.Variable;

public class ReflectionRulesHelper {

    private static const METADATA_MARSHALL_TAG:String = "Marshall";
    private static const METADATA_FIELD_KEY:String = "field";
    private static const METADATA_TYPE_KEY:String = "type";

    public function ReflectionRulesHelper() {
    }

    public static function addReflectedConstructorRules(injectionMap:InjectionMap, reflectionMap:Type):void {
        const clazzMarshallingMetadata:Array = reflectionMap.getMetadata(METADATA_MARSHALL_TAG);
        if (!clazzMarshallingMetadata) {
            return;
        }

        const marshallingMetadata:Metadata = clazzMarshallingMetadata[0];
        const numArgs:uint = marshallingMetadata.arguments.length;

        for (var i:uint = 0; i < numArgs; i++) {
            var argument:MetadataArgument = MetadataArgument(marshallingMetadata.arguments[i]);
            if (argument.key == METADATA_FIELD_KEY) {
                const param:Parameter = reflectionMap.constructor.parameters[i];
                const arrayTypeHint:Class = extractArrayTypeHint(param.type);
                injectionMap.addConstructorField(new InjectionDetail(argument.value, param.type.clazz, true, param.type.hasMetadata("Enum"), arrayTypeHint));
            }
        }
    }


    public static function addReflectedFieldRules(injectionMap:InjectionMap, reflectionMap:Type):void {
        for each (var field:Field in reflectionMap.fields) {
            if (!field.hasMetadata(Metadata.TRANSIENT) && canAccess(field)) {
                const fieldMetadataEntries:Array = field.getMetadata(METADATA_MARSHALL_TAG);
                const fieldMetadata:Metadata = (fieldMetadataEntries) ? fieldMetadataEntries[0] : null;
                const arrayTypeHint:Class = extractArrayTypeHint(field.type, fieldMetadata);
                const sourceFieldName:String = extractFieldName(field, fieldMetadata);

                injectionMap.addField(field.name, new InjectionDetail(sourceFieldName, field.type.clazz, false, field.type.hasMetadata("Enum"), arrayTypeHint));
            }
        }
    }


    public static function addReflectedSetterRules(injectionMap:InjectionMap, reflectionMap:Type):void {
        for each (var method:Method in reflectionMap.methods) {

            const methodMarshallingMetadata:Array = method.getMetadata(METADATA_MARSHALL_TAG);
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
                    injectionMap.addMethod(method.name, new InjectionDetail(argument.value, param.type.clazz, false, false, arrayTypeHint));
                }
            }
        }
    }

    private static function canAccess(field:Field):Boolean {
        if (field is Variable) {
            return true;
        } else if (field is Accessor) {
            return (field as Accessor).writeable;
        }
        return false;
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
}
}
