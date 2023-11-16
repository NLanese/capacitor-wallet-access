# ==== GOAL OF THIS PLUGIN ==== #
This plugin aims to give Front End Developers who are working with a nodeJS package using Capacitor the ability
to acces a user's wallet. This will allow a few different things...
1. We can use this plugin to see whether or not a pass already exists on a user's device

# ==== TO BUILD LOCALLY ==== #
1. run `npm run build`
2. run `npm link`

# ==== REQs ==== #
1. This plugin will be useless on Web Applications since it is not optimized for Macs

# ==== GENERAL SET UP ==== #
1. Switch to the ios directory and run 
   `pod install`.
    If this command fails,enter this following command in your Computer User's root directory 
   `gem install ffi -v '1.15.0'`

# ==== SET UP FOR CAPACITOR v3.9.0 ==== #
1. Change all Capacitor Dependency versions in the package.json to `3.9.0`
2. In the root directory, run 
   `npm i @type/yarg@17.0.8`
3. Switch to the ios directory and run 
   `pod install`. If this command fails,
   enter this following command in your Computer User's root directory 
   `gem install ffi -v '1.15.0'`

# ==== INSTALLATION AND USAGE ==== #
1. You can download this package and npm install 
   `..path/from/project/to/this/plugin`

2. Add the plugin to your capacitor.config.json file through the following syntax....
  "plugins": {
    ...
    "capacitor-wallet-access": {
      "path": "../path/to/capacitor-wallet-access"
    }

2a. On iOS, you will also have to add this Capacitor Plugin to your Podfile like so....
    `pod 'CapacitorWalletAccess', :path => '../../node_modules/capacitor-wallet-access'`

3. Run `npx cap sync` in the root directory of your

2. To import the Plugin on your Capacitor JS Frontend Framework; do the following...
   `import WalletAccessPlugin from "..path/to/node_modules/capacitor-wallet-access`

3. To use the getWallet function, first import (shown above) and then...
   `const wallet = WalletAccessPlugin.getWallet()`

