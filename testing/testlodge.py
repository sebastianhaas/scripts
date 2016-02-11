import json, urllib2, base64, os


# Get settings from environment variables
name = os.environ['TESTLODGE_NAME']
email = os.environ['TESTLODGE_EMAIL']
password = os.environ['TESTLODGE_PASSWORD']
project = os.environ['TESTLODGE_PROJECT']

api_version = os.getenv('TESTLODGE_API_VERSION', 'v1')
base_url = os.getenv('TESTLODGE_BASE_URL', 'api.testlodge.com')

release_branch_prefix = os.getenv('TESTLODGE_RELEASE_BRANCH_PREFIX', 'release')
mocha_result_json = os.getenv('MOCHA_RESULT_JSON', 'mochaTestResults.json')

# Build url
url = 'https://{name}.{base_url}/{api_version}'.format(name=name, base_url=base_url, api_version=api_version)
print url

request = urllib2.Request('{url}/projects.json'.format(url=url))
base64string = base64.encodestring('%s:%s' % (email, password)).replace('\n', '')
request.add_header("Authorization", "Basic %s" % base64string)
result = urllib2.urlopen(request)
print result

with open("/Users/Sebastian/Documents/Development/practicebird/mochaTestResults.json") as json_file:
	json_object = json.load(json_file)
	for case_run in json_object['passes']:
		print case_run.keys()


