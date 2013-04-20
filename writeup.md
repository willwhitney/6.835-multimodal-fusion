Will Whitney

# Multimodal Signal Fusion Using HMMs

## Unimodal Gesture Recognition

**Question 1**: From the experiments using body features (Part 1a) and hand features (Part 1b), what are the best classification accuracies you obtained? What parameter values did you validate and what was your strategy for finding the best parameter value?

Using body features, I obtained a classification accuracy of 0.606250 with parameters `H=12, G=1`. I used the grid search method given in `run.m` to select this parameters.

Using hand features, the maximum classification accuracy was 0.642708, with `H=8, G=2`. This result was also obtained using the given grid search methodology.

For both of these tests, all combinations of the parameters `H = {8, 4, 12}` and `G = {1, 3}` were tested.

**Question 2**: For each experiment, the run.m script will automatically generate a confusion matrix for the best performing model. Submit and interpret the two confusion matrices you obtained: For each modality explain which pairs of gestures are confused the most and *why* you think they were. See the gesture pairs in Figure 1 and use them in explaining the *why*.

![](/Users/will/Dropbox/MIT/6.835/miniproject4/body_only.png)

For the body-only interpretation, gesture 1 was the most misinterpreted, as almost 70% of the time it was predicted as gesture 2. Gestures 5 and 6 were also thoroughly confused, with gesture 6 being interpreted more than half of the time as gesture 5. Gesture 5 itself was only barely more than half the time correctly interpreted. While gestures 3 and 4 were sometimes confused with each other, they were more distinguishable than the other confused pairs.

From examining the diagrams, these confused pairs of gestures make perfect sense. These pairs have the same arm movements, and differ only in the hand position used for the gesture. The fact that gestures 3 and 4 are usually distinguishable is actually somewhat surprising, and probably reflects a difference in the arm movements caused by the wrist orientation change. Perhaps the signaler does not bring his hands as close together when the thumbs are pointing inward, towards each other.

![](/Users/will/Dropbox/MIT/6.835/miniproject4/hand_only.png)

The hand-only predictions exhibit some confusion between gestures 2 and 3, 1 and 3, and 2 and 4. This confusion was asymmetrical in the cases of 1 <--> 3 and 2 <--> 3, in that gesture 1 was misread as gesture 3, but 3 was not misread as 1. Similarly, 3 was read as 2, but not vice versa. Throughout gestures 1-4, likelihood of erroneous interpretation as gesture 2 was very high, with gesture 1 having the lowest (0.18) chance of such misreading.

Confusion between gestures 4 and 2, and gestures 3 and 1, makes perfect sense; these involve the exact same right hand orientation and pose on the features included in our data. The confusion between 2 and 3, however, is somewhat more perplexing, as the only features they (should) share are right hand palm state. Gesture 2 is thumb down, gesture 3 is thumb up, and gesture 2 only uses the right hand while gesture 3 uses both.


**Question 3**: Follow the steps in Part 2a. What is the best classification accuracy you obtained using early fusion HMM? What parameter values did you try and what was your strategy for finding the best parameter value?

The early fusion HMM achieved an accuracy of 0.872917 with the parameters `H = 8` and `G = 1`. I found this value using the grid search method implemented in `run.m`, which tested `H = {8, 4, 12}` and `G = {1, 3}`. 

**Question 4**: Implement testLateHMM.m to perform late fusion, and explain your implementation with pseudocode in your writeup. Note that you must follow the type signature of the function, as the function’s input and output parameters are used in the function experiment late hmm.m.

	Given:
	- the data, `seqs`
	- ground truth `labels`
	- the body and hand HMMs as `hmm{1, 2}`
	- the `featureMap` of which features go with which HMMs
	- the `weightsMV`, a list of weightings to try
	
	Calculate the log-likelihoods for each option on each gesture for just the body HMM and body data
	Calculate the log-likelihoods for each option on each gesture for just the hand HMM and hand data
	
	For each weighting in `weightsMV`:
		For each sample in `seqs`:
			Compute the weighted average of the likelihoods given by body and hand for each of the six possible interpretations 
			Select the most likely interpretation and store it in `stat`
			
		Determine the percentage of 
			
	

**Question 5**: Follow the steps in Part 2b. What is the best classification accuracy you can get using late fusion HMM? What parameter values did you validate and what was your strategy for finding the best parameter value? Which weight value tends to give you the best performance in terms of the classification accuracy? Why do you think that weight value give the best result?
[Late HMM] accuracy=0.846875 (H=[12 8],G=[3 2],W=[0.50 0.50])**Question 6**: Describe the differences between early and late fusion algorithms in terms of the underlying assumptions, how the classifiers are trained and then used to test new samples.
**Question 7**: Submit and interpret the two confusion matrices you obtained (both from early fusion and late fusion). Which approach (early versus late) performed better? Pick the confusion matrix that performed better and compare it to the two confusion matrices you obtained in Question 2. What differences do you see? Do you see a better classification accuracy on those gesture pairs that were confused the most in unimodal approach? Why do you think the performance has improved?
![](/Users/will/Dropbox/MIT/6.835/miniproject4/early_fusion.png)

![](/Users/will/Dropbox/MIT/6.835/miniproject4/late_fusion.png)**Question 8**: Implement the function `chmm = make_chmm(N,Q,X)` (located inside trainCHMM.m) that generates the graph structure of a coupled HMM. Explain your implementation with pseudocode in your writeup. Note that you must follow the type signature of the function, as the function’s input and output parameters are used in the function trainCHMM.m.

**Question 9**: Follow the step in Part 3 and run an experiment using coupled HMM. What is the best classification accuracy you obtained using coupled HMM? What parameter values did you validate and what was your strategy for finding the best parameter value?
[Coupled HMM] accuracy=0.766667 (H=[8 8],G=[1 1])￼￼￼￼￼￼￼￼￼
**Question 10**: Submit and interpret the confusion matrix you obtained, comparing to the confusion matrices you obtained so far. Does coupled HMM tend to perform better than the early/late fusion HMMs? Why do you think it did (or did not)?

![](/Users/will/Dropbox/MIT/6.835/miniproject4/coupled.png)
**Question 11**: Describe the differences between coupled HMM and early/late fusion HMMs in terms of the underlying assumptions, how the classifiers are trained and then used to test new samples.
**Question 12**: What are the two assumptions that a co-training algorithm makes? In the context of the NATOPS dataset, do those assumptions make sense?

Co-training algorithms are algorithms that employ more than one observable variable about the data, in this case the hand data and the body data. These algorithms rely on the idea that these different views into the data can correct one another's ambiguity, and that each of the views is itself able to classify the data. More formally, the two assumptions of co-training are:

1. Conditional Independence. That is, each view into the data must provide answers which are not correlated with those of the other view, except via the correct, ground-truth classification. If the two views are correlated, they will have the same errors, and thus not be able to cross-correct their output.

2. Sufficiency. Each view must be sufficient to accurately classify the data on its own. That way, each of the views can generate labels from a set of unlabeled training data using its own highest-confidence classifications, then train the other view using this newly-labeled data.

These assumptions seem fairly logical for this problem. Consulting the confusion diagrams for the body-only and hand-only classifiers, their mistakes don't seem to overlap most of the time. The body HMM, for example, frequently labels gesture 4 as gesture 3, but the hand HMM can determine conclusively that gesture 4 is not gesture 3. While neither of them has especially good accuracy for gesture 4, they don't have the *same* problems. They also seem to meet the sufficiency requirement, according to the individual accuracies of the HMMs (0.606250 and 0.642708).
**Question 13**: Implement trainCoHMM.m that performs co-training of HMMs. We have provided you with pseudocode for implementing co-training algorithms (Figure 3). Note that you must follow the type signature of the function, as the function’s input and output parameters are used in the function experiment cotrain_hmm.m.

**Question 14**: Follow the step in Part 4 and run an experiment using co-training HMM. What is the best classification accuracy you obtained using co-training HMM? What parameter values did you try out and what was your strategy for finding the best parameter value? Submit and interpret the confusion matrix you obtained.







































