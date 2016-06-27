//
//  ABCCategories.m
//  Airbitz
//

#import "ABCCategories+Internal.h"
#import "AirbitzCore+Internal.h"

@interface ABCCategories ()
{
    ABCAccount          *_account;
    NSArray             *_categoryList;
    BOOL                _categoriesUpdated;
}

@end

@implementation ABCCategories

- (id) initWithAccount:(ABCAccount *)account;
{
    _account = account;
    return self;
}

- (NSArray *)listCategories
{
    if (_categoryList && !_categoriesUpdated)
        return _categoryList;

    _categoriesUpdated = NO;
    char            **aszCategories = NULL;
    unsigned int    countCategories = 0;
    NSMutableArray *mutableArrayCategories = [[NSMutableArray alloc] init];
    
    // get the categories from the core
    tABC_Error error;
    ABC_GetCategories([_account.name UTF8String],
                      [_account.password UTF8String],
                      &aszCategories,
                      &countCategories,
                      &error);
    
    {
        // store them in our own array
        
        if (aszCategories && countCategories > 0)
        {
            for (int i = 0; i < countCategories; i++)
            {
                [mutableArrayCategories addObject:[NSString stringWithUTF8String:aszCategories[i]]];
            }
        }
        
    }
    
    // free the core categories
    if (aszCategories != NULL)
    {
        [ABCUtil freeStringArray:aszCategories count:countCategories];
    }
    
    NSArray *tempArray = [mutableArrayCategories sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    // store the final as storted
    _categoryList = tempArray;
    
    return _categoryList;
}

- (NSError *)addCategory:(NSString *)category;
{
    NSError *nserror = nil;
    // check and see that it doesn't already exist
    if ([_categoryList indexOfObject:category] == NSNotFound)
    {
        // add the category to the core
        tABC_Error error;
        ABC_AddCategory([_account.name UTF8String],
                        [_account.password UTF8String],
                        (char *)[category UTF8String], &error);
        nserror = [ABCError makeNSError:error];
        _categoriesUpdated = YES;
    }
    return nserror;
}

- (NSError *)removeCategory:(NSString *)category;
{
    tABC_Error error;
    NSError *nserror = nil;
    ABC_RemoveCategory([_account.name UTF8String],
                       [_account.password UTF8String],
                       (char *)[category UTF8String], &error);
    nserror = [ABCError makeNSError:error];
    _categoriesUpdated = YES;
    return nserror;
}

// saves the categories to the core
- (NSError *)saveCategories:(NSArray *)arrayCategories;
{
    NSError *nserror = nil;
    NSError *nserrorRet = nil;
    NSMutableArray *saveArrayCategories = [NSMutableArray arrayWithArray:arrayCategories];
    
    // got through the existing categories
    for (NSString *strCategory in _categoryList)
    {
        // if this category is in our new list
        if ([saveArrayCategories containsObject:strCategory])
        {
            // remove it from our new list since it is already there
            [saveArrayCategories removeObject:strCategory];
        }
        else
        {
            // it doesn't exist in our new list so delete it from the core
            nserror = [self removeCategory:strCategory];
            if (nserror) nserrorRet = nserror;
        }
    }
    
    // add any categories from our new list that didn't exist in the core list
    for (NSString *strCategory in saveArrayCategories)
    {
        nserror = [self addCategory:strCategory];
        if (nserror) nserrorRet = nserror;
    }
    
    return nserrorRet;
}



@end