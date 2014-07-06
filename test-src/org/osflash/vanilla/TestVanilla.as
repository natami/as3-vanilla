package org.osflash.vanilla
{

	import org.flexunit.Assert;
	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertNotNull;
	import org.flexunit.asserts.assertNull;
	import org.osflash.vanilla.testdata.PersonConstructorMetadata;
	import org.osflash.vanilla.testdata.PersonGenderEnum;
	import org.osflash.vanilla.testdata.PersonImplicitFields;
	import org.osflash.vanilla.testdata.PersonMutlipleArgumentSetterMetadata;
	import org.osflash.vanilla.testdata.PersonPublicFields;
	import org.osflash.vanilla.testdata.PersonPublicFieldsMetadata;
	import org.osflash.vanilla.testdata.PersonSetterMetadata;
	import org.osflash.vanilla.testdata.PersonTransientFields;
	import org.osflash.vanilla.testdata.PersonWithAddressConstructor;
	import org.osflash.vanilla.testdata.PersonWithAddressFields;

	/**
	 * @author Jonny
	 */
	public class TestVanilla
	{
		/**
		 * Plain old AS3 Object which we want to Marhsall into a strong type.
		 */
		public static const SOURCE : Object = {
			name : "jonny",
			age : 28,
			artists : ["mew", "tool"],
			gender : PersonGenderEnum.MALE
		};

		private var _marshaller : Vanilla;


		[Before]
		public function setup() : void
		{
			_marshaller = new Vanilla();
		}


		[Test]
		public function noNeedToMarshall() : void
		{
			assertEquals("string value", _marshaller.extract("string value", String));
			assertEquals(42, _marshaller.extract(42, Number));
			assertEquals(true, _marshaller.extract(true, Boolean));
		}


		[Test]
		public function withPublicFields() : void
		{
			const result : PersonPublicFields = _marshaller.extract(SOURCE, PersonPublicFields);
			assertEquals(SOURCE["name"], result.name);
			assertEquals(SOURCE["age"], result.age);
			assertEquals(SOURCE["artists"], result.artists);
			assertEquals(SOURCE["gender"], result.gender);
		}


		[Test]
		public function withImplicitFields() : void
		{
			const result : PersonImplicitFields = _marshaller.extract(SOURCE, PersonImplicitFields);
			assertEquals(SOURCE["name"], result.name);
			assertEquals(SOURCE["age"], result.age);
			assertEquals(SOURCE["artists"], result.artists);
			assertEquals(SOURCE["gender"], result.gender);
		}


		[Test(description="Marshalling doesn't require all fields in the TargetType to be present in the source object")]
		public function missingFieldsUsingFieldInjection() : void
		{
			const source : Object = { name : "dave" };
			const result : PersonPublicFields = _marshaller.extract(source, PersonPublicFields);
			assertEquals(source["name"], result.name);
			assertEquals(0, result.age);
			assertNull(result.artists);
		}


		[Test(description="Marshalling doesn't require all fields in the TargetType to be present in the source object")]
		public function missingFieldsUsingMutatorInjection() : void
		{
			const source : Object = { name : "dave" };
			const result : PersonSetterMetadata = _marshaller.extract(source, PersonSetterMetadata);
			assertEquals(source["name"], result.getName());
			assertEquals(0, result.getAge());
			assertNull(result.getArtists());
		}


		[Test(description="If the values dont exist in the source object, the AVM will either use the default value (if defined) or assign the default empty value for the method param's Type")]
		public function missingFieldsUsingMultipleArgumentSetter() : void
		{
			const source : Object = { name : "dave", gender : PersonGenderEnum.MALE };
			const result : PersonMutlipleArgumentSetterMetadata = _marshaller.extract(source, PersonMutlipleArgumentSetterMetadata);
			assertEquals(source["name"], result.getName());
			assertEquals(0, result.getAge());
			assertEquals(source["gender"], result.getGender());
			assertNull(result.getArtists());
		}


		[Test(description="Marshalling will ignore any extra fields present in the source object that don't exist in the TargetType")]
		public function withAdditionalFieldsInSource() : void
		{
			const source : Object = { name : "bob", age : 27, artists : [ "nin", "qotsa" ], ignoredExtraField : "ignored" };
			const result : PersonPublicFields = _marshaller.extract(source, PersonPublicFields);
			assertEquals(source["name"], result.name);
			assertEquals(source["age"], result.age);
			assertEquals(source["artists"], result.artists);
		}


		[Test]
		public function mismatchedDataType() : void
		{
			const source : Object = { name : "Jonny", age : "27" };

			try
			{
				_marshaller.extract(source, PersonPublicFields);
				Assert.fail("Expected MarshallingError");
			} catch (e : MarshallingError)
			{
				assertEquals(MarshallingError.TYPE_MISMATCH, e.errorID);
			}
		}


		[Test]
		public function missingRequiredFieldDefinedByConstructorInjection() : void
		{
			const source : Object = { name : "Jonny" };

			try
			{
				_marshaller.extract(source, PersonConstructorMetadata);
				Assert.fail("Expected MarshallingError");
			} catch (e : MarshallingError)
			{
				assertEquals(MarshallingError.MISSING_REQUIRED_FIELD, e.errorID);
			}
		}


		[Test]
		public function withMetadataDefinedConstructorArguments() : void
		{
			const result : PersonConstructorMetadata = _marshaller.extract(SOURCE, PersonConstructorMetadata);
			assertEquals(SOURCE["name"], result.name);
			assertEquals(SOURCE["age"], result.age);
			assertEquals(SOURCE["artists"], result.artists);
			assertEquals(SOURCE["gender"], result.gender);
		}


		[Test]
		public function withMetadataDefinedSetters() : void
		{
			const result : PersonSetterMetadata = _marshaller.extract(SOURCE, PersonSetterMetadata);
			assertEquals(SOURCE["name"], result.getName());
			assertEquals(SOURCE["age"], result.getAge());
			assertEquals(SOURCE["artists"], result.getArtists());
			assertEquals(SOURCE["gender"], result.getGender());
		}


		[Test]
		public function withMetadataDefinedMultipleArgumentSetter() : void
		{
			const result : PersonMutlipleArgumentSetterMetadata = _marshaller.extract(SOURCE, PersonMutlipleArgumentSetterMetadata);
			assertEquals(SOURCE["name"], result.getName());
			assertEquals(SOURCE["age"], result.getAge());
			assertEquals(SOURCE["artists"], result.getArtists());
			assertEquals(SOURCE["gender"], result.getGender());
		}


		[Test]
		public function withMetadataFields() : void
		{
			const source : Object = {
				myName : "Dave",
				myAge : 28,
				myGender : "FEMALE"
			};
			const result : PersonPublicFieldsMetadata = _marshaller.extract(source, PersonPublicFieldsMetadata);
			assertEquals(source["myName"], result.name);
			assertEquals(source["myAge"], result.age);
			assertEquals(source["myGender"], result.gender.value);
		}


		[Test]
		public function withNestedObjectFields() : void
		{
			const source : Object = {
				name : "Jonny",
				address : {
					address1 : "My House",
					city : "London"
				}
			};

			const result : PersonWithAddressFields = _marshaller.extract(source, PersonWithAddressFields);
			assertEquals(source["name"], result.name);
			assertNotNull(result.address);
			assertEquals(source["address"]["address1"], result.address.address1);
			assertEquals(source["address"]["city"], result.address.city);
		}


		[Test]
		public function withNestedObjectConstructorMetadata() : void
		{
			const source : Object = {
				name : "Jonny",
				address : {
					address1 : "My House",
					city : "London"
				},
				gender : PersonGenderEnum.MALE
			};

			const result : PersonWithAddressConstructor = _marshaller.extract(source, PersonWithAddressConstructor);
			assertEquals(source["name"], result.name);
			assertNotNull(result.address);
			assertEquals(source["address"]["address1"], result.address.address1);
			assertEquals(source["address"]["city"], result.address.city);
			assertEquals(source["gender"], result.gender);
		}


		[Test(description="Marshalling ignores Transient variables")]
		public function transientVariablesAreIgnored() : void
		{
			const source : Object = { name : "dave", age : 22 };
			const result : PersonTransientFields = _marshaller.extract(source, PersonTransientFields);
			assertEquals(22, result.age);
			assertNull(result.name);
		}
	}
}