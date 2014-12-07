package org.osflash.vanilla.util
{

	import org.flexunit.asserts.assertEquals;
	import org.flexunit.asserts.assertFalse;
	import org.flexunit.asserts.assertTrue;

	public class TestCacheUtil
	{

		private static const KEY : String = "cache_key";
		private static const VALUE : Object = {value : "Some value"};
		private var cacheUtil : CacheUtil;


		[Before]
		public function before() : void
		{
			cacheUtil = new CacheUtil();
		}


		[Test]
		public function testAddElementToCacheWhenAddedThenCacheExists() : void
		{
			performAddElement();

			assertEquals(VALUE, cacheUtil.getElement(KEY));
		}


		[Test]
		public function testHasElementWhenElementIsCachedThenReturnsTrue() : void
		{
			performAddElement();

			assertTrue(cacheUtil.hasElement(KEY));
		}


		[Test]
		public function testHasElementWhenElementIsNotCachedThenReturnsFalse() : void
		{
			assertFalse(cacheUtil.hasElement(KEY));
		}


		[Test]
		public function testGetElementWhenElementIsCachedThenReturnsElement() : void
		{
			performAddElement();

			assertEquals(VALUE, performGetElement());
		}


		[Test(expects="org.as3commons.lang.IllegalArgumentError")]
		public function testGetElementWhenElementIsNotCachedThenThrowsException() : void
		{
			performGetElement();
		}


		private function performAddElement() : void
		{
			cacheUtil.addElement(KEY, VALUE);
		}


		private function performGetElement() : Object
		{
			return cacheUtil.getElement(KEY);
		}
	}
}
