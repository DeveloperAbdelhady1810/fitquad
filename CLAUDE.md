# FitQuad — Flutter App: Complete Reference for Claude Code

## Project Overview

FitQuad is a gym management Flutter app with three distinct user roles: **Member**, **Coach**, and **Admin**. It connects to a Laravel 12 backend API (Sanctum auth, role middleware).

- **Flutter** version: SDK ^3.9.2 (Dart 3)
- **Backend base URL (debug):** `http://192.168.1.26:8080/api/v1` — change the IP in `lib/core/services/api_client.dart` line 9 to match your local network
- **Backend base URL (release):** `https://api.fitquad.com/api/v1`
- **Design size:** 375×812 (flutter_screenutil) — always use `.r`, `.w`, `.h`, `.sp` for sizing
- **State management:** BLoC / Cubit
- **Navigation:** go_router v17 — use `context.push()`, `context.pop()`, `context.go()`
- **Localization:** `flutter_intl` — strings via `S.of(context).key`

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on iOS simulator / Android emulator
flutter run

# Run on specific device
flutter run -d <device-id>

# Build release APK
flutter build apk --release
```

**Backend requirement:** Laravel API must be running on the same network as the device/emulator. Update `baseUrl` in `lib/core/services/api_client.dart` if your IP differs from `192.168.1.26:8080`.

---

## Architecture

```
lib/
├── core/
│   ├── enums/          # AdminTab, Categories, ChooseCoach, MemberType, MessagesTab, etc.
│   ├── helpers/        # AppDecorations, spacing helpers (vGap/hGap), SharedPrefHelper
│   ├── rouets/         # app_router.dart + router_list.dart (all GoRoutes)
│   ├── services/       # ApiClient, GeminiService, HealthService, ReminderService
│   ├── theme/          # AppColors, AppTextStyles
│   └── widgets/        # Reusable: SubscriptionGate, CustomButton, ColumnChart, etc.
├── features/
│   ├── admin/          # Admin panel (dashboard, members, coaches, products, analytics)
│   ├── auth/           # Login, register, social auth, onboarding survey
│   ├── coach/          # Coach home, sessions, members, chat, calendar, profile
│   └── member/         # All member features (see detail below)
└── main.dart
```

---

## Color Palette (AppColors)

| Name | Hex | Use |
|------|-----|-----|
| `primary` | `#020618` | Background (darkest) |
| `secondary` | `#0F172A` | Cards, sheets |
| `teal` | `#00a689` | Primary action, accents |
| `emerald` | `#50C878` | Success, XP, nutrition |
| `blue` | `#4d8dbd` | Info, branches |
| `purple` | `#a338d8` | Admin, premium |
| `grey` | `#e8c1bbbb` | Muted text, icons |
| `red` | `#FF0000` | Error, destructive |

All backgrounds are dark. All text on dark background uses white or grey variants.

---

## Authentication Flow

### Files
- `lib/features/auth/data/auth_repository.dart` — all API calls
- `lib/features/auth/ui/views/` — SplashScreen, LoginView, SignUpView, SurveyView (onboarding)
- `lib/features/auth/ui/widgets/` — LoginViewBody, onboarding steps

### Flow
1. `SplashScreen` (`/`) — checks stored token → routes to correct home
2. `LoginView` (`/login`) — email/password + Google + Apple sign-in
3. `SignUpView` (`/sign_up`) — register with role selection
4. **Onboarding survey** (`/onboarding`) — shown only on first login (`is_onboarded == false` from backend)
5. After onboarding → `BottomNavBarView` (`/nav`)

### Token storage
`ApiClient` stores token and role in `SharedPreferences` (`auth_token`, `auth_role`).

### Role routing
After login, role is read → navigate to:
- `member` → `/nav`
- `coach` → `/coach_nav`
- `admin` → `/admin`

---

## Member App

### Bottom Navigation (`/nav`)
File: `lib/features/member/home/ui/views/bottom_nav_bar_view.dart`

5 tabs (index 0–4):
| Index | Tab | Widget |
|-------|-----|--------|
| 0 | Home | `HomeTab` |
| 1 | Train | `TrainTab` (or `WeekSummaryScreen` if plan exists) |
| 2 | AI | `AiTab` |
| 3 | Eat | `EatTab` |
| 4 | Market | `MarketTab` |

**AnnouncementOverlay** wraps the entire nav — checks for unseen admin announcements on load and shows full-screen story cards.

**GymSelectionScreen** is pushed automatically if `member.needsGymSelection == true` (i.e., `training_mode` is null).

### State Management (MemberCubit)
File: `lib/features/member/home/manager/member_cubit.dart`

States: `MemberLoading`, `MemberLoaded(member)`, `MemberError`, `MemberUpdated`, `CoachLoaded(coaches)`

`loadAll()` is called in `BottomNavBarView.initState()`. It fetches:
- Dashboard (`GET /member/dashboard`) → `MemberModel`
- Workout plan → `workoutPlan` map
- Nutrition plan → `nutritionPlan` map
- Check-ins (last 7 days) → `weekCheckIns` list
- Progress (streak/XP/badges) → `progressData` map

### MemberModel fields
File: `lib/features/member/data/models/member_model.dart`

| Field | Type | Source |
|-------|------|--------|
| `id` | String? | member.id |
| `name` | String? | user.name |
| `weight` | double? | member.current_weight |
| `sleepHrs` | double? | member.sleep_hours |
| `waterL` | double? | member.water_liters |
| `status` | MemberStatus? | active / inactive / frozen / expiring |
| `streakDays` | int | member.streak_days |
| `xpPoints` | int | member.xp_points |
| `level` | int | member.level |
| `referralCode` | String? | member.referral_code |
| `loyaltyPoints` | int | member.loyalty_points |
| `branchId` | String? | member.branch_id |
| `trainingMode` | String? | member.training_mode |

`MemberModel.fromJson()` handles nested `{ member: { user: {} } }` structure from backend.

---

## Member Screens (complete list)

### Home Tab (`/nav` index 0)
File: `lib/features/member/home/ui/widgets/home_tab.dart`

**Widgets in scroll order:**
1. AppBar — date, greeting, QR button, chat button, profile button, notifications button
2. `StreakCard` — streak + XP bar (from `lib/features/member/gamification/streak_card.dart`)
3. `_ExpiryBanner` — orange warning if `member.status == MemberStatus.expiring`
4. `_CoachUpsellBanner` — shown if `streakDays >= 10 && member.type == null`
5. Workout card + "Start" button → pushes `WorkoutActiveScreen`
6. Nutrition row (macros summary)
7. Activity chart (real check-in data from `weekCheckIns`)
8. Metric tiles: Weight / Sleep / Water
9. Health data (Apple Health / Google Fit via `HealthCubit`)
10. `_CommunityBanner` → pushes `/community`
11. `_CrowdingBanner` — if branch crowding data available

**Dialogs triggered from home:**
- `showQrSheet(context)` → QR code modal
- `showWaterDialog(context)` → water logging
- `showWeekDialog(context)` → workout week overview
- "Send to Coach" → `MemberRepository.sendMessageToCoach()`

### Workout Active Screen (`/workout-active`)
File: `lib/features/member/home/ui/views/workout_active_screen.dart`

Full-screen workout session. Receives `exercises` (List) and `plan_title` (String) via `state.extra as Map<String, dynamic>`.

Features:
- Exercise PageView (swipe left/right)
- Per-set rep counter with start/complete buttons
- Rest timer countdown (30/60/90s configurable)
- Elapsed time display
- Confetti on completion
- Completion screen: duration, exercise count, estimated kcal
- Post-workout supplement upsell card
- Auto-logs check-in on completion

### Train Tab (`/nav` index 1)
File: `lib/features/member/train/widgets/train_tap.dart`

Three option cards (gradient UI):
- **Manual** → `DesignPlanManuallyScreen` (`/design_plan_manually`)
- **AI Plan** → uses `GeminiService` to generate a workout plan
- **Coach** → `ChooseCoachScreen` (`/choose_coach`)

History button → `WorkoutHistoryScreen` (`/workout-history`)

#### DesignPlanManuallyScreen (`/design_plan_manually`)
Muscle group selection → exercise picker per day → save to API (`POST /member/workout-plan`)

#### WorkoutHistoryScreen (`/workout-history`)
File: `lib/features/member/train/widgets/workout_history_screen.dart`
Lists check-ins from `GET /member/check-ins`. Each card shows date, time, branch, XP gained, streak days.

### Eat Tab (`/nav` index 3)
File: `lib/features/member/eat/widgets/eat_tap.dart`

Shows daily macros overview and meal log. Options:
- **Manual nutrition plan** → `DesignNutritionManuallyScreen`
- **AI Nutrition Plan** → `NutritionProposalDialog` → Gemini generates plan
- **Coach for Nutrition** → `ChooseCoachScreen` (source=eat)
- `NutritionPlanScreen` (`/nutrition_plan`) — shows full plan with daily meal cards
- Meal logging: `FoodSearchDialog` (text search + **barcode scanner**)

#### FoodSearchDialog
File: `lib/features/member/home/ui/widgets/food_search_dialog.dart`
Has a QR/barcode icon button → opens `BarcodeScannerScreen` → on scan result, auto-fills the food via `MemberRepository.getFoodItemByBarcode(barcode)`

#### BarcodeScannerScreen
File: `lib/features/member/home/ui/widgets/barcode_scanner_screen.dart`
Uses `MobileScannerController`. Animated scan line. Torch toggle. Returns food map to caller via `Navigator.pop(context, food)`.

### AI Tab (`/nav` index 2)
File: `lib/features/member/ai/ai_tab.dart`

Personalised AI coach chat powered by **Gemini** via the backend (`POST /member/ai/chat`).

**State:** `AiAssistantCubit` emits `AiChatState { messages, inBodyAttached }`.

**Personalisation system:**
- `AiMemberContext` (`lib/features/member/ai/models/ai_member_context.dart`) builds a structured `[FITQUAD_MEMBER_CONTEXT]` prefix injected before every message sent to the backend. It includes: member name, goal, weight, age, streak/level/XP, weekly check-ins, workout plan name, nutrition plan kcal, and optionally the full InBody scan.
- Greeting message is goal-specific (`MemberType.loss / fit / low / neww`).
- Suggested prompt chips are also goal-driven (4 chips, differ per goal).

**InBody attachment:**
- `AiTab` loads the latest InBody record on init via `MemberRepository.getInBodyRecords()`.
- "Attach InBody" chip is **always visible** in `MessageInput`.
  - If records exist (`hasData: true`) → toggle attach/detach normally.
  - If no records (`hasData: false`) → chip shows greyed "Attach InBody (no scan yet)"; tapping shows a SnackBar telling the user to add one in the InBody tab.
- Toggle is **persistent** (stays attached until tapped again).
- When attached, `inBodyAttached: true` is set in `AiChatState`; the next send includes all InBody metrics in the context prefix.
- Sent messages with InBody show a small "InBody attached" label below the bubble.

**Cubit key methods:**
- `updateContext(AiMemberContext)` — called every build; sets personalized greeting once member data loads (flag `_greetingSet`)
- `sendMessage(String)` — builds enriched prompt from stored context, sends to API
- `toggleInBody()` — flips `inBodyAttached` in state
- `clearChat()` — resets to personalized greeting

**Message rendering:**
- `ChatBubble` uses `flutter_markdown` (`MarkdownBody`) for AI responses — renders bold, headings, bullet lists, numbered lists, code blocks, blockquotes in dark-theme style.
- User messages render as plain `Text`.
- Typing indicator: animated bouncing 3-dot row (`_TypingDots`) with staggered `AnimationController`s.

**ChatMessage model** (`lib/features/member/data/models/message_model.dart`):
`{ text, isUser, isTyping, inBodyAttached }` — `inBodyAttached` flag drives the "InBody attached" label.

**Known issue:** Requires valid Gemini API key in `GeminiService`. If chat shows error, check `lib/core/services/gemini_service.dart`.

### InBody Screen (`/inbody`)
File: `lib/features/member/inbody/ui/inbody_screen.dart`

Two tabs via `DefaultTabController`:
1. **Records** — list of InBody measurements with fl_chart graphs (weight, fat%, muscle mass trend)
2. **Progress Photos** — `ProgressPhotosTab`

Add button (top-right) → `InBodyFormScreen` when on Records tab.

#### InBodyFormScreen (`/inbody_form`)
File: `lib/features/member/inbody/ui/inbody_form_screen.dart`
Input fields for all InBody metrics. On save:
- POSTs to `POST /member/inbody-records`
- Calls `GeminiService.sendMessageWithInBody()` for AI interpretation
- Shows AI insight dialog before popping

#### ProgressPhotosTab
File: `lib/features/member/inbody/ui/progress_photos_tab.dart`
Loads from `GET /member/progress-photos`. Upload via `ImagePicker` (gallery). Shows grid of `_PhotoCard` with network images. Delete by swiping or tapping trash.

### Badges / Gamification Screen (`/badges`)
File: `lib/features/member/gamification/badges_screen.dart`

Stats row: Level, Streak, XP, Check-ins. Badge grid (3 columns) showing earned/locked state with progress bars. Leaderboard button in AppBar → `LeaderboardScreen`.

Data source: `GET /member/progress` which returns `{ streak_days, xp_points, level, total_checkins, badges: [...] }`

#### StreakCard
File: `lib/features/member/gamification/streak_card.dart`
Displayed on home tab. Shows flame emoji + streak count + XP progress bar to next level milestone.

### Leaderboard Screen (`/leaderboard`)
File: `lib/features/member/community/leaderboard_screen.dart`

3 lazy-loaded tabs (TabController):
- 📍 Most Check-ins → `GET /member/leaderboard?category=check_ins`
- 🔥 Longest Streak → `GET /member/leaderboard?category=streak`
- ⭐ Most XP → `GET /member/leaderboard?category=xp`

Current member row highlighted in teal with "(You)" label. Medal emojis for top 3.

### Community Feed Screen (`/community`)
File: `lib/features/member/community/community_feed_screen.dart`

Posts from `GET /member/community/posts`. Each `_PostCard` shows:
- Author avatar (initials), name, time-ago
- Post type badge (workout_share / milestone / coach_tip)
- Text body
- 3 emoji reaction buttons (💪 🔥 🎉) with toggle — `POST /member/community/posts/{id}/react`

FAB / compose button → bottom sheet with 300-char TextField → `POST /member/community/posts`.

### Coach Selection Screen (`/choose_coach`)
File: `lib/features/member/home/ui/widgets/choose_coach_screen.dart`

Lists coaches filtered by `source` (train/eat) and member's gym. Each `_CoachCard` shows avatar, name, title, service/turnaround tags, rating, bio preview.

**Tap card** → `CoachProfileScreen` (pushed via `Navigator.push`)
**Hire button** → `_showHireDialog` (fee breakdown) → `_initiatePayment` → `PaymentWebviewScreen`

### Coach Profile Screen
File: `lib/features/member/home/ui/widgets/coach_profile_screen.dart`

Full-screen profile with `SliverAppBar` hero, star rating row, specialization chips (from `coach.coachType`), stats row (price/delivery/rating), benefits list.

Bottom bar: price display + "Hire Coach" button → bottom sheet with fee breakdown → `PaymentRepository.initiateCoachPayment()` → `PaymentWebviewScreen`.

### Payment Webview Screen (`/payment_webview`)
File: `lib/features/member/payment/ui/payment_webview_screen.dart`
Receives `payment_url`, `coach_name`, `total_amount` via `state.extra as Map`. Shows Paymob payment iframe in `WebViewWidget`.

### Market Tab (`/nav` index 4)
File: `lib/features/member/shop/ui/widgets/market_tab.dart`

- Search field + filter button
- Category tabs (`MarketTabs`)
- `FlashSaleBanner` — appears automatically when any product has `sale_price` set; live countdown timer to midnight
- `MarketGridView` — 2-column grid of `ProductCard`

**Loading:** `MarketCubit` is provided and `loadProducts()` is called in `main.dart` (`BlocProvider(create: (_) => MarketCubit()..loadProducts())`). Products load at startup. If the grid shows empty, the API is returning no data or an error — check `GET /member/shop/products` and the products seeder.

Tap product card → `ProductDetailScreen` (via `Navigator.push` with `BlocProvider.value(CartCubit)`)

#### ProductCard
File: `lib/features/member/shop/ui/widgets/product_card.dart`
SALE chip badge when `product.isOnSale`. Shows effective price (sale price in red with strikethrough original).

#### ProductDetailScreen
File: `lib/features/member/shop/ui/views/product_detail_screen.dart`
Network image (4:5), category chip, rating, price/sale badge, stock status, description, benefits list. Sticky "Add to Cart" bottom bar.

#### CartView (`/cart`)
File: `lib/features/member/shop/ui/views/cart_view.dart`
`CartCubit` manages cart state. Checkout → `MemberRepository.placeOrder()`.

### Notifications Screen (`/notifications`)
File: `lib/features/member/notifications/notifications_screen.dart`
Lists from `GET /member/notifications`. Mark read via `POST /member/notifications/read`.

### Notification Preferences Screen (`/notification-preferences`)
File: `lib/features/member/notifications/notification_preferences_screen.dart`
Toggles for water reminders (every 2h, 9am–9pm) and sleep reminder (10:30pm). Uses `ReminderService` + `SharedPreferences`.

### Profile Screen (`/profile`)
File: `lib/features/member/profile/ui/widgets/profile_tab.dart`

Sections:
- Avatar + name + plan badge
- Personal Details (bottom sheet) — name, weight, goal
- Membership & Billing (bottom sheet) — subscription status
- Visit History (bottom sheet) — check-in list
- Settings → Notifications (nav to `NotificationPreferencesScreen`), Language toggle
- **Loyalty Points Card** — shows `loyaltyPoints`, credit equivalent, earn rate
- **Referral Card** — shows `referralCode`, copy + share via Clipboard
- Sign Out

### QR Screen
File: `lib/features/member/qr/qr_screen.dart`
Full-screen modal showing `QrImageView(data: memberId)`. Triggered from home AppBar QR button.

### Member Chat Screen
File: `lib/features/member/home/ui/widgets/member_chat_screen.dart`
Chat thread with coach. Loads `GET /member/messages`. Speech-bubble UI (teal for member, dark for coach). Send via `POST /member/messages`. Opened from chat bubble icon in home AppBar.

### Gym Selection Screen (`/gym_selection`)
File: `lib/features/member/gym/ui/gym_selection_screen.dart`
Shown automatically if `member.trainingMode == null`. Options: partner gym list, solo training. Calls `MemberRepository.assignBranch()`.

### Announcements Overlay
File: `lib/features/member/announcements/announcement_overlay.dart`
Wraps `BottomNavBarView`. Fetches `GET /member/announcements` on load, filters seen IDs (stored in `SharedPreferences` key `seen_announcements`). Shows full-screen story card with optional CTA button. Supports multiple announcements with progress dots.

### Subscription Gate Widget
File: `lib/core/widgets/subscription_gate.dart`
Wraps any premium feature. If `member.status` is not `active`, shows a locked overlay. Tap → bottom sheet with Basic vs Pro feature comparison. Used in `AiTab` and other gated features.

---

## Coach App

### Coach Bottom Navigation (`/coach_nav`)
File: `lib/features/coach/home/ui/views/coach_bottom_nav_bar_view.dart`

4 tabs:
| Index | Tab |
|-------|-----|
| 0 | Home (`CoachHomeTab`) |
| 1 | Members (`MembersTab`) |
| 2 | Chat (`CoachChatTab`) |
| 3 | Calendar (`CalendarTab`) |

Providers: `MessagesCubit`, `CoachCubit` (calls `getCoachSessions('1')` on init)

### Coach Home Tab
File: `lib/features/coach/home/ui/widgets/home_tab.dart`

Full BlocBuilder on `CoachCubit`. Shows:
1. **4 stat cards** (horizontal scroll): Today's Sessions, Active Clients, Monthly Earnings, Rating
2. **Today's Schedule** — horizontal scroll of upcoming sessions (up to 5)
3. **Client Alerts** — colored cards (inactive 5+ days, expiring subscription, streak milestone)
4. **Members strip** — horizontal avatar row
5. **Quick Actions** (2×2 grid): Create Plan, Nutrition Plan, Broadcast, Add Session

Stat/alert data comes from `CoachRepository.getDashboard()` → `dashboard['client_alerts']` list.

### Coach Members Tab
File: `lib/features/coach/members/widgets/members_tab.dart`
Lists `_allMembers` from `CoachCubit`. Filter by `MemberType`. Tap → `MemberProfileScreen`.

### Member Profile Screen (Coach view)
File: `lib/features/coach/home/ui/widgets/member_profile_screen.dart`
5-tab view for a specific member: Overview, Training, Nutrition, InBody, Analysis.

### Coach Chat Tab
File: `lib/features/coach/chat/widgets/coach_chat_tab.dart`
3 tabs: All / Members / System (filtered via `MessagesCubit`). Tap a member conversation → `CoachChatThreadScreen`.

### Coach Chat Thread Screen
File: `lib/features/coach/chat/widgets/chat_thread_screen.dart`
Full chat thread with a specific member. Features:
- Message bubbles (teal for coach, dark for member)
- ⚡ Quick Templates button (6 pre-written messages: "Great job today! 💪", etc.)
- Templates horizontal scroll bar
- Loads `GET /coach/messages/{memberId}`, sends `POST /coach/messages`

### Coach Calendar Tab
File: `lib/features/coach/calender/widgets/calender_tab.dart`
Week/day view of sessions.

### Coach Profile Tab
File: `lib/features/coach/profile/widgets/profile_tab.dart`
Coach info editor.

### CoachCubit State
File: `lib/features/coach/home/manager/coach_state.dart`

`CoachesLoaded` contains:
- `sessions` — List<SessionModel>
- `allMembers` / `filteredMembers` — List<MemberModel>
- `todaySessions`, `activeMembers`, `monthlyEarnings`, `totalEarnings`, `rating` — dashboard stats
- `clientAlerts` — List<Map> from backend

---

## Admin App (`/admin`)
File: `lib/features/admin/ui/views/admin_view.dart`

Drawer navigation with 10 tabs:

| Tab | Widget | Data |
|-----|--------|------|
| Dashboard | `AdminViewBody` | `GET /admin/dashboard` — stats + line chart + bar chart + top products |
| Members | `MembersBody` | `GET /admin/members` — search + status filter |
| Coaches | `CoachesBody` | `GET /admin/coaches` |
| Plans | `PlansBody` | `GET /admin/subscription-plans` |
| Check-ins | `CheckInsBody` | `GET /admin/check-ins` |
| Market | `MarketBody` | `GET /admin/products` + orders |
| Analytics | `AnalyticsBody` | `GET /admin/analytics` |
| Marketing | `MarketingBody` | Promo codes + announcements |
| Staff | `StaffBody` | `GET /admin/staff` |
| Settings | `SettingsBody` | App configuration |

All admin data via `lib/features/admin/data/admin_repository.dart`.

---

## Backend API Reference

### Base URL
`http://<YOUR_LOCAL_IP>:8080/api/v1` (debug) — set in `lib/core/services/api_client.dart`

### Auth Headers
All protected routes require: `Authorization: Bearer <token>`

### Auth Routes (public)
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/register` | Register with role |
| POST | `/auth/login` | Email + password |
| POST | `/auth/social` | Google / Apple |
| POST | `/auth/forgot-password` | Password reset |
| POST | `/auth/reset-password` | Confirm reset |

### Protected Auth
| Method | Path | Description |
|--------|------|-------------|
| POST | `/auth/logout` | Invalidate token |
| GET | `/auth/me` | Current user data |
| PUT | `/auth/profile` | Update profile |

### Member Routes (role:member)
| Method | Path | Description |
|--------|------|-------------|
| GET/PUT | `/member/dashboard` | Member profile + stats |
| GET | `/member/coaches` | Coach list (filtered by gym + ?source=train\|eat) |
| POST | `/member/coach-requests` | Request a coach plan |
| GET/POST | `/member/workout-plan` | Workout plan |
| GET | `/member/exercises` | Exercise library |
| GET/POST | `/member/nutrition-plan` | Nutrition plan |
| GET | `/member/food-items` | Food search |
| GET | `/member/food-items/barcode?barcode=xxx` | Barcode lookup |
| POST | `/member/logged-meals` | Log a meal |
| GET | `/member/logged-meals` | Today's meals |
| GET | `/member/week-summary` | 7-day nutrition |
| GET/POST | `/member/check-ins` | Check-in history + new check-in |
| GET | `/member/sessions` | Coach sessions |
| GET/POST | `/member/inbody-records` | InBody data |
| GET | `/member/shop/products` | Products (filterable) |
| POST | `/member/shop/orders` | Place order |
| GET | `/member/shop/orders` | Order history |
| GET | `/member/notifications` | Notifications |
| POST | `/member/notifications/read` | Mark read |
| POST | `/member/ai/chat` | AI chat |
| GET | `/member/ai/history` | Chat history |
| POST/GET | `/member/messages` | Coach messages |
| GET | `/member/branches` | Gym branches |
| POST | `/member/branch` | Assign to branch |
| GET | `/member/branches/{id}/crowding` | Crowding % |
| POST | `/member/payments/initiate` | Paymob payment init |
| GET | `/member/payments/fee` | Fee calculation |
| GET | `/member/progress` | Gamification data |
| GET/POST | `/member/progress-photos` | Progress photos |
| DELETE | `/member/progress-photos/{id}` | Delete photo |
| GET/POST | `/member/community/posts` | Community feed |
| POST | `/member/community/posts/{id}/react` | Toggle reaction |
| GET | `/member/leaderboard?category=check_ins\|streak\|xp` | Leaderboard |
| GET | `/member/announcements` | Admin announcements |

### Coach Routes (role:coach)
| Method | Path | Description |
|--------|------|-------------|
| GET | `/coach/dashboard` | Stats + client alerts |
| GET | `/coach/members` | Member list |
| GET | `/coach/members/{id}` | Member detail |
| GET/POST | `/coach/sessions` | Sessions CRUD |
| PUT/DELETE | `/coach/sessions/{id}` | Update/delete session |
| GET | `/coach/plan-requests` | Plan requests |
| PUT | `/coach/plan-requests/{id}` | Update request status |
| POST | `/coach/workout-plans` | Create workout plan |
| POST | `/coach/nutrition-plans` | Create nutrition plan |
| GET | `/coach/messages` | Conversation list |
| GET | `/coach/messages/{memberId}` | Thread with member |
| POST | `/coach/messages` | Send message |
| POST | `/coach/broadcast` | Broadcast to all |

### Admin Routes (role:admin)
All under `/admin/*` — members, coaches, subscriptions, products, orders, analytics, check-ins, staff, promo-codes, announcements.

### Webhook (public)
`POST /payments/webhook` — Paymob callback (no auth)

---

## Key Services

### ApiClient (`lib/core/services/api_client.dart`)
Static methods: `get()`, `post()`, `put()`, `delete()`, `uploadMultipart()`.

All methods throw on non-2xx responses (exception message is the backend `message` field). Token auto-injected via `SharedPreferences`.

### GeminiService (`lib/core/services/gemini_service.dart`)
Wraps `google_generative_ai`. Methods:
- `sendMessage(prompt)` — general chat
- `sendMessageWithInBody(prompt, inBodyModel)` — InBody AI interpretation

Requires a valid Gemini API key set in the service file.

### ReminderService (`lib/core/services/reminder_service.dart`)
Wraps `flutter_local_notifications`. Must call `ReminderService.init()` before use (done in `main()`).
- `scheduleWaterReminders()` — IDs 100–119
- `scheduleSleepReminder()` — ID 200
- `cancelWaterReminders()` / `cancelSleepReminder()` / `cancelAll()`

### HealthService (`lib/core/services/health_service.dart`)
Reads Apple Health / Google Fit data via the `health` package. Requires permissions (`permission_handler`).

---

## Dependencies (non-obvious)

| Package | Version | Use |
|---------|---------|-----|
| `flutter_markdown` | ^0.7.7 | Renders Gemini markdown responses in AI chat |
| `mobile_scanner` | ^7.2.0 | Barcode scanning in food search |
| `flutter_local_notifications` | ^18.0.1 | Water + sleep reminders |
| `timezone` | ^0.9.4 | Required by flutter_local_notifications for zonedSchedule |
| `confetti` | ^0.7.0 | Milestone celebrations (streak, workout complete) |
| `image_picker` | ^1.1.2 | Progress photo upload |
| `qr_flutter` | ^4.1.0 | Member QR code at reception |
| `webview_flutter` | ^4.10.0 | Paymob payment iframe |
| `google_generative_ai` | ^0.4.6 | Gemini AI (also used directly in GeminiService) |

---

## Routing (`lib/core/rouets/router_list.dart`)

All routes registered with GoRouter. Extra data passed via `state.extra`:

| Route | Extra Type | Notes |
|-------|-----------|-------|
| `/workout-active` | `Map<String, dynamic>` | `{exercises: List, plan_title: String}` |
| `/choose_coach` | `ChooseCoachSource` (enum) | `train` or `eat` |
| `/plan_ready` | `ChooseCoachSource` | |
| `/payment_webview` | `Map<String, dynamic>` | `{payment_url, coach_name, total_amount}` |
| `/nutrition_overview` | `List<MealModel>` | |
| `/week_summary` | `List<Map<String, dynamic>>` | Week plan |
| `/member_profile` (coach) | `MemberModel` | |

Routes that use `Navigator.push` (not go_router): `CoachProfileScreen`, `ProductDetailScreen`, `CoachChatThreadScreen`, `MemberChatScreen`, `BarcodeScannerScreen`, `NotificationPreferencesScreen`.

---

## Common Patterns & Gotchas

### BLoC pattern
```dart
// Read without listening (one-off action)
context.read<MemberCubit>().loadAll();

// Listen and rebuild
BlocBuilder<MemberCubit, MemberState>(
  builder: (context, state) {
    if (state is MemberLoaded) { ... }
  },
);
```

### Sizing (always use screenutil)
```dart
EdgeInsets.all(16.r)          // responsive
SizedBox(height: 10.h)
Text('x', style: TextStyle(fontSize: 14.sp))
```

### Navigation
```dart
context.push('/route', extra: data);  // push onto stack
context.go('/route');                  // replace entire stack
context.pop();                         // go back
Navigator.push(context, MaterialPageRoute(builder: (_) => Screen()));  // non-router screens
```

### API error handling pattern
```dart
try {
  final data = await SomeRepository.method();
  if (mounted) setState(() { ... });
} catch (e) {
  if (mounted) ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(e.toString()), backgroundColor: AppColors.red),
  );
}
```

### AppColors usage
```dart
backgroundColor: AppColors.primary,   // darkest bg
color: AppColors.secondary,           // card bg
color: AppColors.teal,               // primary action
```

### AppDecorations
```dart
decoration: AppDecorations.containerDecoration  // standard card: secondary bg + rounded corners
```

---

## Known Lints / Pre-existing Warnings

These two warnings exist before any new changes — do not fix them unless specifically asked:
1. `lib/features/coach/home/ui/widgets/add_session_dialog.dart:123` — `use_build_context_synchronously`
2. `lib/features/member/home/ui/widgets/workout_page_view_dialog.dart:24` — `use_build_context_synchronously`

Run `dart analyze lib/` to check for new issues before committing.

---

## Testing Checklist

### Auth
- [ ] Login with email/password → routes to correct role home
- [ ] Google Sign-In → skips onboarding if returning user
- [ ] First-time user → sees onboarding survey
- [ ] Logout → clears token, returns to login

### Member Home
- [ ] Greeting shows real member name
- [ ] Streak card shows real streak days
- [ ] Activity chart shows real weekly check-in data
- [ ] QR code appears on tap
- [ ] Water / Sleep / Weight dialogs save to API

### Member Train
- [ ] Workout card shows real plan (not placeholder)
- [ ] "Start" → WorkoutActiveScreen with exercises
- [ ] Rest timer counts down
- [ ] Completion screen shows duration + kcal + supplement upsell card
- [ ] History tab shows real check-ins

### Member AI Coach
- [ ] Greeting shows member's first name and is goal-specific (different for loss / fit / low / new)
- [ ] Suggested prompt chips match the member's registered goal
- [ ] "Attach InBody" chip appears only when a record exists; hidden otherwise
- [ ] InBody chip toggles on/off (persistent until tapped again)
- [ ] Sending a message with InBody attached includes InBody data in the Gemini context (verify AI response references body composition)
- [ ] Sent message with InBody attached shows "InBody attached" label below the bubble
- [ ] AI response renders markdown: bold, bullets, numbered lists all styled correctly
- [ ] Typing indicator shows animated bouncing dots (not plain "...")
- [ ] Refresh icon clears chat and resets to personalized greeting
- [ ] Sending with no internet → shows friendly error message

### Member Eat
- [ ] Food search returns results
- [ ] Barcode scanner opens camera, scans, returns food
- [ ] Meal logging adds to today's log

### Member Market
- [ ] Products load from API
- [ ] Flash sale banner appears only when products have sale_price
- [ ] Tap product → ProductDetailScreen
- [ ] Add to cart → cart badge increments

### Member Community
- [ ] Feed loads posts
- [ ] Emoji reactions toggle (react again removes)
- [ ] Compose sheet posts a new item

### Member Profile
- [ ] Loyalty points card shows correct value
- [ ] Referral code visible and copyable
- [ ] Notification preferences toggles schedule/cancel reminders

### Coach App
- [ ] Dashboard shows real stats (not zeros)
- [ ] Client alerts appear for inactive members
- [ ] Tap chat conversation → CoachChatThreadScreen
- [ ] Quick template buttons send messages
- [ ] Add session dialog saves to API

### Admin
- [ ] Dashboard stats load from API
- [ ] Members list searchable
- [ ] Announcements post and appear in member app

---

## Common Runtime Errors

| Error message | Cause | Fix |
|---------------|-------|-----|
| `SQLSTATE: no such table: inbody_records` | Migration not run | `php artisan migrate` in backend directory |
| `SQLSTATE: no such table: community_posts` | Migration not run | `php artisan migrate` |
| `SQLSTATE: no such table: progress_photos` | Migration not run | `php artisan migrate` |
| Market grid empty, no spinner | `loadProducts()` not called | Confirmed fixed: `main.dart` uses `MarketCubit()..loadProducts()` |
| Attach InBody button not visible | No InBody records + old code | Fixed: button always visible; greyed when no data |
| AI says "couldn't connect" | Gemini API key invalid or quota | Check `GeminiService` key |
| `BlocProvider not found: MarketCubit` | Cubit not in tree | `MarketCubit` must be in `main.dart` `MultiBlocProvider` |

---

## Backend Migration Notes (local only, never pushed)

The following backend files were created/modified locally and are NOT in git:
- `database/migrations/2025_05_26_100003_add_gamification_to_members.php` — streak_days, xp_points, level, last_activity_date
- `database/migrations/2025_05_26_100004_create_progress_photos_table.php`
- `database/migrations/2025_05_26_100005_add_referral_to_members_table.php` — referral_code, referred_by_member_id
- `database/migrations/2025_05_26_100006_create_community_posts_table.php` — posts + community_reactions
- `app/Http/Controllers/Member/ProgressPhotoController.php`
- `app/Http/Controllers/Member/CommunityController.php`
- `app/Http/Controllers/Member/LeaderboardController.php`
- `app/Models/Member.php` — referral_code in fillable + booted() observer
- `routes/api.php` — all new routes added

Run after pulling backend:
```bash
php artisan migrate
php artisan db:seed --class=BadgesSeeder
php artisan db:seed --class=ProductSeeder
```
