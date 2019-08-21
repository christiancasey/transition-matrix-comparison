function v = unicode2gsc( v )
% Returns the Gardiner Sign Code based on the Unicode hex string
	
	load GSCUnicodeHex;
	
	if(~iscell(v))
		v = {v};
	end
	
	vOut = cell(size(v));
	
	for i = 1:length(v(:))
		iMatch = find(strcmp(vGSCUnicodeHex(:,2),v{i}));
		if(isempty(iMatch))
			error(sprintf('Sign Code not found: %s', v{i}));
		end
		
		vOut{i} = vGSCUnicodeHex{iMatch,1};
	end
	
	v = vOut;
		