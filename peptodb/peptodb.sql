
-- main tweets
CREATE  TABLE tweets (
	tweetid bigint, -- tweet of the id
	runid bigint, -- id of the set of keywords that was used to get this tweets
	status text, -- text of the tweet
	statusvec tsvector,	-- postgresql tweet vector
	tweet json	-- full tweet json
);

-- Classification
CREATE  TABLE classification (
	tweetid bigint, -- tweet of the id
	runid text, -- id of the run or user that made the classification
	label_date text, -- date the classification was made
	class text, -- the classification of the tweet
	conf float -- confidence of the classification
);

-- run information
CREATE  TABLE runs (
	runid text,
	run_date text, -- date this run was created
	filter_text text, -- text used if the filter used
	userid text -- userid that is extracting this data
);

-- TODO
-- Geocode table for tweets with geocodes
--CREATE  TABLE geolocations (
--	tweetid bigint, -- from the tweets table 
--	point POINT,
--	place BOX
--);

-- indices 

