import re, sys
with open(sys.argv[1], 'r', encoding='utf-8') as f:
    content = f.read()
matches = re.findall(r'<actor[^>]*id="(\d+)"[^>]*name="([^"]+)"', content)
for m in matches:
    print(f'{m[0]} - {m[1]}')
