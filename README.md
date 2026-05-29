# Owner Panel — Flutter App

A complete property owner panel for listing PG rooms, Guest Rooms, and Plots.

## Screens included
1. **Home Screen** — Dashboard with upload button & notifications
2. **Property Type Screen** — Select PG / Guest Room / Plot
3. **Property Details Screen** — Fill name, location, rooms, occupancy
4. **Verification Screen** — Menu for document uploads
5. **Document Upload Screen** — Registry & NOC upload
6. **Self Verification Screen** — Aadhaar front & back upload
7. **Success Screen** — Animated completion screen

## Setup Instructions

### Step 1 — Create Flutter project
```bash
flutter create owner_panel
cd owner_panel
```

### Step 2 — Replace files
Copy ALL files from this folder into your project, replacing what's there:
- `lib/main.dart`
- `lib/theme/app_theme.dart`
- `lib/widgets/common_widgets.dart`
- `lib/screens/home_screen.dart`
- `lib/screens/property_type_screen.dart`
- `lib/screens/property_details_screen.dart`
- `lib/screens/verification_screen.dart`
- `lib/screens/document_upload_screen.dart`
- `lib/screens/self_verification_screen.dart`
- `lib/screens/success_screen.dart`
- `pubspec.yaml`

### Step 3 — Get dependencies
```bash
flutter pub get
```

### Step 4 — Run
```bash
flutter run
```

## Adding real file picker (optional)
To enable actual file/image uploads, add to pubspec.yaml:
```yaml
dependencies:
  file_picker: ^8.0.0
  image_picker: ^1.1.2
```
Then replace the `_simulateUpload()` methods with real file picker calls.

## Color scheme
Primary: #B05A38 (warm terracotta brown)
