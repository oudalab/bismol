

-- main tweets
CREATE OR REPLACE TABLE tweets (
	tweetid long, -- tweet of the id
	runid long, -- id of the set of keywords that was used to get this tweets
	status string, -- text of the tweet
	statusvec tsvector,	-- postgresql tweet vector
	tweet json	-- full tweet json
);

-- Classification
CREATE OR REPLACE TABLE classification (
	tweetid long, -- tweet of the id
	runid string, -- id of the run or user that made the classification
	label_date string, -- date the classification was made
	class string, -- the classification of the tweet
	conf float -- confidence of the classification
);


-- run information
CREATE OR REPLACE TABLE runs (
	runid string,
	run_date string, -- date this run was created
	filter_text string, -- text used if the filter used
	userid string -- userid that is extracting this data
);

-- TODO
-- Geocode table for tweets with geocodes
--CREATE OR REPLACE TABLE geolocations (
--	tweetid long, -- from the tweets table 
--	point POINT,
--	place BOX
--);

-- indices 
