/**
 * Created by sorenjepsen on 08/12/13.
 */
package org.osflash.vanilla.testdata {
import org.flexunit.experimental.theories.internals.ParameterizedAssertionError;

[Enum]
[Marshall(field="gender")]
public class PersonGenderEnum {

    public static const MALE:PersonGenderEnum = new PersonGenderEnum("MALE");
    public static const FEMALE:PersonGenderEnum = new PersonGenderEnum("FEMALE");

    private var _gender:String;

    public function PersonGenderEnum(gender:String) {
        this._gender = gender;
    }


    public function get gender():String {
        return _gender;
    }
}
}
