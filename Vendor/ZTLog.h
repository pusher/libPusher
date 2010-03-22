#ifdef DEBUG
    #define ZTLog(xx, ...) NSLog(@"%s(%d): " xx, ((strrchr(__FILE__, '/') ? : __FILE__- 1) + 1), __LINE__, ##__VA_ARGS__)
#else
    #define ZTLog(xx, ...) ((void)0)
#endif

#define ZTLogRect(r) ZTLog(@"%s x=%f, y=%f, w=%f, h=%f", #r, r.origin.x, r.origin.y, r.size.width, r.size.height)