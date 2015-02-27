@import <Foundation/CPCache.j>


/*
 * CPCacheTest tests all methods from CPCache
 */
@implementation CPCacheTest : OJTestCase<CPCacheDelegate>
{
    // Parameters to check delegate
    int     _countDelegateExecuted;
    CPArray _caches;
    CPArray _objects;
}

- (void)setUp
{
    // Initialize data to check delegate
    _countDelegateExecuted = 0;
    _caches = [[CPArray alloc] init];
    _objects = [[CPArray alloc] init];
}


/*
 * Delegate method, called when an object is evicted
 */
- (void)cache:(CPCache)cache willEvictObject:(id)obj
{
    _countDelegateExecuted++;
    [_caches addObject:cache];
    [_objects addObject:obj];
}


/*
 * Tests methods of CPCache
 */
- (void)testInit
{
    var cache = [[CPCache alloc] init];

    [self assert:CPCache equals:[cache class]];
    [self assert:0 equals:[cache countLimit]];
    [self assert:0 equals:[cache totalCostLimit]];
    [self assert:nil equals:[cache delegate]];
}

- (void)testObjectForKey
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setObject:@"Object1" forKey:@"key1"];

    // With valid key
    [self assert:@"Object1" equals:[cache objectForKey:@"key1"]];

    // With invalid key
    [self assert:nil equals:[cache objectForKey:@"key666"]];

    // With nil key
    [self assert:nil equals:[cache objectForKey:nil]];
}

- (void)testSetObjectForKeyDefault
{
    // Setup cache
    var cache = [[CPCache alloc] init];

    // Check result when add key in empty cache
    [cache setObject:@"Object1" forKey:@"key1"]
    [self assert:@"Object1" equals:[cache objectForKey:@"key1"]];

    // Check result when add a key with existing key
    [cache setObject:@"Object2" forKey:@"key1"]
    [self assert:@"Object2" equals:[cache objectForKey:@"key1"]];
}

- (void)testSetObjectForKeyWithExistingKey
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setObject:@"Object1" forKey:@"key1"];
    [cache setObject:@"Object2" forKey:@"key2"];

    // Check result when add key in cache with total cost limit
    [cache setObject:@"Object3" forKey:@"key1"];
    [self assert:@"Object3" equals:[cache objectForKey:@"key1"]];
    [self assert:@"Object2" equals:[cache objectForKey:@"key2"]];

    // Check delegate
    [self assert:1 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];
}

- (void)testSetObjectForKeyDiscardByCost
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setTotalCostLimit:100];
    [cache setObject:@"Object1" forKey:@"key1" cost:50];
    [cache setObject:@"Object2" forKey:@"key2" cost:50];

    // Check result when add key in cache with total cost limit
    [cache setObject:@"Object3" forKey:@"key3" cost:1];
    [self assert:nil equals:[cache objectForKey:@"key1"]];
    [self assert:@"Object2" equals:[cache objectForKey:@"key2"]];
    [self assert:@"Object3" equals:[cache objectForKey:@"key3"]];

    // Check delegate
    [self assert:1 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];
}

- (void)testSetObjectForKeyDiscardByCount
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setCountLimit:2];
    [cache setObject:@"Object1" forKey:@"key1"];
    [cache setObject:@"Object2" forKey:@"key2"];

    // Check result when add key in cache with count limit
    [cache setObject:@"Object3" forKey:@"key3"];
    [self assert:nil equals:[cache objectForKey:@"key1"]];
    [self assert:@"Object2" equals:[cache objectForKey:@"key2"]];
    [self assert:@"Object3" equals:[cache objectForKey:@"key3"]];

    // Check delegate
    [self assert:1 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];
}

- (void)testRemoveObjectForKey
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setObject:@"Object1" forKey:@"key1"];

    // Remove object
    [cache removeObjectForKey:@"key1"];
    [self assert:nil equals:[cache objectForKey:@"key1"]];

    // Check delegate
    [self assert:1 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];
}

- (void)testRemoveAllObjects
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setObject:@"Object1" forKey:@"key1"];
    [cache setObject:@"Object2" forKey:@"key2"];

    // Remove all objects
    [cache removeAllObjects];
    [self assert:nil equals:[cache objectForKey:@"key1"]];
    [self assert:nil equals:[cache objectForKey:@"key2"]];

    // Check delegate
    [self assert:2 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];
    [self assert:cache equals:[_caches objectAtIndex:1]];
    [self assert:@"Object2" equals:[_objects objectAtIndex:1]];
}


/*
 * Accessors and mutators
 */

- (void)testCountLimit
{
    var cache = [[CPCache alloc] init];
    [self assert:0 equals:[cache countLimit]];
}

- (void)testSetCountLimit
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setObject:@"Object1" forKey:@"key1"];
    [cache setObject:@"Object2" forKey:@"key2"];
    [cache setObject:@"Object3" forKey:@"key3"];

    // Set count limit
    [cache setCountLimit:2];
    [self assert:nil equals:[cache objectForKey:@"key1"]];
    [self assert:@"Object2" equals:[cache objectForKey:@"key2"]];
    [self assert:@"Object3" equals:[cache objectForKey:@"key3"]];

    // Check delegate
    [self assert:1 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];

    // Check new count limit
    [self assert:2 equals:[cache countLimit]];
}

- (void)testTotalCostLimit
{
    var cache = [[CPCache alloc] init];
    [self assert:0 equals:[cache totalCostLimit]];
}

- (void)testSetTotalCostLimit
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];
    [cache setObject:@"Object1" forKey:@"key1" cost:50];
    [cache setObject:@"Object2" forKey:@"key2" cost:10];
    [cache setObject:@"Object3" forKey:@"key3" cost:70];

    // Set total cost limit
    [cache setTotalCostLimit:100];
    [self assert:nil equals:[cache objectForKey:@"key1"]];
    [self assert:@"Object2" equals:[cache objectForKey:@"key2"]];
    [self assert:@"Object3" equals:[cache objectForKey:@"key3"]];

    // Check delegate
    [self assert:1 equals:_countDelegateExecuted];
    [self assert:cache equals:[_caches objectAtIndex:0]];
    [self assert:@"Object1" equals:[_objects objectAtIndex:0]];

    // Check total cost limit
    [self assert:100 equals:[cache totalCostLimit]];
}

- (void)testDelegate
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];

    [self assert:self equals:[cache delegate]];
}

- (void)testSetDelegate
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setDelegate:self];

    [self assert:self equals:[cache delegate]];
}

/*
 * Test private methods
 */

- (void)testCount
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setObject:@"Object1" forKey:@"key1" cost:50];
    [cache setObject:@"Object2" forKey:@"key2" cost:10];
    [cache setObject:@"Object3" forKey:@"key3" cost:70];

    [self assert:3 equals:[cache _count]];
}

- (void)testTotalCost
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setObject:@"Object1" forKey:@"key1" cost:50];
    [cache setObject:@"Object2" forKey:@"key2" cost:10];
    [cache setObject:@"Object3" forKey:@"key3" cost:70];

    [self assert:130 equals:[cache _totalCost]];
}

- (void)testResequencePosition
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setObject:@"Object1" forKey:@"key1" cost:50];  // 1 - 1
    [cache setObject:@"Object2" forKey:@"key2" cost:10];
    [cache setObject:@"Object3" forKey:@"key3" cost:70];  // 3 - 2
    [cache removeObjectForKey:@"key2"]
    [cache setObject:@"Object4" forKey:@"key4" cost:70];  // 4 - 3

    // Before resequence
    [self assert:1 equals:[[[cache _items] objectForKey:@"key1"] position]];
    [self assert:3 equals:[[[cache _items] objectForKey:@"key3"] position]];
    [self assert:4 equals:[[[cache _items] objectForKey:@"key4"] position]];

    [cache _resequencePosition];

    // After resequence
    [self assert:1 equals:[[[cache _items] objectForKey:@"key1"] position]];
    [self assert:2 equals:[[[cache _items] objectForKey:@"key3"] position]];
    [self assert:3 equals:[[[cache _items] objectForKey:@"key4"] position]];
}

- (void)testCleanCacheWithoutDiscarding
{
    // Setup cache
    var cache = [[CPCache alloc] init];
    [cache setTotalCostLimit: 100]
    [cache setDelegate:self];
    [cache setObject:@"Object1" forKey:@"key1" cost:50];
    [cache setObject:@"Object2" forKey:@"key2" cost:40];

    // Set total cost limit
    [cache _cleanCache];
    [self assert:@"Object1" equals:[cache objectForKey:@"key1"]];
    [self assert:@"Object2" equals:[cache objectForKey:@"key2"]];

    // Check delegate
    [self assert:0 equals:_countDelegateExecuted];
}

- (void)testCleanCacheWithCostDiscarding
{
    // Not testable, but tested in testSetObjectForKeyDiscardByCost
}

- (void)testCleanCacheWithCountDiscarding
{
    // Not testable, but tested in testSetObjectForKeyDiscardByCount
}


@end
