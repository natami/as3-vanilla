/**
 * Created by sorenjepsen on 29/12/13.
 */
package org.osflash.vanilla.caching
{

	import mockolate.mock;
	import mockolate.received;
	import mockolate.runner.MockolateRunner;

	import org.flexunit.assertThat;
	import org.flexunit.asserts.assertEquals;
	import org.hamcrest.object.instanceOf;
	import org.osflash.vanilla.InjectionMap;
	import org.osflash.vanilla.testdata.Address;
	import org.osflash.vanilla.util.ICache;

	MockolateRunner;

	[RunWith("mockolate.runner.MockolateRunner")]
	public class TestInjectionMapCache
	{

		private static const TESTCLASS : Class = Address;
		[Mock]
		public var cacheUtil : ICache;
		private var injectionMapCache : InjectionMapCache = InjectionMapCache.getInstance();


		[Before]
		public function before() : void
		{
			injectionMapCache = InjectionMapCache.getInstance();
			injectionMapCache.injectionCache = cacheUtil;
		}


		[Test]
		public function testGetInjectionMapForClassWhenNotCachedThenInjectionMapIsCreated() : void
		{
			performGetInjectionMapForClass();

			assertThat(cacheUtil, received().method('addElement').args(TESTCLASS, instanceOf(InjectionMap)).once());
		}


		[Test]
		public function testGetInjectionMapForClassWhenCachedThenInjectionMapIsReturnedFromCache() : void
		{
			mockCacheUtilHasElementToReturnTrue();

			performGetInjectionMapForClass();

			assertThat(cacheUtil, received().method('getElement').args(TESTCLASS).once());
		}


		[Test]
		public function testGetInstanceWhenCalledAlwaysReturnsSameInstance() : void
		{
			assertEquals(injectionMapCache, InjectionMapCache.getInstance());
		}


		[Test(expects="flash.errors.IllegalOperationError")]
		public function testClassConstructionWhenClassIsInitializedUsingNewThenThrowException() : void
		{
			injectionMapCache = new InjectionMapCache(String);
		}


		private function performGetInjectionMapForClass() : void
		{
			injectionMapCache.getInjectionMapForClass(TESTCLASS);
		}


		private function mockCacheUtilHasElementToReturnTrue() : void
		{
			mock(cacheUtil).method('hasElement').args(TESTCLASS).returns(true);
		}

	}
}
