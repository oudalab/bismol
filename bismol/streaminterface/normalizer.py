import time

def normalize(valueToNormalize, keyToBeNormalizedFor):

	if keyToBeNormalizedFor == "URL":
		return valueToNormalize.encode('ascii',errors='ignore')
	elif keyToBeNormalizedFor == "timeStamp":
		if type(valueToNormalize) is int:
			return gmtime(valueToNormalize)
		else:
			return valueToNormalize.encode('ascii',errors='ignore')
	else:
		return valueToNormalize.encode('ascii',errors='ignore')

