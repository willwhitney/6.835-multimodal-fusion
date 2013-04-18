Will Whitney

# Multimodal Signal Fusion Using HMMs

## Unimodal Gesture Recognition

**Question 1**: From the experiments using body features (Part 1a) and hand features (Part 1b), what are the best classification accuracies you obtained? What parameter values did you validate and what was your strategy for finding the best parameter value?

Using body features, I obtained a classification accuracy of 0.606250 with parameters `H=12, G=1`. I used the grid search method given in `run.m` to select this parameters.

Using hand features, the maximum classification accuracy was 0.642708, with `H=8, G=2`. This result was also obtained using the given grid search methodology.

**Question 2**: For each experiment, the run.m script will automatically generate a confusion matrix for the best performing model. Submit and interpret the two confusion matrices you obtained: For each modality explain which pairs of gestures are confused the most and *why* you think they were. See the gesture pairs in Figure 1 and use them in explaining the *why*.

![](/Users/will/Dropbox/MIT/6.835/miniproject4/body_only.png)

For the body-only interpretation, gesture 1 was the most misinterpreted, as almost 70% of the time it was predicted as gesture 2. Gestures 5 and 6 were also thoroughly confused, with gesture 6 being interpreted more than half of the time as gesture 5. Gesture 5 itself was only barely more than half the time correctly interpreted. While gestures 3 and 4 were sometimes confused with each other, they were more distinguishable than the other confused pairs.

From examining the diagrams, these confused pairs of gestures make perfect sense. These pairs have the same arm movements, and differ only in the hand position used for the gesture. The fact that gestures 3 and 4 are usually distinguishable is actually somewhat surprising, and probably reflects a difference in the arm movements caused by the wrist orientation change. Perhaps the signaler does not bring his hands as close together when the thumbs are pointing inward, towards each other.

![](/Users/will/Dropbox/MIT/6.835/miniproject4/hand_only.png)

The hand-only predictions exhibit some confusion between gestures 2 and 3, 1 and 3, and 2 and 4. This confusion was asymmetrical in the cases of 1 <--> 3 and 2 <--> 3, in that gesture 1 was misread as gesture 3, but 3 was not misread as 1. Similarly, 3 was read as 2, but not vice versa. Throughout gestures 1-4, likelihood of erroneous interpretation as gesture 2 was very high, with gesture 1 having the lowest (0.18) chance of such misreading.

Confusion between gestures 4 and 2, and gestures 3 and 1, makes perfect sense; these involve the exact same right hand orientation and pose on the features included in our data. The confusion between 2 and 3, however, is somewhat more perplexing, as the only features they (should) share are right hand palm state. Gesture 2 is thumb down, gesture 3 is thumb up, and gesture 2 only uses the right hand while gesture 3 uses both.


**Question 3**: Follow the steps in Part 2a. What is the best classification accuracy you obtained using early fusion HMM? What parameter values did you try and what was your strategy for finding the best parameter value?













**Question 10**: Submit and interpret the confusion matrix you obtained, comparing to the confusion matrices you obtained so far. Does coupled HMM tend to perform better than the early/late fusion HMMs? Why do you think it did (or did not)?




Co-training algorithms are algorithms that employ more than one observable variable about the data, in this case the hand data and the body data. These algorithms rely on the idea that these different views into the data can correct one another's ambiguity, and that each of the views is itself able to classify the data. More formally, the two assumptions of co-training are:

1. Conditional Independence. That is, each view into the data must provide answers which are not correlated with those of the other view, except via the correct, ground-truth classification. If the two views are correlated, they will have the same errors, and thus not be able to cross-correct their output.

2. Sufficiency. Each view must be sufficient to accurately classify the data on its own. That way, each of the views can generate labels from a set of unlabeled training data using its own highest-confidence classifications, then train the other view using this newly-labeled data.

These assumptions seem fairly logical for this problem. Consulting the confusion diagrams for the body-only and hand-only classifiers, their mistakes don't seem to overlap most of the time. The body HMM, for example, frequently labels gesture 4 as gesture 3, but the hand HMM can determine conclusively that gesture 4 is not gesture 3. While neither of them has especially good accuracy for gesture 4, they don't have the *same* problems. They also seem to meet the sufficiency requirement, according to the individual accuracies of the  (0.606250 and 0.642708).









































