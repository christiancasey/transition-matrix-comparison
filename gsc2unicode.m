function v = gsc2unicode( v )
% Returns the Unicode hex string based on the Gardiner Sign Code
	
	load GSCUnicodeHex;
	
	if(~iscell(v))
		v = {v};
	end
	
	vOut = cell(size(v));
	
	for i = 1:length(v(:))
		iMatch = find(strcmp(vGSCUnicodeHex(:,1),v{i}));
		if(isempty(iMatch))
			error(sprintf('Sign Code not found: %s', v{i}));
		end
		
		vOut{i} = vGSCUnicodeHex{iMatch,2};
	end
	
	v = vOut;
		