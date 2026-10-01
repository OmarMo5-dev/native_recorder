# Native Recorder 🎙️

A small learning project built with **Flutter + Android Native
(Kotlin)**.

The goal is not to build a production recorder. The goal is to
understand how to design and implement an Android-specific feature
inside a Flutter application, including the communication between Dart
and Kotlin.

## 1. Project Goal

Native Recorder is a simple voice-recording app.

Features:

- Start recording
- Stop recording
- Save recordings locally
- List recordings
- Play a recording
- Stop playback
- Delete a recording
- Microphone permission
- Foreground Service while recording
- Native Android notification

> This is a **voice recorder**, not a phone-call recorder.

------------------------------------------------------------------------

# 2. What This Project Teaches

This project was built to practice:

- Flutter ↔ Android communication
- Kotlin Native development
- Android Activity and Service concepts
- Context and Intent
- Runtime permissions
- Foreground Services
- MediaRecorder
- MediaPlayer
- File management
- Notifications
- MethodChannel
- EventChannel
- Clean Architecture
- Separation of Responsibilities
- Native feature design

The important lesson is not memorizing the code. It is learning how to
move from a requirement to a Native architecture and then to
implementation.

------------------------------------------------------------------------

# 3. Big Picture

Flutter owns the application side:

``` text
UI
State
User Interaction
Application Flow
UseCases
Repository
```

Android Native owns Android-specific capabilities:

``` text
Microphone
Permissions
MediaRecorder
Foreground Service
Notification
Files
MediaPlayer
Android Lifecycle
```

The complete idea:

``` text
Flutter
  ↓
Flutter Architecture
  ↓
MethodChannel / EventChannel
  ↓
Kotlin Native
  ↓
Android APIs
```

------------------------------------------------------------------------

# 4. Flutter Architecture

The Flutter side follows a feature-based Clean Architecture structure:

``` text
lib/
└── features/
    └── recorder/
        ├── data/
        │   ├── datasources/
        │   │   └── native_recorder_data_source.dart
        │   ├── models/
        │   │   └── recording_model.dart
        │   └── repositories/
        │       └── recorder_repository_impl.dart
        │
        ├── domain/
        │   ├── entities/
        │   │   └── recording.dart
        │   ├── repositories/
        │   │   └── recorder_repository.dart
        │   └── usecases/
        │       ├── request_microphone_permission.dart
        │       ├── start_recording.dart
        │       ├── stop_recording.dart
        │       ├── get_recordings.dart
        │       ├── play_recording.dart
        │       ├── stop_playback.dart
        │       └── delete_recording.dart
        │
        └── presentation/
            ├── cubit/
            │   ├── recorder_cubit.dart
            │   └── recorder_state.dart
            ├── pages/
            │   └── recorder_page.dart
            └── widgets/
                ├── record_button.dart
                └── recording_item.dart
```

## Flutter responsibilities

### Presentation

Contains UI, Cubit, State, and widgets.

The UI does not know about:

- Kotlin
- MediaRecorder
- Android Service
- Context
- Intent
- MethodChannel

### Cubit

`RecorderCubit` manages UI state:

``` text
initial
requestingPermission
ready
recording
stopping
error
```

It receives user actions, calls UseCases, listens to Native events, and
updates the UI.

### UseCases

Application actions:

``` text
RequestMicrophonePermission
StartRecording
StopRecording
GetRecordings
PlayRecording
StopPlayback
DeleteRecording
```

### Repository

The domain defines:

``` text
RecorderRepository
```

The data layer implements:

``` text
RecorderRepositoryImpl
```

The Cubit depends on the repository abstraction instead of knowing the
Native implementation.

### DataSource

`NativeRecorderDataSource` is the Flutter gateway to Android.

It contains:

``` text
MethodChannel
EventChannel
```

------------------------------------------------------------------------

# 5. Entity vs Model

`Recording` is the domain entity.

It represents the application's concept of a recording:

``` text
path
name
createdAt
size
```

`RecordingModel` represents the data received from the Native/data
layer.

The idea is:

``` text
Native Data
    ↓
Model
    ↓
Domain Entity
```

------------------------------------------------------------------------

# 6. Android Native Architecture

The Native side is organized by responsibility:

``` text
android/app/src/main/kotlin/<package>/
└── recorder/
    ├── channel/
    │   ├── RecorderMethodChannel.kt
    │   └── RecorderEventChannel.kt
    │
    ├── manager/
    │   ├── RecordingManager.kt
    │   └── PlaybackManager.kt
    │
    ├── service/
    │   └── RecordingService.kt
    │
    ├── permission/
    │   └── MicrophonePermissionManager.kt
    │
    ├── file/
    │   └── RecordingFileManager.kt
    │
    └── notification/
        └── RecordingNotificationManager.kt
```

## Responsibility of each part

Component Responsibility
  ------------------------------ --------------------------------
MainActivity Flutter entry point and wiring
RecorderMethodChannel Flutter → Native commands
RecorderEventChannel Native → Flutter events
RecordingManager Recording orchestration
RecordingService Actual recording execution
MicrophonePermissionManager Permission handling
RecordingFileManager Recording files
RecordingNotificationManager Notification
PlaybackManager Audio playback

------------------------------------------------------------------------

# 7. MainActivity

`MainActivity` is intentionally thin.

It:

- Creates dependencies
- Connects the components
- Registers MethodChannel
- Registers EventChannel
- Forwards permission results

It does **not** contain:

- Recording implementation
- File management
- Playback implementation
- Notification implementation
- Service logic

The mental model is:

``` text
MainActivity
    ↓
Wiring / Registration
    ↓
Feature Classes
```

This prevents a God Class.

------------------------------------------------------------------------

# 8. MethodChannel

Channel:

``` text
native_recorder/methods
```

MethodChannel is used mainly for:

``` text
Flutter → Native
```

Commands used in the project:

``` text
requestMicrophonePermission
hasMicrophonePermission
startRecording
stopRecording
getRecordings
playRecording
stopPlayback
deleteRecording
```

Flutter calls:

``` dart
_methodChannel.invokeMethod(
  'playRecording',
  {'path': path},
);
```

Native reads:

``` kotlin
val path = call.argument<String>("path")
```

The Native side selects the operation with:

``` kotlin
when (call.method) {
    ...
}
```

Results are returned with:

``` kotlin
result.success(...)
result.error(...)
result.notImplemented()
```

### Mental model

``` text
Flutter
   ↓
MethodChannel
   ↓
Kotlin
   ↓
Native operation
   ↓
Result
   ↓
Flutter
```

------------------------------------------------------------------------

# 9. EventChannel

Channel:

``` text
native_recorder/events
```

EventChannel is used for Native events that need to reach Flutter.

Examples:

``` text
RECORDING_STARTED
RECORDING_STOPPED
RECORDING_ERROR
```

Flow:

``` text
Native
  ↓
EventChannel
  ↓
Flutter Stream
  ↓
Cubit
  ↓
UI
```

### Difference

MethodChannel:

``` text
Request / Response
```

EventChannel:

``` text
Stream of Events
```

### Important note

The current implementation stores an `EventSink`. If Native sends an
event before Flutter is listening, that event can be lost.

A future production implementation could add buffering or state
synchronization.

------------------------------------------------------------------------

# 10. Microphone Permission

There are two separate concepts.

## Manifest

The app declares:

``` xml
<uses-permission
    android:name="android.permission.RECORD_AUDIO" />
```

## Runtime Permission

Android may require asking the user at runtime.

Flow:

``` text
Manifest
   ↓
Check Permission
   ↓
Request Permission
   ↓
Android Dialog
   ↓
Granted / Denied
   ↓
Callback
   ↓
Flutter
```

`MicrophonePermissionManager` handles this process.

The `pendingResult` callback exists because the permission request is
asynchronous.

------------------------------------------------------------------------

# 11. RecordingManager

`RecordingManager` is an orchestration layer.

It:

1. Checks microphone permission.
2. Creates an explicit Intent.
3. Sends an action to `RecordingService`.
4. Starts or stops the Service.

It does **not** directly use `MediaRecorder`.

Flow:

``` text
Flutter
 ↓
RecordingManager
 ↓
Intent
 ↓
RecordingService
```

This separation keeps the Service responsible for execution and the
Manager responsible for orchestration.

------------------------------------------------------------------------

# 12. RecordingService

`RecordingService` is responsible for the actual recording operation.

Important lifecycle methods:

``` text
onCreate()
onStartCommand()
onDestroy()
onBind()
```

### onCreate()

Initializes dependencies.

It does not mean recording has started.

### onStartCommand()

Receives the Intent and checks its action:

``` text
ACTION_START → startRecording()
ACTION_STOP  → stopRecording()
```

### onDestroy()

Cleans up Native resources.

### onBind()

The Service is not a bound service:

``` kotlin
override fun onBind(
    intent: Intent?
): IBinder? = null
```

------------------------------------------------------------------------

# 13. MediaRecorder

`MediaRecorder` performs the actual audio recording.

Configuration order:

``` text
setAudioSource()
      ↓
setOutputFormat()
      ↓
setAudioEncoder()
      ↓
setOutputFile()
      ↓
prepare()
      ↓
start()
```

This project uses:

``` text
Audio Source → Microphone
Output Format → MPEG-4
Encoder → AAC
File → .m4a
```

When stopping:

``` text
stop()
 ↓
release()
```

`release()` is important because Native APIs can hold system resources.

------------------------------------------------------------------------

# 14. Why MediaRecorder Is Nullable

The project uses:

``` kotlin
private var mediaRecorder: MediaRecorder? = null
```

The `?` means it can be:

``` text
MediaRecorder
```

or:

``` text
null
```

Before recording:

``` text
null
```

During recording:

``` text
MediaRecorder instance
```

After cleanup:

``` text
null
```

This:

``` kotlin
mediaRecorder?.release()
```

means:

> If the object exists, release it.

------------------------------------------------------------------------

# 15. Foreground Service

Recording is a long-running operation.

The project uses a Foreground Service while recording.

The Service calls:

``` kotlin
startForeground(...)
```

and displays a notification.

The Service is declared with:

``` xml
android:foregroundServiceType="microphone"
```

The important concept:

> A Foreground Service is not a magic way to bypass Android background
> restrictions. It is an Android mechanism for user-visible ongoing work
> and is still subject to Android's rules.

------------------------------------------------------------------------

# 16. RecordingFileManager

Recordings are stored under:

``` text
context.filesDir/recordings/
```

Files use a name similar to:

``` text
recording_1712345678901.m4a
```

`RecordingFileManager` handles:

``` text
Create file
List files
Sort files
Delete file
```

The Service does not need to know how the directory is organized.

------------------------------------------------------------------------

# 17. RecordingNotificationManager

Responsible for:

``` text
NotificationChannel
Notification
NotificationManager
```

The notification is shown while recording as part of the Foreground
Service design.

------------------------------------------------------------------------

# 18. PlaybackManager

Playback is separated from recording.

It uses:

``` text
MediaPlayer
```

Flow:

``` text
Flutter
 ↓
MethodChannel
 ↓
PlaybackManager
 ↓
MediaPlayer
 ↓
Audio File
```

It handles:

- `setDataSource`
- `prepare`
- `start`
- `stop`
- `release`
- completion cleanup

------------------------------------------------------------------------

# 19. Android Manifest

The project declares:

``` xml
<uses-permission
    android:name="android.permission.RECORD_AUDIO" />

<uses-permission
    android:name="android.permission.FOREGROUND_SERVICE" />

<uses-permission
    android:name="android.permission.FOREGROUND_SERVICE_MICROPHONE" />

<uses-permission
    android:name="android.permission.POST_NOTIFICATIONS" />
```

And declares the Service:

``` xml
<service
    android:name=".recorder.service.RecordingService"
    android:exported="false"
    android:foregroundServiceType="microphone" />
```

Remember:

``` text
Manifest declaration
≠
Runtime permission granted
```

------------------------------------------------------------------------

# 20. Flutter ↔ Native Complete Flow

## Start Recording

``` text
User
 ↓
Flutter UI
 ↓
RecorderCubit
 ↓
StartRecording UseCase
 ↓
RecorderRepository
 ↓
NativeRecorderDataSource
 ↓
MethodChannel
 ↓
RecorderMethodChannel
 ↓
RecordingManager
 ↓
Intent
 ↓
RecordingService
 ↓
Foreground Service
 ↓
MediaRecorder
 ↓
Audio File
```

Native then sends:

``` text
RECORDING_STARTED
```

back through:

``` text
RecordingService
 ↓
RecorderEventChannel
 ↓
EventChannel
 ↓
NativeRecorderDataSource
 ↓
Repository
 ↓
Cubit
 ↓
UI
```

## Stop Recording

``` text
Flutter UI
 ↓
Cubit
 ↓
StopRecording UseCase
 ↓
Repository
 ↓
DataSource
 ↓
MethodChannel
 ↓
RecordingManager
 ↓
RecordingService
 ↓
MediaRecorder.stop()
 ↓
MediaRecorder.release()
 ↓
RECORDING_STOPPED
 ↓
EventChannel
 ↓
Cubit
 ↓
Reload recordings
 ↓
UI
```

------------------------------------------------------------------------

# 21. Error Flow

Native operations can fail.

Examples:

``` text
prepare()
start()
stop()
file operations
```

The Native layer catches failures and can send:

``` text
RECORDING_ERROR
```

Then:

``` text
Native
 ↓
EventChannel
 ↓
Flutter
 ↓
Cubit
 ↓
Error State
 ↓
UI
```

The important idea is that Native errors become application state
instead of uncontrolled failures.

------------------------------------------------------------------------

# 22. Why We Separate Classes

A bad design could put everything inside `MainActivity`:

``` text
MainActivity
 ├── Permission
 ├── MediaRecorder
 ├── File handling
 ├── Notification
 ├── Playback
 ├── Service
 └── MethodChannel
```

That becomes a God Class.

The project instead uses:

``` text
Channel
   ↓
Manager
   ↓
Service
   ↓
Android API
```

with separate helpers for:

``` text
Permission
Files
Notifications
Playback
```

Each class has a clearer responsibility.

------------------------------------------------------------------------

# 23. Native Development Mental Model

This is the most important lesson of the project.

Do not start by writing Kotlin.

Start with the requirement.

Example:

``` text
Requirement:
Record audio
```

Ask:

``` text
What Android capability is needed?
        ↓
Microphone
        ↓
Which Android API?
        ↓
MediaRecorder
        ↓
Does it need background execution?
        ↓
Foreground Service
        ↓
What permissions are required?
        ↓
Microphone / Foreground Service related permissions
        ↓
How does Flutter communicate with Native?
        ↓
MethodChannel + EventChannel
        ↓
How should Native responsibilities be separated?
        ↓
Manager + Service + File + Notification
```

Then write the code.

------------------------------------------------------------------------

# 24. General Native Feature Design Formula

Keep this formula as a reference:

``` text
Requirement
     ↓
Platform Capability
     ↓
Android API
     ↓
Native Component
     ↓
Communication Contract
     ↓
Flutter Integration
```

For this project:

``` text
Voice Recording
     ↓
Microphone
     ↓
MediaRecorder
     ↓
RecordingService
     ↓
MethodChannel + EventChannel
     ↓
Flutter DataSource / Repository / Cubit
```

This same way of thinking can later be used for:

``` text
Audio
Camera
Bluetooth
Sensors
Notifications
Background Work
Platform Services
```

------------------------------------------------------------------------

# 25. When Should I Use Native?

Not every feature needs Kotlin.

Flutter normally handles:

- UI
- Navigation
- State
- Application flow
- Most application logic

Native becomes useful when the requirement depends heavily on:

- Android APIs
- Android lifecycle
- System services
- Special permissions
- Hardware capabilities
- Background/foreground execution
- Platform-specific functionality

The decision should start from the **requirement**, not from the desire
to use Native code.

------------------------------------------------------------------------

# 26. Kotlin Concepts Practiced

The project uses:

``` text
class
constructor
private
val
var
lateinit
nullable types
?
?.
!!
if
when
try/catch
lambda
callback
object
companion object
const val
override
inheritance
```

Example:

``` kotlin
private var mediaRecorder: MediaRecorder? = null
```

Read it as:

``` text
private
→ only this class should access it

var
→ value can change

mediaRecorder
→ variable name

MediaRecorder?
→ value may be MediaRecorder or null
```

And:

``` kotlin
mediaRecorder?.release()
```

means:

``` text
If mediaRecorder exists:
    release it
```

------------------------------------------------------------------------

# 27. Android Concepts Practiced

The project gives practical experience with:

``` text
Activity
Service
Intent
Context
Manifest
Runtime Permission
Foreground Service
Notification
MediaRecorder
MediaPlayer
Lifecycle
```

The purpose is to understand how these pieces work together rather than
study them as isolated definitions.

------------------------------------------------------------------------

# 28. Resource Cleanup

Native APIs often own resources that need explicit cleanup.

Examples:

``` kotlin
recorder.stop()
recorder.release()
```

``` kotlin
mediaPlayer.release()
```

``` kotlin
stopForeground(...)
stopSelf()
```

The general Native resource lifecycle is:

``` text
Acquire
  ↓
Use
  ↓
Stop
  ↓
Release
  ↓
Clear Reference
```

This is an important difference when moving from normal Dart application
code into Native platform code.

------------------------------------------------------------------------

# 29. Current Project Notes / Limitations

This is a learning project, not a production recorder.

Known areas for future improvement:

### Event buffering

An EventChannel event can be missed if Flutter is not listening at the
moment Native sends it.

### Playback completion state

The current `PlaybackManager` handles MediaPlayer completion internally,
but there is no dedicated playback-completed event sent back to Flutter.

### Notification permission

`POST_NOTIFICATIONS` is declared, but a complete runtime notification
permission flow can be added when required by the target Android version
and desired behavior.

### Production hardening

A production application would need more handling for:

- Audio focus
- Interruptions
- Microphone conflicts
- Service/process edge cases
- Android version differences
- Lifecycle edge cases
- Invalid/corrupted recordings
- Stronger state synchronization

These were outside the core scope of this learning project.

------------------------------------------------------------------------

# 30. Final Architecture Diagram

``` text
                         FLUTTER
                            │
                            ▼
                     ┌─────────────┐
                     │     UI      │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │    Cubit    │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │   UseCase   │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ Repository  │
                     └──────┬──────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ DataSource  │
                     └──────┬──────┘
                            │
                     MethodChannel
                            │
                            ▼
                         KOTLIN
                            │
                  ┌─────────┼─────────┐
                  ▼         ▼         ▼
               Manager   Service   FileManager
                            │
                            ▼
                      MediaRecorder
                            │
                            ▼
                        Audio File
```

Events return:

``` text
Android
   ↓
EventChannel
   ↓
DataSource
   ↓
Repository
   ↓
Cubit
   ↓
UI
```

------------------------------------------------------------------------

# 31. Quick Revision Checklist

-   [ ] I understand why Native was needed.
-   [ ] I understand Flutter responsibilities.
-   [ ] I understand Native responsibilities.
-   [ ] I understand the Flutter folder structure.
-   [ ] I understand the Native folder structure.
-   [ ] I understand MainActivity's role.
-   [ ] I understand MethodChannel.
-   [ ] I understand EventChannel.
-   [ ] I understand Runtime Permissions.
-   [ ] I understand Context.
-   [ ] I understand Intent.
-   [ ] I understand Service.
-   [ ] I understand Foreground Service.
-   [ ] I understand MediaRecorder.
-   [ ] I understand MediaPlayer.
-   [ ] I understand FileManager.
-   [ ] I understand NotificationManager.
-   [ ] I understand callbacks.
-   [ ] I understand Kotlin nullable types.
-   [ ] I understand `lateinit`.
-   [ ] I understand `companion object`.
-   [ ] I understand `try/catch`.
-   [ ] I understand Native resource cleanup.
-   [ ] I understand Flutter → Native communication.
-   [ ] I understand Native → Flutter events.
-   [ ] I can separate responsibilities between classes.
-   [ ] I can design a Native feature before writing Kotlin.

------------------------------------------------------------------------

# 32. Final Lesson

Do not memorize:

``` text
RecordingService.kt
MethodChannel
MediaRecorder
```

Remember the thinking process:

``` text
What is the requirement?
        ↓
What belongs to Flutter?
        ↓
What requires Android?
        ↓
Which Android API provides it?
        ↓
Which Android component is needed?
        ↓
What permissions are required?
        ↓
Does it need background/foreground execution?
        ↓
What commands go from Flutter to Native?
        ↓
What events come from Native to Flutter?
        ↓
How should responsibilities be separated?
        ↓
Then write the code.
```

The code changes from project to project.

The engineering thinking is what remains.
