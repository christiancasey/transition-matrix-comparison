function strHTML = htmlwrite( strBody, strTitle, strFileName )
% Simple function for outputting data in HTML file

	if(~exist('strFileName'))
		strFileName = [ strTitle '.html' ];
	end
	
	strHTML = sprintf('<html><head><title>%s</title></head><body>\n%s\n</body></html>', strTitle, strBody);
	txtwrite( strHTML, strFileName );