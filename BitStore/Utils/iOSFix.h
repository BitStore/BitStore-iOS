//
//  iOS8Fix.h
//  BitStore
//
//  Created by Dylan Marriott on 07.07.14.
//  Copyright (c) 2014 Dylan Marriott. All rights reserved.
//

#ifndef __ENABLE_COMPATIBILITY_WITH_UNIX_2003__
#define __ENABLE_COMPATIBILITY_WITH_UNIX_2003__
#include <stdio.h>
FILE *fopen$UNIX2003( const char *filename, const char *mode )
{
    return fopen(filename, mode);
}
size_t fwrite$UNIX2003( const void *a, size_t b, size_t c, FILE *d )
{
    return fwrite(a, b, c, d);
}
char *strerror$UNIX2003( int errnum )
{
    return strerror(errnum);
}
#endif