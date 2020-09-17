import json
import base64

data = {
         "records": [
           {
             "recordId": "1",
             "data": {
               "userId": "currentUserId",
               "mysfitId": "4e53920c-505a-4a90-a694-b9300791f0ae"
             }
           },
           {
             "recordId": "2",
             "data": {
               "userId": "2",
               "mysfitId": "2b473002-36f8-4b87-954e-9a377e0ccbec"
             }
           }
         ]
       }

with open('event.json') as json_file:
    event = json.load(json_file)

    out = []
    for record in data['records']:
        print('Processing record: ' + record['recordId'])
        # kinesis firehose expects record payloads to be sent as encoded strings,
        # so we must decode the data first to retrieve the click record.
        #click = json.loads(base64.b64decode(record['data']))

        s = json.dumps(record['data'])

        out.append(base64.b64encode(s.encode('utf-8')))

    print(out)