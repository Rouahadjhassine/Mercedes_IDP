import urllib.request, json, base64, sys

token = '8bKvQuPO0EMpSPn7lxq3yVekP9jSaSY3C6aS6SPz9E6BV2WCTZP8JQQJ99CDACAAAAApUjDyAAASAZDO2TmK'
auth = base64.b64encode(b':' + token.encode()).decode()

url = 'https://dev.azure.com/ymi0337/IDP-MIC/_apis/build/builds/117/timeline?api-version=7.1'
req = urllib.request.Request(url)
req.add_header('Authorization', 'Basic ' + auth)

try:
    with urllib.request.urlopen(req) as response:
        data = json.loads(response.read())
        for r in data['records']:
            if r['type'] == 'Stage':
                name = r['name'].encode('ascii', 'ignore').decode('ascii')
                print(f"{name}: {r.get('state', '')} / {r.get('result', '')}")
except Exception as e:
    print('Error:', e)
