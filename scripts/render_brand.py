"""Render the original geometric SVG identity into app icon PNGs."""
from pathlib import Path
from PIL import Image,ImageDraw
import json
root=Path(__file__).resolve().parents[1];brand=root/'assets/brand'
scale=8
canvas=Image.new('RGB',(160*scale,160*scale),'#282338')
d=ImageDraw.Draw(canvas)
def point(p):return ((p[0]+16)*scale,(p[1]+10)*scale)
def cubic(a,b,c,e):
    result=[]
    for i in range(101):
        t=i/100;u=1-t
        result.append((u*u*u*a[0]+3*u*u*t*b[0]+3*u*t*t*c[0]+t*t*t*e[0],u*u*u*a[1]+3*u*u*t*b[1]+3*u*t*t*c[1]+t*t*t*e[1]))
    return result
def stroke(points,color):
    p=[point(v) for v in points];r=6*scale
    d.line(p,fill=color,width=12*scale,joint='curve')
    for x,y in [p[0],p[-1]]:d.ellipse((x-r,y-r,x+r,y+r),fill=color)
stroke(cubic((61,101),(13,76),(14,37),(50,30))+cubic((50,30),(75,25),(98,37),(104,54)),'#B9A3F5')
for a,b in [((72,64),(102,84)),((66,88),(96,108)),((60,112),(84,128))]:stroke([a,b],'#B9A3F5')
x,y=point((104,19));r=10*scale;d.ellipse((x-r,y-r,x+r,y+r),fill='#F47D68')
canvas.resize((1024,1024),Image.Resampling.LANCZOS).save(brand/'app-icon.png',optimize=True)
sizes={'mdpi':48,'hdpi':72,'xhdpi':96,'xxhdpi':144,'xxxhdpi':192}
for density,size in sizes.items():canvas.resize((size,size),Image.Resampling.LANCZOS).save(root/f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
for path in (root/'ios/Runner/Assets.xcassets/AppIcon.appiconset').glob('*.png'):
    size=int(Image.open(path).width);canvas.resize((size,size),Image.Resampling.LANCZOS).save(path)
for size in [192,512]:
    for name in [f'Icon-{size}.png',f'Icon-maskable-{size}.png']:
        canvas.resize((size,size),Image.Resampling.LANCZOS).save(root/'web/icons'/name)
canvas.resize((32,32),Image.Resampling.LANCZOS).save(root/'web/favicon.png')
mark=(brand/'mark.svg').read_text()
(brand/'mark-ink.svg').write_text(mark.replace('#B9A3F5','#282338').replace('#7756B8','#282338').replace('#F47D68','#282338'))
(brand/'mark-white.svg').write_text(mark.replace('#B9A3F5','#FFFFFF').replace('#7756B8','#FFFFFF').replace('#F47D68','#FFFFFF'))
(brand/'palette.json').write_text(json.dumps({'ink':'#282338','lavender':'#B9A3F5','coral':'#F47D68','paper':'#F8F6F1','accessiblePrimary':'#7251AF'},indent=2))
print('Brand assets and native/web app icons rendered')
