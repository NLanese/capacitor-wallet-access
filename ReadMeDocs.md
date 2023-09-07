==== SET UP ====
1. In the root directory, run `npm i @type/yarg@17.0.8`
2. Switch to the ios directory and run `pod install`. If this command fails,
   enter this following command in your Computer User's root directory `gem install ffi -v '1.15.0'`


For cap 3.9.0, you have to downgrade @types/yarg to 17.0.8 by manually inputting `npm i @type/yarg@17.0.8`
Otherwise, you will get 827 errors related to typeScript declarations during npm run build