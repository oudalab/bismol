import gmtime

def normalize(valueToNomalize, keyToBeNormalizedFor):

	if keyToBeNormalizedFor == "URL":
		return valueToNomalize.encode('ascii',errors='ignore')
	elif keyToBeNormalizedFor == "timeStamp":
		if type(valueToBeNormalizedFor) is int:
			return gmtime(valueToBeNormalizedFor)
		else:
			return valueToNomalize.encode('ascii',errors='ignore')
	else:
		return valueToNomalize.encode('ascii',errors='ignore')

