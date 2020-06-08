# shop_app

Shop App from the [Flutter & Dart - The Complete Guide](https://www.udemy.com/course/learn-flutter-dart-to-build-ios-android-apps/)  course on Udemy.

## About
This app emulates a Shopping App.
- Shows a grid of available products.
- Each product contains the following information:
  - Title
  - Price 
  - Description
  - ImageUrl
  - Favorite
- Users can:
  - Mark a product as favorite.
  - Set a filter to show only products marked as favorite
  - Add a product to the cart.
  - Place an order and see past orders.
  - Add new products.
  - Edit existing products.
  - Delete existing products

## What can you learn from this app?
- App Lifecycle
- State Managent using the provider pattern
  - How and when to use the **Provider** package
    - Using multiple providers
    - Render a piece of code instead of running the whole build method using **Consumer**
    - When to listen to changes when using a provider.
- Form Management
  - Validating user input
  - Setting initial values
  - Setting input type (keyboard) 
  - FocusNode Widget
  - TextEditingController
- HTTP Requests (This App uses Firebase as backend, but it's not using the firebase SDK)
  - POST, GET, PUT, PATCH, DELETE requests.
  - Encoding and decoding data.
  - Working with async-await methods
- Authentication
  - Sign up users with Email and password.
  - Log users in
  - Autologin
  - Autologout
  - Persist user data once they close the app.
- Animations
  - AnimationContainer
  - Animated Builder
  - Transitions
  - Hero
  - Custom page transitions
