function [vProbability, vLetters] = get_glyph_distribution(strCorpus)


	% Use the unique function to get a list of letters 
	% and a transcription of the corpus with indices from that list
	% e.g. [a d b a] -> [a b d], , [1 3 2 1]
	[strLetters,~,vIndices] = unique(strCorpus);

	iNumLetters = max(vIndices);
	vLetterIndices = 1:iNumLetters;
	vLetterCounts = histc(vIndices, vLetterIndices);
	[vLetterCounts, iFreqIndex] = sort(vLetterCounts, 'descend');
	vLetterIndices = vLetterIndices(iFreqIndex);
	
	% Remove space character
	vLetterCounts = vLetterCounts(2:end);
	vLetterIndices = vLetterIndices(2:end);
	
	vProbability = vLetterCounts / sum(vLetterCounts);
	vLetters = strLetters(vLetterIndices);
	
	