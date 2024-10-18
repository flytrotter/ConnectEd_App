# Connected App

Welcome to **Connected**, the app that connects educators with industry professionals for guest lectures, career panels, and more! This README will guide you through setting up the app and running it locally.

## Some Cool Features

-   **Educator and Industry Professional Modes:** Separate sign-up flows for teachers and professionals, ensuring a personalized experience for both.
-   **Profile Search & Filters:** Educators can search for and filter industry professionals based on specific categories.
-   **Save & View Profiles:** Save industry professionals to favorites and view them later.
-   **Scheduling System:** Educators can schedule sessions with industry professionals using an interactive calendar.
- **AI Generation:** Educators can generate meeting-specific lesson plans from the Gemini API 

## Prerequisites

To run the app locally, ensure you have the following tools installed:

-   **Flutter SDK:** [Installation guide](https://docs.flutter.dev/get-started/install)
-   **Firebase Account:** [Get started with Firebase](https://firebase.google.com/)

## Installation

1.  **Clone the repository:**
    
    `git clone https://github.com/your-username/connected-app.git` 
    
2.  **Navigate into the project directory:**
    
    `cd connected-app` 
    
3.  **Install dependencies:**
    
    Run the following command to install all Flutter dependencies:
    
    `flutter pub get` 
    
4.  **Firebase setup:**
    
    -   **iOS Setup:**
        
        -   Download the `GoogleService-Info.plist` file from your Firebase console and place it in the `ios/Runner` directory.
        -   Follow the Firebase iOS setup guide to configure the iOS app with Firebase.
    -   **Android Setup:**
        
        -   Download the `google-services.json` file from your Firebase console and place it in the `android/app` directory.
        -   Ensure the Firebase SDKs are integrated by following the Android setup guide.

## Running the App

1.  **Start the development server:**
    
    Ensure your device or emulator is set up, then run:

    `flutter run` 

## Contributing

1.  Fork the repository
2.  Create your feature branch (`git checkout -b feature/new-feature`)
3.  Commit your changes (`git commit -m 'Add new feature'`)
4.  Push to the branch (`git push origin feature/new-feature`)
5.  Open a pull request
