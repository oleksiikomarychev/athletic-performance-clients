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

## Deploy Flutter Web with Coolify

The workflow in `.github/workflows/publish-web.yml` builds Flutter Web, pushes
`oleksiikomarychev/workoutapp-web:latest` and a commit-specific image to Docker
Hub, then calls the Coolify deploy webhook. Nginx serves the Flutter app on
port `80`. The browser calls the public HTTPS API directly; configure CORS on
the API gateway for the web application's domain.

Configure the following in this repository under **Settings → Secrets and
variables → Actions**:

| Type | Name | Value |
| --- | --- | --- |
| Variable | `PROD_API_BASE_URL` | Public HTTPS API origin, without `/api/v1` or a trailing slash |
| Variable | `CHAT_WS_URL` | Public `wss://` agent origin, if chat is available |
| Secret | `DOCKERHUB_USERNAME` | Docker Hub username |
| Secret | `DOCKERHUB_TOKEN` | Docker Hub access token with push access |
| Secret | `COOLIFY_WEBHOOK` | Deploy webhook URL from the Coolify web application |
| Secret | `COOLIFY_TOKEN` | Coolify API token with Deploy permission |

In Coolify, create a **Docker Image** application using
`oleksiikomarychev/workoutapp-web:latest`, set the internal port to `80`, and
assign the public HTTPS domain. Disable Git push auto-deploy for this app: the
workflow triggers deployment only after the new image is published. The
Docker Hub image must be public or the Coolify server must be authenticated
to Docker Hub.

The web build embeds the API and chat URLs at build time. Changing a GitHub
variable requires a new workflow run. The local `assets/env/app.env` contains
older URLs; the workflow's `--dart-define` value overrides the API URL.
