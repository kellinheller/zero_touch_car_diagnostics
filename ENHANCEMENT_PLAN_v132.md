# ZTCD v1.31+ Enhancement Plan

## Phase 1: Repository Merge

### Current State
- `/home/mark/zero_touch_car_diagnostics/` - Original repo (might have older code)
- `/home/mark/zero_touch_car_diagnostics_vs2/` - Current active repo (Flipper Zero removed, v1.31.0)
- Remote: `https://github.com/donniebrasc/zero_touch_car_diagnostics_vs2.git`

### Merge Strategy
1. Keep `zero_touch_car_diagnostics_vs2` as the primary (already has latest code)
2. Archive old repo as backup
3. Consolidate all work into single repository

### Execute Merge
```bash
# Backup old repo
cd /home/mark
mv zero_touch_car_diagnostics zero_touch_car_diagnostics_old_backup

# Rename vs2 to be the main
mv zero_touch_car_diagnostics_vs2 zero_touch_car_diagnostics

# Update remote to use unified name (optional)
cd zero_touch_car_diagnostics
# Keep as is, or update repo name on GitHub
```

---

## Phase 2: Car Graphics UI Enhancement

### Current Dashboard Structure
- Main dashboard with 3 tabs (Dashboard, Map, Trips)
- Real-time OBD sensor display
- Trip recording controls

### New UI Elements
1. **Vehicle Status Display**
   - Car silhouette with health indicators
   - Engine status (running, idle, fault)
   - Temperature gauge visualization
   - Battery/fuel display on vehicle graphic

2. **Real-time Sensor Visualization**
   - Animated RPM gauge (circular)
   - Speed gauge display
   - Temperature overlay on car graphic (color-coded)
   - Pressure indicators

3. **Trip Map Overlay**
   - Car icon that follows route
   - Damage/wear indicators on route segments

### Implementation Plan
1. Add SVG assets for car graphics
2. Create car status widget component
3. Integrate into main dashboard
4. Add animations for real-time updates

### Files to Modify
- `lib/pages/main_dashboard_page.dart` - Add car graphics display
- Create `lib/widgets/car_status_widget.dart` - New widget for vehicle visualization
- Create `lib/assets/car_graphics.dart` - SVG car graphics
- Update `pubspec.yaml` - Add graphics libraries if needed

---

## Phase 3: Gemini 2.5 Flash Integration

### Current Issue
- General Gemini API keys don't work properly
- Need default/configured API for reliable diagnosis

### Solutions (choose one or combine):

#### Option A: Backend Service (Recommended for production)
- Create backend server with managed API key
- Flutter app calls backend instead of direct Gemini API
- Backend proxies to Gemini with credentials
- Backend URL: `https://your-backend/api/diagnose`

#### Option B: Firebase Functions (Medium complexity)
- Use Firebase Cloud Functions with API key
- Deploy function with embedded key
- Call from Flutter via Firebase
- More secure than client-side

#### Option C: Gemini API Project Setup
- Create Google Cloud project
- Set up Gemini API with proper billing
- Generate service account key
- Use restricted API key (Android package restriction)

#### Option D: Use Gemini 2.0 Flash (Alternative)
- Switch to `gemini-2.0-flash-exp` which has better free tier support
- Simpler to implement
- May have similar limitations

### Recommendation: Option C + Rate Limiting
1. User configures their own Gemini 2.5 Flash API key in settings
2. App validates key on first use
3. Show helpful error messages if key fails
4. Implement request queuing/caching to reduce API calls
5. Document best practices for API key usage

### Implementation
- Update `lib/services/gemini_client.dart`
- Add API key validation method
- Implement response caching
- Add fallback error messages
- Update `lib/pages/settings_page.dart` with setup guide

---

## Phase 4: Testing & Release

### Build Version
- v1.32.0 (next after v1.31.0)

### Test Checklist
- Car graphics render correctly
- Real-time gauge updates smooth
- Gemini diagnosis working
- Trip logging captures all data
- GPS map displays correctly

### Release Steps
1. Update version in `pubspec.yaml` to 1.32.0
2. Build new APK
3. Commit all changes
4. Create tag `v1.32.0`
5. Push to GitHub
6. Create release on GitHub with APK

---

## Implementation Timeline

| Phase | Task | Est. Time |
|-------|------|-----------|
| 1 | Merge repos | 15 min |
| 2a | Create car graphics assets | 30 min |
| 2b | Build car status widget | 45 min |
| 2c | Integrate into dashboard | 30 min |
| 3a | Update Gemini configuration | 20 min |
| 3b | Add API key validation | 20 min |
| 4 | Build, test, release | 45 min |
| | **Total** | **~3 hours** |

---

## Files to Create/Modify

### New Files
- `lib/widgets/car_status_widget.dart` - Car graphics widget
- `lib/widgets/gauge_widget.dart` - Animated gauge display
- `lib/assets/car_graphics.dart` - SVG/vector graphics

### Modified Files
- `lib/pages/main_dashboard_page.dart` - Add car graphics display
- `lib/services/gemini_client.dart` - Improve API handling
- `lib/pages/settings_page.dart` - Better API key setup
- `pubspec.yaml` - Version bump + new dependencies (if needed)

---

## Dependencies Needed

Current: `google_generative_ai`, `google_maps_flutter`, `sensors_plus`, etc.

Possible additions:
- `flutter_svg` - For SVG graphics (optional)
- `animated_percent_indicators` - For gauges (optional)
- `provider` - For state management if needed

---

## Next Steps

1. ✅ Review this plan
2. ⏳ Confirm approach (especially Gemini API handling)
3. ⏳ Start Phase 1: Repository merge
4. ⏳ Start Phase 2: Car graphics UI
5. ⏳ Start Phase 3: Gemini configuration
6. ⏳ Build and release v1.32.0

**Ready to proceed? Which phase should we start with?**
