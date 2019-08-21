function [mTransition, vLetters, vInformation] = get_transition_matrix_from_corpus(strCorpus, nMostFrequent)


	% Use the unique function to get a list of letters 
	% and a transcription of the corpus with indices from that list
	% e.g. [a d b a] -> [a b d], , [1 3 2 1]
	[strLetters,~,vIndices] = unique(strCorpus);

	iNumLetters = max(vIndices);
	vLetterIndices = 1:iNumLetters;
	vLetterCounts = histc(vIndices, vLetterIndices);
	[vLetterCounts, iFreqIndex] = sort(vLetterCounts, 'descend');
	vLetterIndices = vLetterIndices(iFreqIndex);

	nMostFrequent = nMostFrequent+1; % Add one to include crucial space character
	nMostFrequent = min(nMostFrequent,iNumLetters); % Prevent out of range

	% Take only the top n letters now to speed processing later
	vLetterCounts = vLetterCounts(1:nMostFrequent);
	vLetterIndices = vLetterIndices(1:nMostFrequent);

	% Use a logical vector to determine whether each letter is among the most frequent
	vKeepLetter = logical(vIndices*0);
	for i = 1:length(vLetterIndices)

		vKeepLetter = vKeepLetter | (vIndices==vLetterIndices(i));

	end
	% Keep only the most frequent letters
	strCorpus = strCorpus(vKeepLetter);

	% Redo unique and indexing with new reduced corpus
	[strLetters,~,vIndices] = unique(strCorpus);
	iNumLetters = max(vIndices);
	vLetterIndices = 1:iNumLetters;

	% Make bigram matrix
	mTransitionRaw = zeros(nMostFrequent);

	vBigrams = [ vIndices(1:end-1) vIndices(2:end) ];


	for i = 1:size(vBigrams,1)
		mTransitionRaw(vBigrams(i,1), vBigrams(i,2)) = mTransitionRaw(vBigrams(i,1), vBigrams(i,2)) + 1;
	end
	
	% Normalize rows
	mTransition = mTransitionRaw ./ (sum(mTransitionRaw,2)*ones(1,nMostFrequent));
	
	% Calculate glyph information content (based on Piantadosi 2011)
	mTransitionLog = log2(mTransition);
	mTransitionLog(mTransition==0) = 0;
	vInformation = sum(-1*mTransitionLog, 1) ./ sum(mTransitionRaw, 1);

	% Get rid of space character
	mTransition = mTransition(2:end,2:end);
	strLetters = strLetters(2:end);
	vInformation = vInformation(2:end);
	
	vLetters = cellstr(strLetters')';
	
	
	
	