# 🐾 Whisker World — Young Pet Discovery & Adoption Platform

> **"Every Paw Deserves a Loving Home."**

**Whisker World** is a production-quality, responsive Flutter Web application designed to connect prospective adopters with young animals (puppies, kittens, kits, foals, and more) from verified shelters, breeders, and pet stores. Built entirely on top of **SQLite** (via WebAssembly in browser environments and native FFI on desktop/tests), the application features atomic adoption lifecycles, rigorous role-based routing, store-specific listing isolation, and a modern Material 3 design system with persistent dark mode.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Key Features](#2-key-features)
3. [Technology Stack](#3-technology-stack)
4. [Flutter & Dart Version](#4-flutter--dart-version)
5. [SQLite Implementation](#5-sqlite-implementation)
6. [Database Schema](#6-database-schema)
7. [Database Migrations](#7-database-migrations)
8. [Architecture & Design Patterns](#8-architecture--design-patterns)
9. [Setup & Installation](#9-setup--installation)
10. [Running Locally](#10-running-locally)
11. [Building for Production Web](#11-building-for-production-web)
12. [Demo Accounts](#12-demo-accounts)
13. [Testing & Quality Assurance](#13-testing--quality-assurance)
14. [Acceptance Flows](#14-acceptance-flows)
15. [Known Limitations](#15-known-limitations)

---

## 1. Project Overview

Whisker World solves the challenge of finding and adopting young companion animals ethically. The platform empowers two distinct user personas:
- **Pet Owners & Store Caregivers**: Manage young pet listings, associate pets with verified stores, evaluate incoming adoption questionnaires, approve/reject inquiries, and finalize adoptions.
- **Pet Adopters**: Discover young pets by species, breed, location, or age; bookmark favorite companions; and submit detailed adoption applications.

---

## 2. Key Features

- **Young Pet Management**: Comprehensive animal models capturing species, breed, age (days, weeks, months), life stages (`newborn`, `baby`, `young`, `adolescent`, `adult`, `senior`), young animal terminology (Dog → Puppy, Cat → Kitten, Rabbit → Kit, Horse → Foal, etc.), vaccination, deworming, and veterinary health records.
- **Store-Specific Pet Listings (Strict Isolation)**: Pet Stores maintain individual profiles with cover photos, logos, opening hours, and contact details. When a user opens a store, **only pets belonging to that specific store** are queried and displayed using parameterized SQL:
  ```sql
  SELECT * FROM pets WHERE store_id = ? AND availability_status = 'available';
  ```
- **End-to-End Adoption Lifecycle**:
  - `pending`: Adopter submits application with detailed questionnaire.
  - `approved`: Pet Owner approves; pet availability transitions atomically to `pending` (Pending Adoption).
  - `rejected` / `cancelled`: Owner rejects or Adopter cancels; pet availability is immediately restored to `available`.
  - `completed`: Finalizes adoption; pet status becomes `adopted`, and any other pending applications for that pet are automatically marked as `rejected`.
- **Favorites System**: SQLite-backed user favorites with `UNIQUE(user_id, pet_id)` constraints to prevent duplicates.
- **Search, Filters & Sorting**: Real-time multi-criteria filtering across animal type, breed, location, age, life stage, gender, store, fee range, and dynamic sorting (Newest, Oldest, Youngest, Price Low to High, Price High to Low).
- **Design System & Dark Mode**: Material 3 warm cream (`#FAF7F2`), soft coral (`#FF6B4A`), and natural sage (`#4A7C59`) color palette with persistent dark mode preference saved in `SharedPreferences`.
- **Role-Based Routing & Security**: Route guards prevent unauthenticated users or owners from accessing adopter-only screens and vice versa. Passwords use salted HMAC-SHA256 hashing.

---

## 3. Technology Stack

- **Framework**: [Flutter Web](https://flutter.dev) (Channel stable, WebAssembly enabled)
- **Language**: [Dart 3.5+](https://dart.dev)
- **Database**:
  - Web: `sqflite_common_ffi_web` (SQLite compiled to WebAssembly via SQLite3 WASM)
  - VM / Unit Tests / Desktop: `sqflite_common_ffi` with `sqlite3`
- **State Management**: `provider` (MultiProvider with clean separation of concerns)
- **Routing**: `go_router` (declarative routing with role-based `redirect` guards)
- **Persistence**: `shared_preferences` (session authentication tokens and theme modes)
- **Typography**: `google_fonts` (Plus Jakarta Sans)
- **Security & Cryptography**: `crypto` (HMAC-SHA256 with 16-byte cryptographically secure random salt)

---

## 4. Flutter & Dart Version

- **Flutter SDK**: `>= 3.24.0`
- **Dart SDK**: `>= 3.5.0 < 4.0.0`
- Web Renderer: Auto-detected (CanvasKit / HTML) with tree-shaken icons and WASM dry run support.

---

## 5. SQLite Implementation

Whisker World avoids in-memory mock arrays in favor of a relational SQLite database across all execution environments:
- **Web**: Initialized with `databaseFactoryFfiWeb` backed by IndexedDB and WebAssembly.
- **Desktop / VM Tests**: Initialized with `sqfliteFfiInit()` and `databaseFactoryFfi`.
- **Foreign Keys**: Enforced on every connection lifecycle:
  ```dart
  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }
  ```
- **Parameterized SQL**: All database operations use bind parameters (`?`) to prevent SQL injection vulnerabilities.

---

## 6. Database Schema

The database consists of 6 tables with relational integrity:

```
┌─────────────┐       ┌──────────────┐       ┌─────────────┐
│    users    │◄──────┤  pet_stores  │◄──────┤    pets     │
└─────────────┘       └──────────────┘       └─────────────┘
       ▲                                            ▲
       │                                            │
       ├────────────────────────────────────────────┤
       │                                            │
┌──────────────┐                             ┌─────────────┐
│  favorites   │                             │ pet_images  │
└──────────────┘                             └─────────────┘
       ▲                                            ▲
       │                                            │
┌───────────────────────────────────────────────────┴───────┐
│                     adoption_requests                     │
└───────────────────────────────────────────────────────────┘
```

### Table Definitions

1. **`users`**:
   `id` (TEXT PRIMARY KEY), `name` (TEXT), `email` (TEXT UNIQUE), `password_hash` (TEXT), `phone` (TEXT), `role` (TEXT: `petOwner` | `petAdopter`), `location` (TEXT), `bio` (TEXT), `profile_image` (TEXT), `created_at` (TEXT), `updated_at` (TEXT).
2. **`pet_stores`**:
   `id` (TEXT PRIMARY KEY), `owner_id` (TEXT, FK -> `users.id`), `name` (TEXT), `description` (TEXT), `address` (TEXT), `city` (TEXT), `state` (TEXT), `country` (TEXT), `phone` (TEXT), `email` (TEXT), `website` (TEXT), `logo_url` (TEXT), `cover_image_url` (TEXT), `opening_hours` (TEXT), `is_active` (INTEGER), `created_at` (TEXT), `updated_at` (TEXT).
3. **`pets`**:
   `id` (TEXT PRIMARY KEY), `owner_id` (TEXT, FK -> `users.id`), `store_id` (TEXT NULL, FK -> `pet_stores.id`), `name` (TEXT), `animal_type` (TEXT), `breed` (TEXT), `age_value` (INTEGER), `age_unit` (TEXT), `life_stage` (TEXT), `young_animal_name` (TEXT), `gender` (TEXT), `description` (TEXT), `personality` (TEXT), `color` (TEXT), `size` (TEXT), `weight` (REAL), `health_information` (TEXT), `vaccination_status` (TEXT), `deworming_status` (TEXT), `veterinary_check` (TEXT), `is_neutered` (INTEGER), `adoption_fee` (REAL), `location` (TEXT), `availability_status` (TEXT), `created_at` (TEXT), `updated_at` (TEXT).
4. **`pet_images`**:
   `id` (TEXT PRIMARY KEY), `pet_id` (TEXT, FK -> `pets.id` ON DELETE CASCADE), `image_url` (TEXT), `is_primary` (INTEGER), `created_at` (TEXT).
5. **`adoption_requests`**:
   `id` (TEXT PRIMARY KEY), `pet_id` (TEXT, FK -> `pets.id`), `adopter_id` (TEXT, FK -> `users.id`), `owner_id` (TEXT, FK -> `users.id`), `store_id` (TEXT NULL, FK -> `pet_stores.id`), `status` (TEXT: `pending` | `approved` | `rejected` | `cancelled` | `completed`), `message` (TEXT), `reason_for_adoption` (TEXT), `pet_experience` (TEXT), `living_environment` (TEXT), `other_pets` (TEXT), `contact_preference` (TEXT), `created_at` (TEXT), `updated_at` (TEXT).
6. **`favorites`**:
   `id` (TEXT PRIMARY KEY), `user_id` (TEXT, FK -> `users.id`), `pet_id` (TEXT, FK -> `pets.id`), `created_at` (TEXT), `UNIQUE(user_id, pet_id)`.

---

## 7. Database Migrations

Whisker World manages schema versions through an incremental migration registry:
- **Schema V1**: Core tables (`users`, `pet_stores`, `pets`, `pet_images`, `adoption_requests`, `favorites`).
- **Schema V2**: Added indexes for pet discovery and filtering performance.
- **Schema V3**: Added store metadata columns (`website`, `opening_hours`, `city`, `state`, `country`, `is_active`).
- **Schema V4**: Added young pet metadata (`young_animal_name`, `age_unit`, `veterinary_check`).
- **Schema V5**: Added adoption questionnaire columns (`reason_for_adoption`, `pet_experience`, `living_environment`, `other_pets`, `contact_preference`) and status indexes.

Current database version: `DatabaseHelper.currentVersion = 5`.

---

## 8. Architecture & Design Patterns

```
lib/
├── app/
│   ├── app.dart                    # MultiProvider root & MaterialApp setup
│   ├── routes.dart                 # Declarative GoRouter with RoleGuards
│   └── theme.dart                  # Material 3 Light/Dark design system tokens
├── database/
│   ├── database_helper.dart        # SQLite schema versioning & migration runner
│   ├── database_seeder.dart        # Seeds demo accounts & initial companion pets
│   ├── database_service.dart       # SQLite WASM & FFI connection manager
│   └── migrations/                 # SchemaV1 through SchemaV5 definitions
├── models/                         # Domain models with toMap / fromMap serialization
├── providers/                      # Reactive ChangeNotifier state providers
├── repositories/                   # Parameterized SQLite data repositories
├── services/                       # Authentication, hashing, and image fallbacks
├── utils/                          # AnimalUtils terminology & PasswordHasher
├── widgets/                        # Reusable component library
└── screens/                        # Public discovery & role-guarded dashboards
```

---

## 9. Setup & Installation

### Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.24.0`)
- Google Chrome (for running web version)

### Clone & Install
```bash
git clone https://github.com/your-username/whisker_world.git
cd whisker_world
flutter pub get
```

---

## 10. Running Locally

To launch the web application with live SQLite support:
```bash
flutter run -d chrome --web-port=8080
```
Open `http://localhost:8080` in Google Chrome.

---

## 11. Building for Production Web

To build an optimized, tree-shaken Web production bundle:
```bash
flutter build web
```
The compiled static assets will be output to `build/web/`, ready for hosting on Firebase Hosting, GitHub Pages, Vercel, or AWS S3.

---

## 12. Demo Accounts

The application automatically seeds pre-configured demo credentials on first startup:

| Role | Email | Password | Pre-seeded Store & Pets |
| :--- | :--- | :--- | :--- |
| **Pet Owner** | `owner@example.com` | `Owner@123` | **Whisker Haven** (Bruno, Luna, Milo) |
| **Pet Adopter** | `adopter@example.com` | `Adopter@123` | Active adopter account ready to favorite & apply |

> [!TIP]
> The **Login Screen** (`/login`) includes 1-click **"Fill Demo Owner"** and **"Fill Demo Adopter"** buttons for immediate testing.

---

## 13. Testing & Quality Assurance

Whisker World has an extensive suite of **91 automated tests** covering authentication, roles, security, database constraints, store pet isolation, adoption workflows, young-pet terminology, and responsive UI components.

### Run All Tests
```bash
flutter test
```

### Run Static Analysis
```bash
flutter analyze
```

### Test Suites Included
- `test/phase8_final_verification_test.dart` (22 end-to-end acceptance & security tests)
- `test/auth/auth_service_test.dart` (Authentication & session persistence)
- `test/auth/password_hasher_test.dart` (HMAC-SHA256 salted password hashing)
- `test/auth/role_guard_test.dart` (GoRouter role-based redirect guards)
- `test/pet_stores_test.dart` (Store CRUD & store-specific pet isolation)
- `test/adoption_workflow_test.dart` (Atomic SQLite transactions & questionnaire)
- `test/pet_discovery_test.dart` (Search queries, multi-filter SQL, PetCard)
- `test/phase7_ui_test.dart` (Material 3 tokens, theme toggle, and design components)
- `test/animal_utils_test.dart` (Species terminology & age formatting)
- `test/database_test.dart` (SQLite schema, indexes, and CRUD)

---

## 14. Acceptance Flows

### 1. Adoption Acceptance Flow
1. Open Whisker World (`/`) → Explore the Homepage.
2. Click **Find Pets** (`/pets`) → Select a young pet (e.g. **Bruno**, Golden Retriever Puppy).
3. View **Pet Details** (`/pets/pet-bruno`).
4. Click **Apply to Adopt** → Login as Adopter (`adopter@example.com` / `Adopter@123`).
5. Submit the questionnaire → Request status is set to **`PENDING`**.
6. Logout and login as Owner (`owner@example.com` / `Owner@123`).
7. Open **Owner Requests** (`/owner/requests`) → View Bruno's application.
8. Click **Approve** → Request status becomes **`APPROVED`**, and Bruno's availability status updates atomically to **`PENDING ADOPTION`**.

### 2. Store Pet Isolation Flow (Whisker Haven vs Happy Paws)
1. Open **Pet Stores** (`/stores`).
2. Click **Whisker Haven** (`/stores/store-whisker-haven`).
   - Displays **ONLY** pets assigned to Whisker Haven: **Bruno**, **Luna**, and **Milo**.
   - Does **NOT** display Simba, Coco, or Rocky.
3. Return to **Pet Stores** and click **Happy Paws** (`/stores/store-happy-paws`).
   - Displays **ONLY** pets assigned to Happy Paws: **Simba**, **Coco**, and **Rocky**.
   - Does **NOT** display Bruno, Luna, or Milo.

---

## 15. Known Limitations

1. **Web Persistent Storage**: On Flutter Web, SQLite operates via WebAssembly backed by IndexedDB. Clearing browser site data or running in Private/Incognito mode resets local database state.
2. **Image Hosting**: In this standalone offline release, sample images are linked to verified public pet photos on Unsplash. When running offline without an active internet connection, local placeholder icons gracefully render in place of network images.
3. **Email Notifications**: Adoption requests and status changes trigger in-app state updates and notifications; external SMTP email delivery requires a backend mailing service integration.
