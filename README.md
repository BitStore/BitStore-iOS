## BitStore
BitStore is a simple and fast native iOS Bitcoin wallet.  
It offers all the features you want but still provides an easy to use interface.   
Private keys are generated on the device and stored securely in the Keychain.

http://bitstoreapp.com/

## Installation
	pod install
Open BitStore.xcworkspace.  
You will see three schemas:

- BitStore (will use the production server)
- BitStore-Test (will use the test server & color the app red)
- Tests (Unit xctest)

On the test server the stripe test servers will be used and only 0.0001 / 0.0002 / 0.0005 / 0.001 BTC will be transfered. Also the developer profile will be used for the APNs. Phone verification is skipped on the test server.

### Server
**Production** bitstoreapp.com (96.126.120.117)    
**Test** test.bitstoreapp.com (198.58.122.87)

## Code Style
### iOS
- Method braces on same line
- Tabs
- Pointer * by the type no variable name (NSString* name)
- xcode file structure should match the local file system
- use l10n for localized strings, add them manually to the strings file

## Concepts
The idea is to use listeners on most UI elements. So if the currency changes, all labels update. If the address data changes, all views are updated. With tableviews we just reload the hole table. At the moment there's no problem doing that, as we don't have huge tables.

Listeners don't have to be removed. As soon as the registered object becomes deallocated it will be removed.

**Address**

The user can own multiple addresses. A contact is also considered an address.
The address object updates itself and notifies it's listeners.

**Exchange**

To get the current BTC / CUR exchange rate or the current selected currency, the `ExchangeHelper` will provide a listener registration method.
The exchange also contains the selected unit.

**Http requests**

If you do any networking, use `RequestHelper`. Modify if it doesn't suit your needs.

**Jobs**

`JobHelper` makes it easy to add http requests that have to be performed successfully, but not immediatly. This is now used for registering to the push service or the unit change.