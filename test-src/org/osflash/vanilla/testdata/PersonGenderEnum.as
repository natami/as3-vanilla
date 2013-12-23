/**
 * Created by sorenjepsen on 08/12/13.
 */
package org.osflash.vanilla.testdata {

[Enum]
public class PersonGenderEnum {

    public static const MALE:PersonGenderEnum = new PersonGenderEnum("MALE");
    public static const FEMALE:PersonGenderEnum = new PersonGenderEnum("FEMALE");

    private var _value:String;

    public function PersonGenderEnum(gender:String) {
        this._value = gender;
    }


    public function get value():String {
        return _value;
    }


    public function toString():String {
        return _value;
    }
}
}
