"""Vendor 100+ small SVGs from one pinned Simple Icons commit."""
from pathlib import Path
from urllib.request import urlopen, Request
from concurrent.futures import ThreadPoolExecutor
import json, hashlib
root=Path(__file__).resolve().parents[1]
directory=root/'assets/services';directory.mkdir(parents=True,exist_ok=True)
def get(url):
    return urlopen(Request(url,headers={'User-Agent':'Ritmia-assets'}),timeout=40).read()
revision=json.loads(get('https://api.github.com/repos/simple-icons/simple-icons/commits/develop'))['sha']
tree=json.loads(get(f'https://api.github.com/repos/simple-icons/simple-icons/git/trees/{revision}?recursive=1'))['tree']
available={Path(e['path']).stem for e in tree if e['path'].startswith('icons/') and e['path'].endswith('.svg')}
# Familiar services with accounts/subscriptions; availability is checked against upstream.
candidates=[
('spotify','Spotify'),('netflix','Netflix'),('youtube','YouTube'),('github','GitHub'),('notion','Notion'),('figma','Figma'),('dropbox','Dropbox'),('discord','Discord'),('twitch','Twitch'),('patreon','Patreon'),
('apple','Apple'),('applemusic','Apple Music'),('appletv','Apple TV'),('applearcade','Apple Arcade'),('icloud','iCloud'),('amazonprime','Amazon Prime'),('amazonmusic','Amazon Music'),('audible','Audible'),('kindle','Kindle'),('google','Google'),('googledrive','Google Drive'),('googlecloud','Google Cloud'),('youtubemusic','YouTube Music'),('youtubegaming','YouTube Gaming'),
('hbo','HBO'),('hulu','Hulu'),('disneyplus','Disney+'),('paramountplus','Paramount+'),('peacock','Peacock'),('crunchyroll','Crunchyroll'),('mubi','MUBI'),('plex','Plex'),('stremio','Stremio'),('rakuten','Rakuten'),('tubi','Tubi'),('dazn','DAZN'),('f1','Formula 1'),('nba','NBA'),('mlb','MLB'),('nfl','NFL'),('ufc','UFC'),
('deezer','Deezer'),('tidal','Tidal'),('soundcloud','SoundCloud'),('bandcamp','Bandcamp'),('qobuz','Qobuz'),('pandora','Pandora'),('lastdotfm','Last.fm'),('tunein','TuneIn'),('iheartradio','iHeartRadio'),('pocketcasts','Pocket Casts'),('overcast','Overcast'),('mixcloud','Mixcloud'),('spreaker','Spreaker'),
('canva','Canva'),('adobe','Adobe'),('adobecreativecloud','Adobe Creative Cloud'),('affinity','Affinity'),('sketch','Sketch'),('framer','Framer'),('webflow','Webflow'),('wix','Wix'),('squarespace','Squarespace'),('wordpress','WordPress'),('ghost','Ghost'),('medium','Medium'),('substack','Substack'),('tumblr','Tumblr'),('behance','Behance'),('dribbble','Dribbble'),('unsplash','Unsplash'),('pexels','Pexels'),('freepik','Freepik'),('shutterstock','Shutterstock'),('envato','Envato'),('envatoelements','Envato Elements'),
('openai','OpenAI'),('anthropic','Anthropic'),('claude','Claude'),('perplexity','Perplexity'),('googlegemini','Google Gemini'),('huggingface','Hugging Face'),('replit','Replit'),('cursor','Cursor'),('elevenlabs','ElevenLabs'),('runway','Runway'),('grammarly','Grammarly'),('quillbot','QuillBot'),('deepl','DeepL'),
('slack','Slack'),('zoom','Zoom'),('trello','Trello'),('asana','Asana'),('clickup','ClickUp'),('todoist','Todoist'),('evernote','Evernote'),('obsidian','Obsidian'),('airtable','Airtable'),('mondaydotcom','monday.com'),('linear','Linear'),('miro','Miro'),('mural','Mural'),('coda','Coda'),('craft','Craft'),('readwise','Readwise'),('raindropdotio','Raindrop.io'),('superhuman','Superhuman'),('fastmail','Fastmail'),('hey','HEY'),('protonmail','Proton Mail'),('proton','Proton'),('tuta','Tuta'),('mailchimp','Mailchimp'),('brevo','Brevo'),('convertkit','ConvertKit'),('kit','Kit'),('buffer','Buffer'),('hootsuite','Hootsuite'),('later','Later'),
('1password','1Password'),('bitwarden','Bitwarden'),('dashlane','Dashlane'),('lastpass','LastPass'),('nordvpn','NordVPN'),('expressvpn','ExpressVPN'),('surfshark','Surfshark'),('protonvpn','Proton VPN'),('mullvadvpn','Mullvad VPN'),('windscribe','Windscribe'),('privateinternetaccess','Private Internet Access'),('tailscale','Tailscale'),
('mega','MEGA'),('pcloud','pCloud'),('box','Box'),('backblaze','Backblaze'),('sync','Sync'),('nextcloud','Nextcloud'),('owncloud','ownCloud'),('filen','Filen'),('tresorit','Tresorit'),('icedrive','Icedrive'),
('duolingo','Duolingo'),('coursera','Coursera'),('udemy','Udemy'),('skillshare','Skillshare'),('edx','edX'),('datacamp','DataCamp'),('pluralsight','Pluralsight'),('codecademy','Codecademy'),('brilliant','Brilliant'),('khanacademy','Khan Academy'),('masterclass','MasterClass'),('linkedin','LinkedIn'),('linkedinlearning','LinkedIn Learning'),('busuu','Busuu'),('babbel','Babbel'),('memrise','Memrise'),('anki','Anki'),('quizlet','Quizlet'),
('strava','Strava'),('fitbit','Fitbit'),('myfitnesspal','MyFitnessPal'),('headspace','Headspace'),('calm','Calm'),('peloton','Peloton'),('komoot','Komoot'),('alltrails','AllTrails'),('garmin','Garmin'),('nike','Nike'),
('steam','Steam'),('epicgames','Epic Games'),('playstation','PlayStation'),('xbox','Xbox'),('nintendo','Nintendo'),('ubisoft','Ubisoft'),('ea','EA'),('riotgames','Riot Games'),('roblox','Roblox'),('minecraft','Minecraft'),('chessdotcom','Chess.com'),('lichess','Lichess'),('humblebundle','Humble Bundle'),('gogdotcom','GOG.com'),
('gitlab','GitLab'),('bitbucket','Bitbucket'),('jetbrains','JetBrains'),('docker','Docker'),('vercel','Vercel'),('netlify','Netlify'),('cloudflare','Cloudflare'),('digitalocean','DigitalOcean'),('render','Render'),('railway','Railway'),('heroku','Heroku'),('supabase','Supabase'),('firebase','Firebase'),('mongodb','MongoDB'),('planetscale','PlanetScale'),('neon','Neon'),('sentry','Sentry'),('datadog','Datadog'),('postman','Postman'),('insomnia','Insomnia'),('browserstack','BrowserStack'),('lambdatest','LambdaTest'),('saucelabs','Sauce Labs'),('circleci','CircleCI'),('travisci','Travis CI'),('sonarcloud','SonarCloud'),('sonarqube','SonarQube'),('npm','npm'),('packagist','Packagist'),('algolia','Algolia'),('elastic','Elastic'),('grafana','Grafana'),('newrelic','New Relic'),('logrocket','LogRocket'),('amplitude','Amplitude'),('mixpanel','Mixpanel'),('hotjar','Hotjar'),('plausibleanalytics','Plausible Analytics'),('fathom','Fathom'),('matomo','Matomo'),('posthog','PostHog'),
('shopify','Shopify'),('bigcommerce','BigCommerce'),('woocommerce','WooCommerce'),('etsy','Etsy'),('ebay','eBay'),('paypal','PayPal'),('stripe','Stripe'),('square','Square'),('paddle','Paddle'),('lemonsqueezy','Lemon Squeezy'),('gumroad','Gumroad'),('kofi','Ko-fi'),('buymeacoffee','Buy Me a Coffee'),('opencollective','Open Collective'),('liberapay','Liberapay'),
('typeform','Typeform'),('jotform','Jotform'),('tally','Tally'),('calendly','Calendly'),('caldotcom','Cal.com'),('docusign','DocuSign'),('pandadoc','PandaDoc'),('zapier','Zapier'),('make','Make'),('n8n','n8n'),('ifttt','IFTTT'),('aircall','Aircall'),('intercom','Intercom'),('zendesk','Zendesk'),('freshdesk','Freshdesk'),('hubspot','HubSpot'),('salesforce','Salesforce'),('pipedrive','Pipedrive'),('zoho','Zoho'),
('feedly','Feedly'),('inoreader','Inoreader'),('flipboard','Flipboard'),('theguardian','The Guardian'),('nytimes','The New York Times'),('newyorktimes','The New York Times'),('thewashingtonpost','The Washington Post'),('theeconomist','The Economist'),('financialtimes','Financial Times'),('bloomberg','Bloomberg'),('reuters','Reuters'),('bbc','BBC'),('cnn','CNN'),('reddit','Reddit'),('x','X'),('telegram','Telegram'),('signal','Signal'),('vimeo','Vimeo'),('wistia','Wistia'),('loom','Loom'),('riverside','Riverside'),('descript','Descript'),('capcut','CapCut'),('invideo','InVideo'),
]
custom={
'spotify':('24735E','https://www.spotify.com/account/'),'netflix':('B42332','https://www.netflix.com/YourAccount'),
'youtube':('BC302F','https://www.youtube.com/paid_memberships'),'github':('282338','https://github.com/settings/billing'),
'notion':('282338','https://www.notion.so/'),'figma':('7251AF','https://www.figma.com/'),
'dropbox':('285FAD','https://www.dropbox.com/account/plan'),'discord':('5865F2','https://discord.com/'),
'twitch':('7756B8','https://www.twitch.tv/subscriptions'),'patreon':('BC4635','https://www.patreon.com/settings/memberships')}
selected=list(dict(candidates).items())
selected=[e for e in selected if e[0] in available]
assert len(selected)>=100, len(selected)
def fetch(entry):
    slug,title=entry;url=f'https://raw.githubusercontent.com/simple-icons/simple-icons/{revision}/icons/{slug}.svg'
    content=get(url);assert content.lstrip().startswith(b'<svg')
    (directory/f'{slug}.svg').write_bytes(content)
    return {'id':slug,'name':title,'url':url,'bytes':len(content),'sha256':hashlib.sha256(content).hexdigest()}
with ThreadPoolExecutor(max_workers=8) as pool: icons=list(pool.map(fetch,selected))
manifest={'source':'Simple Icons','revision':revision,'license':'CC0-1.0 (icons); trademarks remain with respective owners','icons':icons}
(root/'docs/SIMPLE_ICONS_LICENSE.md').write_bytes(get(f'https://raw.githubusercontent.com/simple-icons/simple-icons/{revision}/LICENSE.md'))
(root/'docs/SERVICE_ICONS.json').write_text(json.dumps(manifest,indent=2),encoding='utf-8')
source="""class ServiceBrand {
  const ServiceBrand(this.id,this.name,this.color,this.cancelUrl);
  final String id,name,cancelUrl;
  final int color;
  String get asset => 'assets/services/$id.svg';
}
const serviceBrands = [
"""
for slug,title in selected:
    color,url=custom.get(slug,('282338',''))
    # json encoding is also a valid Dart string for these service names.
    source+=f'  ServiceBrand({json.dumps(slug)},{json.dumps(title)},0xFF{color},{json.dumps(url)}),\n'
source+="""];
ServiceBrand? findBrand(String? id) {
  for(final brand in serviceBrands) { if(brand.id==id)return brand; }
  return null;
}
"""
(root/'lib/core/catalog.dart').write_text(source,encoding='utf-8')
print(f'{len(icons)} SVG icons, {sum(i["bytes"] for i in icons)} bytes')
