"""Download a pinned SVG catalog. Prepare -> Flutter validate -> --install."""
from pathlib import Path
from urllib.request import Request,urlopen
from xml.etree import ElementTree as ET
import argparse,base64,hashlib,io,json,re,tarfile,zipfile
R=Path(__file__).resolve().parents[1];L=R/'.local/icon-sources';S=L/'staged'
LIMIT=8192;BUDGET=6*1024*1024
SPECIAL={'gemini':'googlegemini','copilot':'microsoftcopilot'}
TITLES={'openai':'ChatGPT','googlegemini':'Gemini','microsoftcopilot':'Microsoft Copilot','midjourney':'Midjourney','elevenlabs':'ElevenLabs','poe':'Poe','deepseek':'DeepSeek','grok':'Grok','openrouter':'OpenRouter','notebooklm':'NotebookLM','runway':'Runway','huggingface':'Hugging Face','replit':'Replit','claudecode':'Claude Code','aistudio':'Google AI Studio','codex':'OpenAI Codex','adobefirefly':'Adobe Firefly','lmstudio':'LM Studio','stability':'Stability AI','luma':'Luma','ideogram':'Ideogram','kling':'Kling AI','kimi':'Kimi','qwen':'Qwen','suno':'Suno','udio':'Udio','krea':'Krea','v0':'v0','zai':'Z.ai','githubcopilot':'GitHub Copilot'}
ALIASES={'openai':['gpt','chatgpt','chat gpt','openai','open ai','gpt-4','gpt4','gpt-5','gpt5','chatgpt plus','chatgpt pro'],'claude':['anthropic','sonnet','opus','haiku'],'googlegemini':['gemini','google','bard','google one'],'microsoftcopilot':['copilot','microsoft','bing'],'midjourney':['mid journey','mj'],'elevenlabs':['eleven labs','voz','voice'],'huggingface':['hugging face'],'codex':['openai codex','gpt codex']}
def get(url):return urlopen(Request(url,headers={'User-Agent':'Ritmia-icons'}),timeout=90).read()
def put(path,data):
 path.parent.mkdir(parents=True,exist_ok=True)
 if isinstance(data,bytes):path.write_bytes(data)
 else:path.write_text(data,encoding='utf-8')
def js(v):return json.dumps(v,ensure_ascii=False,indent=2)
def ds(v):return json.dumps(v,ensure_ascii=False).replace('$',r'\$')
def valid(raw, existing=False):
 if len(raw)>LIMIT and not existing:return False
 try:
  e=ET.fromstring(raw)
  if e.tag.split('}')[-1]!='svg':return False
  for n in e.iter():
   if n.tag.split('}')[-1] in ['script','foreignObject','image','text']:return False
   for k,v in n.attrib.items():
    if k.lower().startswith('on') or (k.split('}')[-1]=='href' and not v.startswith('#')):return False
    if 'url(' in v and re.search(r'url\(\s*[^#]',v):return False
  return b'data:' not in raw
 except ET.ParseError:return False
def packs():
 lock=R/'docs/ICON_PACKS.lock.json'
 if lock.exists():return json.loads(lock.read_text(encoding='utf-8'))
 result=[]
 for name in ['simple-icons','@lobehub/icons-static-svg']:
  data=json.loads(get('https://registry.npmjs.org/'+name+'/latest'))
  result.append({k:data[k] for k in ['name','version','license','dist']})
 put(lock,js(result));return result
def tar(info):
 p=L/(info['name'].split('/')[-1]+'-'+info['version']+'.tgz')
 if not p.exists():put(p,get(info['dist']['tarball']))
 raw=p.read_bytes();algo,digest=info['dist']['integrity'].split('-',1)
 assert base64.b64encode(hashlib.new(algo,raw).digest()).decode()==digest,'Integrity mismatch'
 return tarfile.open(fileobj=io.BytesIO(raw),mode='r:gz')
def prepare():
 S.mkdir(parents=True,exist_ok=True);records={};skipped=[];total=0
 catalog=(R/'lib/core/catalog.dart').read_text(encoding='utf-8')
 curated=set(re.findall(r'^\s*ServiceBrand\(["\']([^"\']+)',catalog,re.M))
 old={r['id']:r for r in json.loads((R/'docs/SERVICE_ICONS.json').read_text(encoding='utf-8'))['icons']}
 for p in sorted((R/'assets/services').glob('*.svg')):
  raw=p.read_bytes();assert valid(raw, existing=True),p.name
  put(S/p.name,raw);total+=len(raw);o=old.get(p.stem,{})
  records[p.stem]={'id':p.stem,'assetId':p.stem,'name':o.get('name',p.stem),'color':'282338','ai':False,'preserveColors':False,'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'source':o.get('url','existing project asset'),'license':o.get('license','See original source')}
 for info in packs():
  with tar(info) as archive:
   names=set(archive.getnames())
   if info['name']=='simple-icons':
    entries=json.load(archive.extractfile('package/data/simple-icons.json'))
    put(R/'docs/SIMPLE_ICONS_LICENSE.md',archive.extractfile('package/LICENSE.md').read())
    for entry in entries:
     slug=entry['slug'];path='package/icons/'+slug+'.svg'
     if slug in records or path not in names or not re.fullmatch('[a-z0-9]+',slug):continue
     raw=archive.extractfile(path).read()
     if not valid(raw) or total+len(raw)>BUDGET:skipped.append(slug);continue
     put(S/(slug+'.svg'),raw);total+=len(raw)
     records[slug]={'id':slug,'assetId':slug,'name':entry['title'],'color':entry['hex'],'ai':False,'preserveColors':False,'aliases':entry.get('aliases',{}).get('aka',[]),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'source':info['dist']['tarball']+'#icons/'+slug+'.svg','brandSource':entry.get('source'),'guidelines':entry.get('guidelines'),'license':entry.get('license',{'type':'Not specified per icon'}),'package':info['name'],'version':info['version']}
   else:
    bases=sorted(Path(n).stem for n in names if n.startswith('package/icons/') and n.endswith('.svg') and '-' not in Path(n).stem)
    priority=['openai','copilot','gemini','midjourney','poe','claude','cursor','elevenlabs']
    for base in priority+[b for b in bases if b not in priority]:
     slug=SPECIAL.get(base,base)
     if not re.fullmatch('[a-z0-9]+',slug):continue
     options=['package/icons/'+base+'-color.svg','package/icons/'+base+'.svg']
     chosen=next((p for p in options if p in names and valid(archive.extractfile(p).read())),None)
     if chosen is None:skipped.append('AI:'+base);continue
     raw=archive.extractfile(chosen).read();color=chosen.endswith('-color.svg')
     asset=slug+'-color' if color else slug
     if slug in records and not color:records[slug]['ai']=True;continue
     if total+len(raw)>BUDGET:skipped.append('budget:'+slug);continue
     put(S/(asset+'.svg'),raw);total+=len(raw)
     records[slug]={'id':slug,'assetId':asset,'name':TITLES.get(slug,base[:1].upper()+base[1:]),'color':'282338','ai':True,'preserveColors':color,'aliases':ALIASES.get(slug,[]),'bytes':len(raw),'sha256':hashlib.sha256(raw).hexdigest(),'source':info['dist']['tarball']+'#'+chosen.removeprefix('package/'),'license':{'type':'MIT','notice':'docs/LOBE_ICONS_LICENSE.txt'},'package':info['name'],'version':info['version']}
 for slug,r in records.items():
  r['aliases']=list(dict.fromkeys(r.get('aliases',[])+ALIASES.get(slug,[])))
  if slug in TITLES:r['name']=TITLES[slug]
 repo=json.loads(get('https://api.github.com/repos/lobehub/lobe-icons'))
 commit=json.loads(get('https://api.github.com/repos/lobehub/lobe-icons/commits/'+repo['default_branch']))['sha']
 license_url='https://raw.githubusercontent.com/lobehub/lobe-icons/'+commit+'/LICENSE'
 license_data=get(license_url);assert b'MIT' in license_data
 put(R/'docs/LOBE_ICONS_LICENSE.txt',license_data)
 put(L/'plan.json',js({'records':list(records.values()),'skipped':skipped,'curated':sorted(curated),'originalCatalogHash':hashlib.sha256(catalog.encode()).hexdigest(),'licenseSource':license_url}))
 print('Prepared',len(records),'brands;',len(list(S.glob('*.svg'))),'SVGs;',total,'bytes;',len(skipped),'excluded')
def install():
 plan=json.loads((L/'plan.json').read_text(encoding='utf-8'));validation=json.loads((L/'validation.json').read_text(encoding='utf-8'))
 source=(R/'lib/core/catalog.dart').read_text(encoding='utf-8')
 assert hashlib.sha256(source.encode()).hexdigest()==plan['originalCatalogHash'],'Catalog changed: merge user edits first'
 failures=set(validation['failures']);records=[r for r in plan['records'] if r['assetId']+'.svg' not in failures]
 assert any(r['id']=='openai' for r in records),'ChatGPT SVG is required'
 for r in records:
  dest=R/'assets/services'/(r['assetId']+'.svg')
  if not dest.exists():put(dest,(S/dest.name).read_bytes())
 curated=set(plan['curated']);extras=sorted([r for r in records if r['id'] not in curated],key=lambda r:(not r['ai'],r['name'].casefold()))
 source="part 'catalog_extra.dart';\n\n"+source
 source=source.replace('{this.hasAsset=true}','{this.hasAsset=true, this.assetId, this.preserveColors=false}')
 source=source.replace('final bool hasAsset;','final bool hasAsset;\n  final String? assetId;\n  final bool preserveColors;')
 source=source.replace("'assets/services/$id.svg'","'assets/services/"+'$'+"{assetId ?? id}.svg'")
 index={r['id']:r for r in records};lines=source.splitlines()
 for i,line in enumerate(lines):
  m=re.match(r'\s*ServiceBrand\(["\']([^"\']+)',line)
  if m and m[1] in index:
   r=index[m[1]];line=re.sub(r',\s*hasAsset:\s*false','',line)
   if r['assetId']!=r['id'] and 'assetId:' not in line:line=line.rstrip().removesuffix('),')+',assetId:'+ds(r['assetId'])+',preserveColors:'+str(r['preserveColors']).lower()+'),'
   lines[i]=line
 source='\n'.join(lines)+'\n';end=source.index('\n];',source.index('const serviceBrands = ['))
 source=source[:end]+'\n  ...extendedBrands,'+source[end:]
 body="part of 'catalog.dart';\n\n// Generated; curated names, URLs and colors remain in catalog.dart.\nconst extendedBrands = <ServiceBrand>[\n"
 for r in extras:
  body+='  ServiceBrand('+','.join([ds(r['id']),ds(r['name']),'0xFF'+r['color'],ds('')])
  if r['assetId']!=r['id']:body+=',assetId:'+ds(r['assetId'])
  if r['preserveColors']:body+=',preserveColors:true'
  body+='),\n'
 body+='];\nconst extendedAiBrandIds = <String>[\n'+''.join('  '+ds(r['id'])+',\n' for r in records if r['ai'])+'];\n'
 body+='const extendedBrandAliases = <String,List<String>>{\n'
 for r in records:
  if r.get('aliases'):body+='  '+ds(r['id'])+': ['+','.join(ds(a) for a in r['aliases'])+'],\n'
 body+='};\n'
 source=source.replace('for(final brand in serviceBrands) { if(brand.id==id)return brand; }\n  return null;', 'return _brandsById[id];')
 source+='\nfinal _brandsById = {for (final brand in serviceBrands) brand.id: brand};\n'
 source=source.replace("final source = aiOnly ? [for (final id in aiBrandIds) findBrand(id)!] : serviceBrands;","final source = aiOnly ? [for (final id in {...aiBrandIds,...extendedAiBrandIds}) if (findBrand(id) case final brand?) brand] : serviceBrands;")
 source=source.replace("(brandAliases[b.id] ?? const []).any((a) => a.contains(q))","[...brandAliases[b.id] ?? const <String>[], ...extendedBrandAliases[b.id] ?? const <String>[]].any((a) => _fold(a).contains(q))")
 put(R/'lib/core/catalog.dart',source);put(R/'lib/core/catalog_extra.dart',body)
 put(R/'docs/SERVICE_ICONS.json',js({'sources':packs(),'licenseSource':plan['licenseSource'],'note':'Collection licenses do not replace individual icon licenses or trademark rights.','icons':records,'excluded':plan['skipped']+list(failures)}))
 files=list((R/'assets/services').glob('*.svg'));zipped=io.BytesIO()
 with zipfile.ZipFile(zipped,'w',zipfile.ZIP_DEFLATED,compresslevel=9) as z:
  for p in files:z.writestr(p.name,p.read_bytes())
 report={'brands':len(curated)+len(extras),'aiBrands':len({*re.findall(r"'([^']+)'",source[source.index('const aiBrandIds'):source.index('const brandAliases')]),*[r['id'] for r in records if r['ai']]}),'svgFiles':len(files),'rawBytes':sum(p.stat().st_size for p in files),'zipBytes':len(zipped.getvalue()),'maxSvgBytes':max(p.stat().st_size for p in files),'failedSvg':sorted(failures),'networkAtRuntime':False}
 put(R/'docs/ICON_CATALOG_REPORT.json',js(report));print(js(report))
if __name__=='__main__':
 p=argparse.ArgumentParser();p.add_argument('--install',action='store_true');args=p.parse_args()
 install() if args.install else prepare()
