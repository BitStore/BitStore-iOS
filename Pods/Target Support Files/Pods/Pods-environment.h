
// To check if a library is compiled with CocoaPods you
// can use the `COCOAPODS` macro definition which is
// defined in the xcconfigs so it is available in
// headers also when they are imported in the client
// project.


// AFNetworking
#define COCOAPODS_POD_AVAILABLE_AFNetworking
#define COCOAPODS_VERSION_MAJOR_AFNetworking 1
#define COCOAPODS_VERSION_MINOR_AFNetworking 3
#define COCOAPODS_VERSION_PATCH_AFNetworking 2

// CoreBitcoin
#define COCOAPODS_POD_AVAILABLE_CoreBitcoin
#define COCOAPODS_VERSION_MAJOR_CoreBitcoin 0
#define COCOAPODS_VERSION_MINOR_CoreBitcoin 4
#define COCOAPODS_VERSION_PATCH_CoreBitcoin 0

// DMPasscode
#define COCOAPODS_POD_AVAILABLE_DMPasscode
#define COCOAPODS_VERSION_MAJOR_DMPasscode 1
#define COCOAPODS_VERSION_MINOR_DMPasscode 0
#define COCOAPODS_VERSION_PATCH_DMPasscode 5

// FXBlurView
#define COCOAPODS_POD_AVAILABLE_FXBlurView
#define COCOAPODS_VERSION_MAJOR_FXBlurView 1
#define COCOAPODS_VERSION_MINOR_FXBlurView 6
#define COCOAPODS_VERSION_PATCH_FXBlurView 2

// MBProgressHUD
#define COCOAPODS_POD_AVAILABLE_MBProgressHUD
#define COCOAPODS_VERSION_MAJOR_MBProgressHUD 0
#define COCOAPODS_VERSION_MINOR_MBProgressHUD 9
#define COCOAPODS_VERSION_PATCH_MBProgressHUD 0

// NSDate+TimeAgo
#define COCOAPODS_POD_AVAILABLE_NSDate_TimeAgo
#define COCOAPODS_VERSION_MAJOR_NSDate_TimeAgo 1
#define COCOAPODS_VERSION_MINOR_NSDate_TimeAgo 0
#define COCOAPODS_VERSION_PATCH_NSDate_TimeAgo 3

// OpenSSL-Universal
#define COCOAPODS_POD_AVAILABLE_OpenSSL_Universal
// This library does not follow semantic-versioning,
// so we were not able to define version macros.
// Please contact the author.
// Version: 1.0.1.h.

// PiwikTracker
#define COCOAPODS_POD_AVAILABLE_PiwikTracker
#define COCOAPODS_VERSION_MAJOR_PiwikTracker 2
#define COCOAPODS_VERSION_MINOR_PiwikTracker 5
#define COCOAPODS_VERSION_PATCH_PiwikTracker 1

// SocketRocket
#define COCOAPODS_POD_AVAILABLE_SocketRocket
#define COCOAPODS_VERSION_MAJOR_SocketRocket 0
#define COCOAPODS_VERSION_MINOR_SocketRocket 3
#define COCOAPODS_VERSION_PATCH_SocketRocket 1

// iRate
#define COCOAPODS_POD_AVAILABLE_iRate
#define COCOAPODS_VERSION_MAJOR_iRate 1
#define COCOAPODS_VERSION_MINOR_iRate 10
#define COCOAPODS_VERSION_PATCH_iRate 3

// Debug build configuration
#ifdef DEBUG

  // SimulatorStatusMagic
  #define COCOAPODS_POD_AVAILABLE_SimulatorStatusMagic
  #define COCOAPODS_VERSION_MAJOR_SimulatorStatusMagic 1
  #define COCOAPODS_VERSION_MINOR_SimulatorStatusMagic 2
  #define COCOAPODS_VERSION_PATCH_SimulatorStatusMagic 0

#endif
