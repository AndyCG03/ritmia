"""Verify a built release APK, including dynamically referenced notification resources."""
from pathlib import Path
import argparse, hashlib, json, os, subprocess, zipfile

parser=argparse.ArgumentParser()
parser.add_argument('apk',type=Path)
parser.add_argument('--expected-version',required=True)
parser.add_argument('--sdk',type=Path,default=Path(os.environ.get('ANDROID_SDK_ROOT',str(Path.home()/'Android'/'Sdk'))))
args=parser.parse_args()
tools=args.sdk/'build-tools'/'36.0.0'
def dump(*flags):return subprocess.check_output([str(tools/'aapt2.exe'),'dump',*flags,str(args.apk)],text=True,encoding='utf8',errors='replace')
badging=dump('badging')
assert "name='app.ritmia.ritmia'" in badging,'Wrong package'
assert "versionName='"+args.expected_version+"'" in badging,'Wrong app version'
resources=dump('resources')
assert 'drawable/ic_stat_ritmia' in resources,'Release shrinker removed the notification icon; OS permission and posting must be tested independently'
for resource in ['layout/ritmia_widget','layout/ritmia_widget_row','xml/ritmia_widget_info','xml/ritmia_widget_row_info']:
 assert resource in resources,'Missing widget resource: '+resource
with zipfile.ZipFile(args.apk) as z:
 assert 'lib/arm64-v8a/libapp.so' in z.namelist(),'Missing ARM64 runtime'
 root=Path(__file__).resolve().parents[1]
 assert z.read('assets/flutter_assets/assets/brand/app-icon-ai.png')==(root/'assets/brand/app-icon-ai.png').read_bytes(),'Original identity PNG differs'
 dex_blobs=[z.read(n) for n in z.namelist() if n.startswith('classes') and n.endswith('.dex')]
 assert any(b'RenewalWidgetProvider' in b for b in dex_blobs),'Missing native widget receiver'
 assert any(b'RenewalRowWidgetProvider' in b for b in dex_blobs),'Missing native row widget receiver'
print(json.dumps({'apk':str(args.apk),'version':args.expected_version,'bytes':args.apk.stat().st_size,
 'sha256':hashlib.sha256(args.apk.read_bytes()).hexdigest(),'retainedNotificationIcon':True,'originalLogo':True,'widgetPackaged':True}))
