"""Verify existing native configuration. Safe to run repeatedly."""
from pathlib import Path
root=Path(__file__).resolve().parents[1]
manifest=(root/'android/app/src/main/AndroidManifest.xml').read_text(encoding='utf-8')
assert 'POST_NOTIFICATIONS' in manifest and 'ScheduledNotificationBootReceiver' in manifest
assert 'isCoreLibraryDesugaringEnabled = true' in (root/'android/app/build.gradle.kts').read_text(encoding='utf-8')
assert 'app.ritmia.ritmia' in (root/'android/app/build.gradle.kts').read_text(encoding='utf-8')
for path in ['assets/brand/app-icon-ai.png','assets/lottie/rhythm.json','assets/lottie/calendar.json','assets/lottie/bell.json']:
 assert (root/path).exists(),path
print('Ritmia native setup verified')
