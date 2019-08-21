function [vEntropy, vRedundancy] = get_transition_entropy( mTransition )

	mEntropy = mTransition .* log2(mTransition);
	mEntropy(mTransition==0) = 0;
	
	vEntropy = -1 * sum( mEntropy, 2 );
	
	vRedundancy = 1 - vEntropy / log2(size(mTransition,2));