#Making an interface file

The interface file has a few parts and is structured as a JSON file.

- name: The name of the source
- delimiter: The delimter for the file. If it is a TSV it'll be '\t' and a CSV ','
- hasHeader: Does the file have a header?
- mapping: Is an array of objects that contain mappings from the source file to the message object. The key in the object should either be a heading column (if the file has a header) or an intger value corresponding to the index of the value we want (if the file does not have a header)

##Example mapping

'''
{
  "name": "neel",
  "hasHeader": false,
  “delimiter”: ‘\t’,
  "mapping": [
    {"0": "URL"},
    {"1": "text"}
  ]
}
''' 
