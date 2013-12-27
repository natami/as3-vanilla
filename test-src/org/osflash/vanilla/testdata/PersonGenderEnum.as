/**
 * Created by sorenjepsen on 08/12/13.
 */
package org.osflash.vanilla.testdata {
import org.osflash.vanilla.IEnum;

public class PersonGenderEnum implements IEnum {

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
