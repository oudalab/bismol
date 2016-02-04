import time

def normalize(valueToNormalize, keyToBeNormalizedFor):

	if keyToBeNormalizedFor == "URL":
		return valueToNormalize
	elif keyToBeNormalizedFor == "timeStamp":
		if type(valueToNormalize) is int:
			return gmtime(valueToNormalize)
		else:
			return valueToNormalize
	else:
		return valueToNormalize

