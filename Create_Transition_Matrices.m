

%% Script Initialization
switchToCD;
clc;	clear;	close all;	
whitebg('w');	colormap lapham;
plottools('off'); close all;

% Supress the warning raised by imshow() because why does this even exist?
warning('off','images:imshow:magnificationMustBeFitForDockedFigure');
set(0,'DefaultFigureWindowStyle','docked');

iFig = 0;



% Stretch and crop the colormap arbitrarily to get a nice-looking figure
vColormap = lapham(220);
vColormap = flipud(vColormap);
vColormap = vColormap((1:129)+91,:); 
vColorscale = linspace(0,1,size(vColormap,1));
vPercentTicks = (1:32:size(vColormap,1));
vPercentLabels = cellstr(num2str(vColorscale(vPercentTicks)'*100));
vPercentLabels = cellfun(@(i) strtrim(sprintf('%s%%', i)), vPercentLabels, 'UniformOutput', false);

% Test colormap
iFig=iFig+1; figure(iFig);
colormap(vColormap);
imagescz( ones(10,1)*vColorscale );
xticks(vPercentTicks);
xticklabels(vPercentLabels);

% Constant for clearing and adding first byte in Egyptian Unicode
BYTE_OFFSET = 21504;

%% English Corpus

disp('English');

% Corpus of Egyptian texts from JSesh in Unicode with spaces separating lines and texts
strEngCorpus = txtread('HP_Clean.txt');

% Make sure it has enough spaces to make the space character the most frequent
strEngCorpus = [ strEngCorpus (strEngCorpus*0+' ') ];

% Show distribution of glyph frequencies
[vProbability, vLetters] = get_glyph_distribution(strEngCorpus);
nGlyphsEng = length(vProbability);
vCumulative = cumsum(vProbability);

% Show most to least ratio
disp(sprintf('Ratio of frequency between %s and %s: %f', vLetters(1), vLetters(end), vProbability(1)/vProbability(end)));

% Show entropy
fEntropy = -vProbability' * log2(vProbability);
disp(sprintf('English:\tEntropy = %f\tRedundancy = %f', fEntropy, 1-fEntropy/log2(length(vProbability))));
disp(sprintf('English:\tMaximum Entropy = %f', log2(nGlyphsEng)));

% Find the number of glyphs required to cover 80% of corpus
iTopEightyEng = find( vCumulative > 0.8, 1, 'first' );
disp(vLetters(1:iTopEightyEng))

% Plot the distributions
iFig=iFig+1; figure(iFig);
plot(vProbability);

print( sprintf('English Glyph Frequency.eps'), '-depsc', '-painters' );

iFig=iFig+1; figure(iFig);
plot(vCumulative);
hold on;
plot(iTopEightyEng, vCumulative(iTopEightyEng), 'or');
hold off;

%%
% Get n most frequent glyphs and pairings and save the results
for nMostFrequent = [ 10 iTopEightyEng nGlyphsEng ]
	
	[mTransitionEng, vLetters, vInformation] = get_transition_matrix_from_corpus(strEngCorpus, nMostFrequent);
	
	% Distibution of probabilities
	vProb = linspace(0,1,1000);
	vProbDist = ksdensity(mTransitionEng(:), vProb, 'Bandwidth', 0.01);
	iFig=iFig+1; figure(iFig);
	colormap(vColormap);
	plot(vProb, log(vProbDist+1));
	
	print( sprintf('English Probabilities %i.eps', nMostFrequent), '-depsc', '-painters' );
	
	% Glyph information content
	[vInformation, iSort] = sort(vInformation);
	vLettersInfo = char(vLetters(iSort));
	
	% Display information content
	iFig=iFig+1; figure(iFig);
	plot(vInformation);
	
	print( sprintf('English Letter Information Content %i.eps', nMostFrequent), '-depsc', '-painters' );

	% Display results
	
	iFig=iFig+1; figure(iFig);
	colormap(vColormap);
	imagescz([ mTransitionEng ones(nMostFrequent,1) ]);
	xticks(1:length(vLetters));
	xticklabels(vLetters);
	yticks(1:length(vLetters));
	yticklabels(vLetters);
	axis equal;

	print( sprintf('English Transition Matrix %i.eps', nMostFrequent), '-depsc', '-painters' );

	% Get average of each transition's entropy and just output it to the console
	[vH,vR] = get_transition_entropy( mTransitionEng );
	disp(sprintf('English (in context):\t%i paired-letters\tEntropy = %f\tRedundancy = %f', nMostFrequent, mean(vH), mean(vR)));
end

%% Egyptian Corpus

disp('Egyptian');

% Letters to label on the plots
vShowLetters = {'N31'; 'G7'; 'G41'; 'G17'; 'O28'; 'R11'; 'C11'; 'E21'};
vShowLettersHex = gsc2unicode(vShowLetters);
vShowLettersDec = hex2dec(vShowLettersHex)-BYTE_OFFSET;

% Corpus of Egyptian texts from JSesh in Unicode with spaces separating lines and texts
strEgyCorpus = txtread('Egyptian.txt');

% Skip (constant) high-order byte in Egyptian, add back in later for display
% This is a cludge to deal with Matlab's poor Unicode handling.
% It works because the first byte in Egyptian Unicode is always: 21504 (BYTE_OFFSET).
strEgyCorpus = strEgyCorpus(2:2:end);

% Make sure it has enough spaces to make the space character the most frequent
strEgyCorpus = [ strEgyCorpus (strEgyCorpus*0+' ') ];

% Show distribution of glyph frequencies
[vProbability, vLetters] = get_glyph_distribution(strEgyCorpus);
nGlyphsEgy = length(vProbability);
vCumulative = cumsum(vProbability);

% Get positions and probabilities of letters to label
vShowLettersRank = zeros(size(vShowLetters));
for i = 1:length(vShowLetters)
	vShowLettersRank(i) = find(vLetters == vShowLettersDec(i));
end
vShowLettersProb = vProbability(vShowLettersRank);

% Show most to least ratio
disp(sprintf('Ratio of frequency between %s and %s: %f', dec2hex(vLetters(1)+21504), dec2hex(vLetters(end)+21504), vProbability(1)/vProbability(end)));

% Show entropy
fEntropy = -vProbability' * log2(vProbability);
disp(sprintf('Egyptian:\tEntropy = %f\tRedundancy = %f', fEntropy, 1-fEntropy/log2(length(vProbability))));
disp(sprintf('Egyptian:\tMaximum Entropy = %f', log2(nGlyphsEgy)));

% Output the Egyptian glyphs in order of frequency to an HTML file
strBody = '';
for i = 1:length(vLetters)
		strBody = sprintf('%s%s:\t&#x%s\t%f%% <br />\n', strBody, dec2hex(vLetters(i)+BYTE_OFFSET), dec2hex(vLetters(i)+BYTE_OFFSET), vProbability(i)*100);
end
htmlwrite( strBody, 'Egyptian Glyphs in Order of Frequency.html' );

% Find the number of glyphs required to cover 80% of corpus
iTopEightyEgy = find( vCumulative > 0.8, 1, 'first' );

% Plot the distributions
iFig=iFig+1; figure(iFig);
plot(vProbability);
hold on;
plot(vShowLettersRank,vShowLettersProb, 'ok');
text(vShowLettersRank,vShowLettersProb,vShowLetters,'VerticalAlignment','bottom','HorizontalAlignment','left')
hold off;

print( sprintf('Egyptian Glyph Frequency.eps'), '-depsc', '-painters' );

hold on;
plot(iTopEightyEgy, vCumulative(iTopEightyEgy), 'or');
hold off;

iFig=iFig+1; figure(iFig);
plot(vCumulative);
hold on;
plot(iTopEightyEgy, vCumulative(iTopEightyEgy), 'or');
hold off;



% Get n most frequent glyphs and pairings and save the results
for nMostFrequent = [ nGlyphsEgy ]
	
	%%
	[mTransitionEgy, vLetters, vInformation] = get_transition_matrix_from_corpus(strEgyCorpus, nMostFrequent);
	
	% Distibution of probabilities
	vProb = linspace(0,1,1000);
	vProbDist = ksdensity(mTransitionEgy(:), vProb, 'Bandwidth', 0.001);
	iFig=iFig+1; figure(iFig);
	colormap(vColormap);
	plot(vProb, log(vProbDist+1));
	
	print( sprintf('Egyptian Probabilities %i.eps', nMostFrequent), '-depsc', '-painters' );
	
	%%
	% Glyph information content
	[vInformation, iSort] = sort(vInformation);
	vLettersInfo = char(vLetters(iSort));
	
	% Eliminate glyphs with 0 information (never appear after another glyph)
	vLettersInfo = vLettersInfo(vInformation~=0);
	vInformation = vInformation(vInformation~=0);
	
	% Get Unicode and Gardiner Sign Codes
	vLettersInfoHex = cellstr(dec2hex(vLettersInfo+BYTE_OFFSET));
	vLettersInfoGSC = unicode2gsc(vLettersInfoHex);
	
	% Get positions and information of letters to label
	vShowLettersRank = zeros(size(vShowLetters));
	for i = 1:length(vShowLetters)
		vShowLettersRank(i) = find(vLettersInfo == vShowLettersDec(i));
	end
	vShowLettersInfo = vInformation(vShowLettersRank);
	
	% Output the Egyptian glyphs in order of information content to an HTML file
	strBody = '';
	for i = 1:length(vLettersInfo)
			strBody = sprintf('%s%s:\t&#x%s\t%f <br />\n', strBody, vLettersInfoGSC{i}, vLettersInfoHex{i}, vInformation(i));
	end
	htmlwrite( strBody, sprintf('Egyptian Glyph Information Content %i', nMostFrequent) );
	
	% Display information content
	iFig=iFig+1; figure(iFig);
	plot(vInformation);
	hold on;
	plot(vShowLettersRank,vShowLettersInfo, 'ok');
	text(vShowLettersRank,vShowLettersInfo,vShowLetters,'VerticalAlignment','bottom','HorizontalAlignment','left');
	hold off;
	
	print( sprintf('Egyptian Glyph Information Content %i.eps', nMostFrequent), '-depsc', '-painters' );
	
	%%
	
	
	% Display transition matrix
	iFig=iFig+1; figure(iFig);
	colormap(vColormap);
	imagescz(mTransitionEgy);
	xticks(1:length(vLetters));
	xticklabels(cellstr(dec2hex(char(vLetters)+BYTE_OFFSET)));
	yticks(1:length(vLetters));
	yticklabels(cellstr(dec2hex(char(vLetters)+BYTE_OFFSET)));
	axis equal;
	

	print( sprintf('Egyptian Transition Matrix %i.eps', nMostFrequent), '-depsc', '-painters' );

	% Outputting the labels is a bit complicated for Egyptian
	% Create an HTML file with hex codes of the labels to display them properly
	strBody = '';
	for i = 1:length(vLetters)
		strBody = sprintf('%s%s:\t&#x%s <br />\n', strBody, dec2hex(vLetters{i}+BYTE_OFFSET), dec2hex(vLetters{i}+BYTE_OFFSET));
	end
	htmlwrite( strBody, sprintf('Egyptian Transition Matrix Chart Labels %i', nMostFrequent) );
	
	% Get average of each transition's entropy and just output it to the console
	[vH,vR] = get_transition_entropy( mTransitionEgy );
	disp(sprintf('Egyptian (in context):\t%i letters\tEntropy = %f\tRedundancy = %f', nMostFrequent, mean(vH), mean(vR)));
end

%% Make and save a new figure with both on the same scale

% Minimum probability in either matrix for padding smaller English matrix to fit
fMinProb = min( [ mTransitionEgy(:)' mTransitionEng(:)' ] );
mTransitionEngPadded = padarray(mTransitionEng, (size(mTransitionEgy,1)-size(mTransitionEng,1))*[1 1], fMinProb, 'post');

mTransitionBoth = [ mTransitionEgy mTransitionEngPadded ];
vXTickLabels = [ cellstr(dec2hex(char(vLetters)+BYTE_OFFSET)) ; cellstr(('a':'z')') ];


iFig=iFig+1; figure(iFig);

colormap(vColormap);
imagescz( mTransitionBoth );
xticks(1:length(vLetters)*2);
xticklabels(vXTickLabels);
yticks(1:length(vLetters));
yticklabels(cellstr(dec2hex(char(vLetters)+BYTE_OFFSET)));
axis equal;

print( sprintf('Egyptian & English Transition Matrix.eps'), '-depsc', '-painters' );

% Create a scale for inclusion in the text
vColorscale = linspace(min(mTransitionBoth(:)),max(mTransitionBoth(:)),size(vColormap,1));
vPercentTicks = (1:32:size(vColormap,1));
vPercentLabels = cellstr(num2str(vColorscale(vPercentTicks)'*100));
vPercentLabels = cellfun(@(i) strtrim(sprintf('%s%%', i)), vPercentLabels, 'UniformOutput', false);

iFig=iFig+1; figure(iFig);
colormap(vColormap);
imagescz(vColorscale);
xticks(vPercentTicks);
xticklabels(vPercentLabels);
axis equal;
grid on;

print( sprintf('Egyptian & English Color Scale.eps'), '-depsc', '-painters' );



















