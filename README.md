# WorkoutApp Flutter client

Flutter application for the WorkoutApp backend. In the local workspace, the
backend repository is at `../../WorkoutApp/`. The client communicates with its
gateway over HTTP and WebSocket; it does not import backend source files.

## Run locally

```sh
flutter pub get
flutter run
```

For the iOS simulator with the backend running on this Mac, use the loopback
address instead of a LAN IP that can change:

```sh
flutter run -d "iPhone 17" --dart-define=LOCAL_API_BASE_URL=http://127.0.0.1:8000
```

The client reads `assets/env/app.env` for local configuration. Release builds
can override the API endpoint with a build-time value:

```sh
flutter build apk --release --dart-define=PROD_API_BASE_URL=https://api.example.com
```

Set `CHAT_WS_URL` with another `--dart-define` when the agent WebSocket service
is available.
