package org.osflash.vanilla
{

	public class InjectionDetail
	{
		public function InjectionDetail(fieldName : String, type : Class, required : Boolean, arrayTypeHint : Class)
		{
			_fieldName = fieldName;
			_type = type;
			_required = required;
			_arrayTypeHint = arrayTypeHint;
		}


		private var _fieldName : String;
		private var _required : Boolean;

		private var _type : Class;

		public function get type() : Class
		{
			return _type;
		}


		private var _arrayTypeHint : Class;

		public function get arrayTypeHint() : Class
		{
			return _arrayTypeHint;
		}


		public function get name() : String
		{
			return _fieldName;
		}


		public function get isRequired() : Boolean
		{
			return _required;
		}


		public function toString() : String
		{
			var result : String = _fieldName + "<" + type + ">";
			if (arrayTypeHint)
			{
				result += "->" + arrayTypeHint;
			}
			return result;
		}
	}
}
